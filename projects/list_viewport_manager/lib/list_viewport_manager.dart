import 'package:flutter/cupertino.dart';
import 'layout_callback_builder.dart';

typedef OnScrollStart = void Function(
    IScrollDataInterface scrollDataInterface, ScrollMetrics metrics);
typedef OnScrollUpdate = void Function(
    IScrollDataInterface scrollDataInterface, ScrollMetrics metrics);
typedef OnScrollEnd = void Function(
    IScrollDataInterface scrollDataInterface, ScrollMetrics metrics);

abstract class IScrollDataInterface {
  factory IScrollDataInterface(_ListLayoutManager listLayoutManager) =>
      _ImplScrollDataInterface._(listLayoutManager);

  int get firstVisibleIndex;
  int get lastVisibleIndex;
  int get nearCenterVisibleIndex;
  GestureDirection get gestureDirection;
  ComputedSize getComputedSize(int index);
  List<ComputedSize> get visibleComputedSizes;
}

class _ImplScrollDataInterface implements IScrollDataInterface {
  final _ListLayoutManager _listLayoutManager;

  _ImplScrollDataInterface._(this._listLayoutManager);

  @override
  int get firstVisibleIndex => _listLayoutManager._firstVisibleIndex!;

  @override
  int get lastVisibleIndex => _listLayoutManager._lastVisibleIndex!;

  @override
  int get nearCenterVisibleIndex => _listLayoutManager._nearCenterVisibleIndex!;

  @override
  GestureDirection get gestureDirection =>
      _listLayoutManager._gestureDirection!;

  @override
  ComputedSize getComputedSize(int index) =>
      _listLayoutManager._getComputedSize(index);

  @override
  List<ComputedSize> get visibleComputedSizes =>
      _listLayoutManager._visibleComputedSizes;
}

enum GestureDirection {
  forward,
  backward,
}

class ListModel extends _ListDataProxy {
  ListModel({required List dataList}) : super(dataList);

  @override
  addItems(List items) {
    super.addItems(items);
  }

  @override
  removeItem(int index) {
    super.removeItem(index);
  }

  @override
  updateItems(List items) {
    super.updateItems(items);
  }
}

abstract class IListDataUpdater {
  void addItems(List items);

  removeItem(int index);

  void updateItems(List items);

  void dispose();
}

