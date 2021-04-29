import 'package:flutter/cupertino.dart';
import 'layout_callback_builder.dart';
import 'dart:math';

typedef OnScrollStart = void Function(IScrollDataInterface scrollDataInterface);
typedef OnScrollUpdate = void Function(
    IScrollDataInterface scrollDataInterface);
typedef OnScrollEnd = void Function(IScrollDataInterface scrollDataInterface);
typedef OnUpdate = void Function(IScrollDataInterface scrollDataInterface);

abstract class IScrollDataInterface {
  factory IScrollDataInterface(_ListLayoutManager listLayoutManager) =>
      _ImplScrollDataInterface._(listLayoutManager);

  int get firstVisibleIndex;
  int get lastVisibleIndex;
  int get nearCenterVisibleIndex;
  bool get hasVisibleChild;
  ScrollMetrics get scrollMetrics;
  GestureDirection? get gestureDirection;
  ComputedSize getComputedSize(int index);
  List<ComputedSize> get visibleComputedSizes;
}

class _ImplScrollDataInterface implements IScrollDataInterface {
  _ListLayoutManager? _listLayoutManager;

  _ImplScrollDataInterface._(this._listLayoutManager);

  @override
  int get firstVisibleIndex => _listLayoutManager!._firstVisibleIndex!;

  @override
  int get lastVisibleIndex => _listLayoutManager!._lastVisibleIndex!;

  @override
  int get nearCenterVisibleIndex =>
      _listLayoutManager!._nearCenterVisibleIndex!;

  @override
  ScrollMetrics get scrollMetrics => _listLayoutManager!._scrollMetrics!;

  @override
  GestureDirection? get gestureDirection =>
      _listLayoutManager!._gestureDirection;

  @override
  ComputedSize getComputedSize(int index) =>
      _listLayoutManager!._getComputedSize(index);

  @override
  List<ComputedSize> get visibleComputedSizes =>
      _listLayoutManager!._visibleComputedSizes;

  void _dispose() {
    _listLayoutManager = null;
  }

  @override
  bool get hasVisibleChild => firstVisibleIndex >= 0;
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
  ScrollMetrics? _scrollMetrics;
  ScrollController? _scrollController;

  bool _updateMetricsFlag = false;
  bool _updateSizeFlag = false;
  OnUpdate? _onUpdate;

  int? _minIndexLayout, _maxIndexLayout;
  Map<int, double>? _cacheSizes;

  late IScrollDataInterface? _scrollDataInterface = IScrollDataInterface(this);

  @override
  void dispose() {
    _clearData();
    (_scrollDataInterface! as _ImplScrollDataInterface)._dispose();
    _scrollDataInterface = null;
    super.dispose();
  }

  Widget buildChild({required int index, required Widget child}) {
    return LayoutCallbackBuilder(
        layoutCallback: (Size childSize) {
          final size =
              _axis == Axis.horizontal ? childSize.width : childSize.height;
          final ComputedSize? oldComputedSize =
              _getSizeLength() <= index ? null : _getComputedSize(index);
          print(
              "layout => index: $index => newSize: $size, oldSize: ${oldComputedSize?.size ?? 0}");
          //_updateHeightByLayout(index, size);
          _cacheSizes ??= {};
          _cacheSizes![index] = size;

          _maxIndexLayout ??= index;
          _maxIndexLayout = max(_maxIndexLayout!, index);
          print(
              "update assert before");
          if (_isNeedUpdateIndex(index, size)) {
            print(
                "update assert after");
            _minIndexLayout ??= index;
            _minIndexLayout = min(_minIndexLayout!, index);
            _markUpdateSizesAfterLayout();
            print(
                "update assert after----------");
          }
          print(
              "update assert after2");
        },
        builder: (_, _$) => child);
  }

  void _update(ScrollMetrics scrollMetrics, {bool sync = false}) {
    if (_onUpdate == null || _updateMetricsFlag) return;
    final updater = _onUpdate!;
    _updateMetricsFlag = true;

    void syncUpdate(_) {
      _updateMetricsFlag = false;
      _updateScrollData(scrollMetrics);
      updater(_scrollDataInterface!);
    }

    if (sync) {
      syncUpdate('sync');
    } else {
      WidgetsBinding.instance!.addPostFrameCallback(syncUpdate);
    }
  }

  bool _isNeedUpdateIndex(int index, double size) {
    final length = _getSizeLength();
    if (index < length) {
      final ComputedSize oldComputedSize = _getComputedSize(index);
      return oldComputedSize.size != size;
    }
    return true;
  }