mixin _ListLayoutManager on _ListSizeManager {
  Axis? _axis;

  //update
  GestureDirection? _gestureDirection;
  int? _firstVisibleIndex, _lastVisibleIndex; //可能为-1，都看不见
  int? _nearCenterVisibleIndex;
  double? _currentPosition;

  late IScrollDataInterface _scrollDataInterface = IScrollDataInterface(this);

  Widget buildChild({required int index, required Widget child}) {
    return LayoutCallbackBuilder(
        layoutCallback: (Size childSize) {
          final size =
              _axis == Axis.horizontal ? childSize.width : childSize.height;
          _updateHeightByLayout(index, size);
        },
        builder: (_, _$) => child);
  }

  List<ComputedSize> get _visibleComputedSizes {
    assert(_firstVisibleIndex != null);
    assert(_lastVisibleIndex != null);
    int firstVisibleIndex = _firstVisibleIndex!;
    final List<ComputedSize> computedSizes = [];

    while (firstVisibleIndex >= 0 && firstVisibleIndex <= _lastVisibleIndex!) {
      computedSizes.add(_getComputedSize(firstVisibleIndex++));
    }

    return computedSizes;
  }

  int _findVisibleIndex(int oldIndex, double pixels, double viewportDimension,
      double maxScrollExtent,
      {bool? reverse, bool Function(int index)? otherCondition}) {
    assert(_gestureDirection != null);
    final startPosition = pixels;
    final endPosition = pixels + viewportDimension;
    final centerPosition = pixels + viewportDimension / 2;
    if (endPosition <= 0 ||
        startPosition >= maxScrollExtent + viewportDimension) return -1;

    final lengthInSize = _getSizeLength();
    int currentOldIndex = oldIndex < 0
        ? (_gestureDirection == GestureDirection.forward ? 0 : lengthInSize - 1)
        : oldIndex;

    final nextBound = _gestureDirection == GestureDirection.forward
        ? currentOldIndex >= lengthInSize - 1
        : currentOldIndex <= 0;
    if (nextBound) {
      assert(currentOldIndex == 0 || currentOldIndex == lengthInSize - 1);
      return currentOldIndex;
    }

    int changeIndex(int index) =>
        _gestureDirection == GestureDirection.forward ? ++index : --index;

    final double baselinePosition = reverse == null
        ? centerPosition
        : (reverse ? endPosition : startPosition);

    return _findVisibleIndexByBaseline(
        currentOldIndex, baselinePosition, changeIndex,
        reverse: reverse, otherCondition: otherCondition);
  }

  int _findVisibleIndexByBaseline(
      int index, double baselinePosition, int Function(int index) changeIndex,
      {bool? reverse, bool Function(int index)? otherCondition}) {
    final lengthInSize = _getSizeLength();
    assert(index >= 0);
    assert(index < lengthInSize);
    int? currentIndex;
    int oldIndex = index;
    bool otherConditionResult;
    do {
      otherConditionResult = otherCondition?.call(index) ?? true;
      //当前下标没判断成功退出循环并取值老的下标
      if (!otherConditionResult) {
        currentIndex = oldIndex;
        break;
      }

      if (reverse != null) {
        final computedSize = _getComputedSize(index);
        final headPosition = computedSize.position;
        final tailPosition = computedSize.position + computedSize.size;
        final baseCondition = reverse
            ? headPosition < baselinePosition
            : tailPosition > baselinePosition;
        if (baseCondition) {
          final keyCondition = reverse
              ? (tailPosition >= baselinePosition || index >= lengthInSize - 1)
              : (headPosition <= baselinePosition || index <= 0);
          if (keyCondition) {
            currentIndex = index;
            break;
          }
        }
      }
      oldIndex = index;
      index = changeIndex(oldIndex);
    } while (index >= 0 && index < lengthInSize && otherConditionResult);

    currentIndex ??= index.clamp(0, lengthInSize - 1);

    assert(currentIndex >= 0);

    return currentIndex;
  }

  _nearCenterIndexComputer(double extentBefore, double viewportDimension) {
    double? bestNearPosition;
    return (int index) {
      final centerBaselinePosition = extentBefore + viewportDimension / 2;
      final ComputedSize computedSize = _getComputedSize(index);
      final nearPosition =
          (computedSize.centerPosition - centerBaselinePosition).abs();
      if (bestNearPosition == null) {
        bestNearPosition = nearPosition;
        return true;
      } else if (nearPosition < bestNearPosition!) {
        bestNearPosition = nearPosition;
        return true;
      }
      //有一个判断失败马上跳出循环
      return false;
    };
  }

  void _initCenterAndLastVisibleIndex(
      int firstVisibleIndex, double pixels, double viewportDimension) {
    assert(firstVisibleIndex >= 0);
    assert(firstVisibleIndex < _getSizeLength());
    assert(_lastVisibleIndex == null);
    assert(_nearCenterVisibleIndex == null);
    final baselinePosition = pixels + viewportDimension;
    final nearCenterIndexComputer =
        _nearCenterIndexComputer(pixels, viewportDimension);
    _lastVisibleIndex = _findVisibleIndexByBaseline(
        firstVisibleIndex, baselinePosition, (int index) => ++index,
        reverse: true, otherCondition: (int index) {
      final result = nearCenterIndexComputer(index);
      if (result) {
        _nearCenterVisibleIndex = index;
      }
      return true;
    });
  }

  void _updateScrollData(ScrollMetrics metrics) {
    assert(metrics.hasViewportDimension);
    //final extentBefore = metrics.extentBefore;
    //final extendAfter = metrics.extentAfter;
    final maxScrollExtent = metrics.maxScrollExtent;
    final pixels = metrics.pixels;
    final viewportDimension = metrics.viewportDimension;

    _currentPosition ??= 0;
    final double oldPosition = _currentPosition!;
    _gestureDirection = pixels > oldPosition
        ? GestureDirection.forward
        : GestureDirection.backward;
    _currentPosition = pixels;

    final _oldFirstVisibleIndex = _firstVisibleIndex ?? 0;
    if (_nearCenterVisibleIndex == null || _lastVisibleIndex == null) {
      _initCenterAndLastVisibleIndex(
          _oldFirstVisibleIndex, pixels, viewportDimension);
      assert(_nearCenterVisibleIndex != null);
      assert(_lastVisibleIndex != null);
    }

    final nearCenterIndexComputer =
        _nearCenterIndexComputer(pixels, viewportDimension);

    _firstVisibleIndex = _findVisibleIndex(
        _oldFirstVisibleIndex, pixels, viewportDimension, maxScrollExtent,
        reverse: false);
    _lastVisibleIndex = _findVisibleIndex(
        _lastVisibleIndex!, pixels, viewportDimension, maxScrollExtent,
        reverse: true);
    _nearCenterVisibleIndex = _findVisibleIndex(
        _nearCenterVisibleIndex!, pixels, viewportDimension, maxScrollExtent,
        otherCondition: nearCenterIndexComputer);
  }

  void _clearData() {
    _gestureDirection = null;
    _firstVisibleIndex = null;
    _lastVisibleIndex = null;
    _nearCenterVisibleIndex = null;
    _currentPosition = null;
  }

  Widget buildList(
      {required ScrollView child,
      OnScrollStart? onScrollStart,
      OnScrollUpdate? onScrollUpdate,
      OnScrollEnd? onScrollEnd}) {
    if (_axis != child.scrollDirection) {
      _axis = child.scrollDirection;
      _clearSizes();
    }

    _clearData();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
    });
    return NotificationListener(
      onNotification: (Notification notification) {
        if (notification is ScrollStartNotification) {
          final ScrollMetrics metrics = notification.metrics;
          _firstVisibleIndex ??= 0;
          if (_lastVisibleIndex == null || _nearCenterVisibleIndex == null) {
            _initCenterAndLastVisibleIndex(
                _firstVisibleIndex!, metrics.pixels, metrics.viewportDimension);
            assert(_lastVisibleIndex != null);
            assert(_nearCenterVisibleIndex != null);
          }
          onScrollStart?.call(_scrollDataInterface, metrics);
        } else if (notification is ScrollUpdateNotification) {
          final ScrollMetrics metrics = notification.metrics;
          _updateScrollData(metrics);
          onScrollUpdate?.call(_scrollDataInterface, metrics);
        } else if (notification is ScrollEndNotification) {
          onScrollEnd?.call(_scrollDataInterface, notification.metrics);
        }
        return false;
      },
      child: child,
    );
  }
}