  //布局时调用
  void _markUpdateSizesAfterLayout() {
    if (_updateSizeFlag) return;

    _updateSizeFlag = true;

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _updateSizeFlag = false;
      final Map cacheSizes = _cacheSizes!;

      int minIndexLayout = _minIndexLayout!;
      final int maxIndexLayout = _maxIndexLayout!;
      _minIndexLayout = null;
      _maxIndexLayout = null;

      assert(minIndexLayout >= 0);
      assert(minIndexLayout <= maxIndexLayout);

      print("start update Layout => minIndexLayout: $minIndexLayout, maxIndexLayout: $maxIndexLayout");

      do {
        final size = cacheSizes[minIndexLayout] ?? _getComputedSize(minIndexLayout).size;
        print("start update => $minIndexLayout => cacheSizes[minIndexLayout]: ${cacheSizes[minIndexLayout]}, size: $size");
        _updateHeightByLayout(
          minIndexLayout,
          size,
          minIndexLayout == maxIndexLayout,
        );
      } while (++minIndexLayout <= maxIndexLayout);

      cacheSizes.clear();
      _cacheSizes = null;

      //重新寻找
      _gestureDirection = GestureDirection.forward;
      //需要将位置清空重新计算
      _firstVisibleIndex = null;
      _lastVisibleIndex = null;
      _nearCenterVisibleIndex = null;

      final ScrollMetrics scrollMetrics =
          _scrollController?.position ?? _scrollMetrics!;
      _update(scrollMetrics, sync: true);
    });
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

  _nearCenterIndexComputer(double pixels, double viewportDimension) {
    double? bestNearPosition;
    return (int index) {
      final centerBaselinePosition = pixels + viewportDimension / 2;
      final ComputedSize computedSize = _getComputedSize(index);
      final nearPosition =
          (computedSize.centerPosition - centerBaselinePosition).abs();
      print("start computer#$index=> centerBaselinePosition:$centerBaselinePosition, nearPosition: $nearPosition, pixels:$pixels, viewportDimension: $viewportDimension");
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

    _scrollMetrics = metrics;
    _currentPosition ??= 0;
    final double oldPosition = _currentPosition!;
    _gestureDirection = pixels == oldPosition
        ? null
        : (pixels > oldPosition
            ? GestureDirection.forward
            : GestureDirection.backward);
    _currentPosition = pixels;

    _firstVisibleIndex ??= 0;
    if (_nearCenterVisibleIndex == null || _lastVisibleIndex == null) {
      _initCenterAndLastVisibleIndex(
          _firstVisibleIndex!, pixels, viewportDimension);
      assert(_nearCenterVisibleIndex != null);
      assert(_lastVisibleIndex != null);
    }

    if (_gestureDirection != null) {
      final nearCenterIndexComputer =
          _nearCenterIndexComputer(pixels, viewportDimension);

      _firstVisibleIndex = _findVisibleIndex(
          _firstVisibleIndex!, pixels, viewportDimension, maxScrollExtent,
          reverse: false);
      _lastVisibleIndex = _findVisibleIndex(
          _lastVisibleIndex!, pixels, viewportDimension, maxScrollExtent,
          reverse: true);
      print("!!!!!computerCenterIndex: CenterIndex=>$_nearCenterVisibleIndex");
      _nearCenterVisibleIndex = _findVisibleIndex(
          _nearCenterVisibleIndex!, pixels, viewportDimension, maxScrollExtent,
          otherCondition: nearCenterIndexComputer);
      print("_nearCenterVisibleIndex: =>=>=>$_nearCenterVisibleIndex");
    }
  }

  void _clearData() {
    _gestureDirection = null;
    _firstVisibleIndex = null;
    _lastVisibleIndex = null;
    _nearCenterVisibleIndex = null;
    _currentPosition = null;
    _onUpdate = null;
    _scrollController = null;
    _minIndexLayout = null;
    _maxIndexLayout = null;
    _cacheSizes?.clear();
    _cacheSizes = null;
  }

  Widget buildList(
      {required ScrollView child,
      OnUpdate? onUpdate,
      OnScrollStart? onScrollStart,
      OnScrollUpdate? onScrollUpdate,
      OnScrollEnd? onScrollEnd}) {
    _clearData();
    if (_axis != child.scrollDirection) {
      _axis = child.scrollDirection;
      _clearSizes();
    }

    if (child.controller != null) {
      _scrollController = child.controller;
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        final ScrollPosition position = child.controller!.position;
        assert(position.hasViewportDimension);
        _update(position);
      });
    }
    _onUpdate = onUpdate;
    return NotificationListener(
      onNotification: (Notification notification) {
        if (notification is ScrollStartNotification) {
          _updateScrollData(notification.metrics);
          onScrollStart?.call(_scrollDataInterface!);
        } else if (notification is ScrollUpdateNotification) {
          _updateScrollData(notification.metrics);
          onScrollUpdate?.call(_scrollDataInterface!);
        } else if (notification is ScrollEndNotification) {
          _updateScrollData(notification.metrics);
          onScrollEnd?.call(_scrollDataInterface!);
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
    if (index > 0) {
      final preSize = _sizes![index - 1].size;
      _updateHeightByLayout(index, preSize, true);
    }
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

  void dispose() {
    _clearSizes();
    _sizes = null;
  }

  void _updateHeightByLayout(int index, double size, bool alignPosition) {
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
      final oldComputedSize = _sizes![index];
      if (oldComputedSize != newComputedSize) {
        _sizes![index] = newComputedSize;
        print("update==> index: $index => newComputedSize: $newComputedSize, oldComputedSize: $oldComputedSize, alignPosition: $alignPosition");
      }

      if (alignPosition) {
        //对齐位置
        final length = _getSizeLength();
        ComputedSize afterComputedSize = newComputedSize;
        while (++index < length) {
          afterComputedSize = _sizes![index].copyWith(
              position: afterComputedSize.position + afterComputedSize.size);
          print("update==> index: $index => newComputedSize: $afterComputedSize, oldComputedSize: ${_sizes![index]}, alignPosition: $alignPosition");
          _sizes![index] = afterComputedSize;
        }
      }
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
    super.dispose();
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

  ComputedSize copyWith({int? index, double? size, double? position}) {
    return ComputedSize._(
        index ?? this.index, size ?? this.size, position ?? this.position);
  }

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