mixin _ListSizeManager {
  List<ComputedSize>? _sizes;

  void _removeSize(int index) {
    assert(index >= 0);
    assert(index < _getSizeLength());
    _sizes!.removeAt(index);
  }

  ComputedSize _getComputedSize(int index) {
    assert(index >= 0);
    assert(index < _sizes!.length);
    return _sizes![index];
  }

  int _getSizeLength() {
    return _sizes?.length ?? 0;
  }

  void _clearSizes() {
    _sizes?.clear();
  }

  void _updateHeightByLayout(int index, double size) {
    assert(index >= 0);
    _sizes ??= [];

    final ComputedSize? preComputedSize =
        (index > 0 && index - 1 < _sizes!.length) ? _sizes![index - 1] : null;

    assert(preComputedSize != null || index == 0);

    final double position = preComputedSize == null
        ? 0
        : preComputedSize.position + preComputedSize.size;
    final newComputedSize = ComputedSize._(index, size, position);

    if (_sizes!.length > index) {
      _sizes![index] = newComputedSize;
    } else {
      assert(_sizes!.length == index);
      _sizes!.add(newComputedSize);
    }
  }
}

abstract class _ListDataProxy
    with _ListSizeManager, _ListLayoutManager
    implements IListDataUpdater {
  final List _dataList;
  _ListDataProxy(List dataList) : _dataList = dataList;

  @override
  void addItems(List items) {}
  removeItem(int index) {
    _removeSize(index);
  }

  @override
  void updateItems(List items) {}

  @override
  void dispose() {
    _dataList.clear();
    _clearData();
    _clearSizes();
  }

  dynamic operator [](int index) => _dataList[index];
  int get length => _dataList.length;
}

class ComputedSize {
  final int index;
  final double size;
  final double position;
  const ComputedSize._(this.index, this.size, this.position);

  @override
  int get hashCode => hashValues(index, size, position);

  double get centerPosition => position + size / 2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ComputedSize &&
        other.index == index &&
        other.size == size &&
        other.position == position;
  }

  @override
  String toString() =>
      "ComputedHeight(index: $index, size: $size, position: $position)";
}
