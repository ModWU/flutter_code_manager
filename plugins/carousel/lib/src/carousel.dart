import 'dart:async';
import 'package:carousel/carousel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_pageview.dart';

const int _defaultAutoPlayDelay = 5000;
const Curve _defaultCurve = Curves.ease;
const Duration _defaultDuration = Duration(milliseconds: 500);
typedef TransformBuilder = Widget Function(BuildContext context, int index,
    double page, double viewportMainAxisExtent, Widget child);

class CarouselView extends StatefulWidget {
  CarouselView.custom({
    Key key,
    this.scale = 1.0,
    this.scrollDirection = Axis.horizontal,
    this.childrenDelegate,
    this.reverse = false,
    this.padEnds = true,
    this.loop = true,
    this.padEndsViewportFraction,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.controller,
    this.onPageChanged,
    this.onHandUpChanged,
    this.transformBuilder,
  })  : assert(reverse != null),
        assert(padEnds != null),
        assert(loop != null),
        assert(
            padEndsViewportFraction == null || padEndsViewportFraction >= 0.0),
        assert(scrollDirection != null),
        assert(childrenDelegate != null),
        assert(allowImplicitScrolling != null),
        assert(clipBehavior != null),
        super(key: key);

  CarouselView.builder({
    Key key,
    this.scale = 1.0,
    this.scrollDirection = Axis.horizontal,
    IndexedWidgetBuilder itemBuilder,
    int itemCount,
    this.reverse = false,
    this.padEnds = true,
    this.loop = true,
    this.padEndsViewportFraction,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.controller,
    this.onPageChanged,
    this.onHandUpChanged,
    this.transformBuilder,
  })  : assert(scale != null),
        assert(reverse != null),
        assert(padEnds != null),
        assert(loop != null),
        assert(
            padEndsViewportFraction == null || padEndsViewportFraction >= 0.0),
        assert(scrollDirection != null),
        assert(allowImplicitScrolling != null),
        assert(clipBehavior != null),
        childrenDelegate = CustomSliverChildBuilderDelegate(itemBuilder,
            childCount: itemCount),
        super(key: key);

  CarouselView({
    Key key,
    this.scale = 1.0,
    this.scrollDirection = Axis.horizontal,
    List<Widget> children = const <Widget>[],
    this.reverse = false,
    this.padEnds = true,
    this.loop = true,
    this.padEndsViewportFraction,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.controller,
    this.onPageChanged,
    this.onHandUpChanged,
    this.transformBuilder,
  })  : assert(scale != null),
        assert(children != null),
        assert(reverse != null),
        assert(padEnds != null),
        assert(loop != null),
        assert(
            padEndsViewportFraction == null || padEndsViewportFraction >= 0.0),
        assert(scrollDirection != null),
        childrenDelegate = CustomSliverChildListDelegate(children),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _CarouselViewState();

  final CustomSliverChildDelegate childrenDelegate;

  final CarouselController controller;

  ///页的改变
  final ValueChanged<int> onPageChanged;

  ///页的改变，手指抬起的瞬间
  final ValueChanged<int> onHandUpChanged;

  final Axis scrollDirection;

  final bool reverse;

  final ScrollPhysics physics;

  final bool pageSnapping;

  final DragStartBehavior dragStartBehavior;

  final Clip clipBehavior;

  final bool allowImplicitScrolling;

  final String restorationId;

  final bool padEnds;

  final bool loop;

  final double padEndsViewportFraction;

  final double scale;

  final TransformBuilder transformBuilder;
}

class _CarouselViewState extends State<CarouselView> {
  CarouselController _controller;
  ValueNotifier<double> _valueNotifier = new ValueNotifier<double>(0.0);

  int _lastReportedPage = 0;
  int _lastHandUpReportedPage = 0;
  bool _hasHandUpHandle = false;

  @override
  void didUpdateWidget(CarouselView oldWidget) {
    print("loglog##didUpdateWidget:::::");

    if (widget != oldWidget) {
      final int childCount = _childCount;
      if (_controller._childCount != childCount) {
        _controller._childCount = childCount;
      }

      if ((widget.controller != oldWidget.controller)) {
        _initController(oldWidget: oldWidget);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void _onScrollEvent() {
    _valueNotifier.value = _controller.page;
  }

  int _getRealIndex(int index) =>
      widget.loop ? (index - 2) % _realItemCount : index;

  int _getFitRealIndex(int index) {
    if (widget.loop) return index;
    return (index - 2) % _realItemCount;
  }

  int _getFitIndex(int realIndex) {
    if (!widget.loop) return realIndex;

    final int realItemCount = _realItemCount;
    if (realIndex < 0) realIndex = 0;
    if (realIndex >= realItemCount) realIndex = realItemCount - 1;

    return realIndex + 2;
  }

  int _getInitialPage(CarouselView oldView, CarouselController oldController) {
    assert(oldView != null);
    assert(oldController != null);
    if ((oldController.position?.hasViewportDimension) ?? false) {
      final int oldCurrentPage = oldController.page.round();

      if (widget.loop) {
        return oldView.loop
            ? oldCurrentPage.clamp(0, _childCount)
            : _getFitIndex(oldCurrentPage);
      } else {
        return !oldView.loop
            ? oldCurrentPage.clamp(0, _childCount)
            : _getFitRealIndex(oldCurrentPage);
      }
    }

    return null;
  }

  void _initController({CarouselView oldWidget}) {
    print("loglog##_initController:::::");
    final CarouselController oldController = _controller;

    _controller = widget.controller ?? _DefaultCarouselController();

    _controller
      .._initialPage = _getFitIndex(_controller.initialPage)
      .._childCount = _childCount;

    bool needInitialValue = true;

    if (oldController != null &&
        oldWidget != null &&
        oldController != _controller) {
      final int oldPage = _getInitialPage(oldWidget, oldController);
      if (oldPage != null) {
        needInitialValue = false;
        //_valueNotifier.value = oldPage * 1.0;
        WidgetsBinding.instance.addPostFrameCallback((callback) {
          _valueNotifier.value = oldPage * 1.0;
          _controller.jumpToPage(oldPage);
        });
      }

      if (oldController is _DefaultCarouselController) {
        print("_controller._initialPage oldPage: $oldPage");
        oldController.removeListener(_onScrollEvent);
        oldController.dispose();
      }
    }

    if (needInitialValue) {
      _valueNotifier.value = _controller.initialPage * 1.0;
      _lastReportedPage = _getRealIndex(_controller.initialPage);
      _lastHandUpReportedPage = _lastReportedPage;
    }

    _controller.addListener(_onScrollEvent);

    _controller._initAutoPlay();
  }

  void _disposeController() {
    _controller.removeListener(_onScrollEvent);
    _controller.dispose();
  }

  int get _childCount => widget.loop ? _realItemCount + 4 : _realItemCount;

  int get _realItemCount {
    int result = widget.childrenDelegate.estimatedChildCount;
    if (result == null) {
      int lo = 0;
      int hi = 1;
      const int max = kIsWeb ? 9007199254740992 : ((1 << 63) - 1);
      while (widget.childrenDelegate.build(context, hi - 1) != null) {
        lo = hi - 1;
        if (hi < max ~/ 2) {
          hi *= 2;
        } else if (hi < max) {
          hi = max;
        } else {
          throw FlutterError(
              'Could not find the number of children in ${widget.childrenDelegate}.\n'
              'The childCount getter was called (implying that the delegate\'s builder returned null '
              'for a positive index), but even building the child with index $hi (the maximum '
              'possible integer) did not return null. Consider implementing childCount to avoid '
              'the cost of searching for the final child.');
        }
      }
      while (hi - lo > 1) {
        final int mid = (hi - lo) ~/ 2 + lo;
        if (widget.childrenDelegate.build(context, mid - 1) == null) {
          hi = mid;
        } else {
          lo = mid;
        }
      }
      result = lo;
    }
    return result;
  }

  bool get _canScroll =>
      _realItemCount > 1 || (_realItemCount == 1 && widget.loop);

  @override
  void initState() {
    super.initState();
    _initController();
    // _valueNotifier.value = _controller.initialPage * 1.0;
  }

  @override
  void dispose() {
    print("##################66666666666666666dispose");
    if (widget.controller == null) {
      _disposeController();
    } else {
      _controller.stopAutoPlay();
    }
    super.dispose();
  }

  Widget _transformChild(
      int index, double page, Widget child, BoxConstraints constraints) {
    final int currentIndex = page.round();
    final double scale = widget.scale;

    double scaleVal = 1.0;

    if (index != currentIndex) {
      double _needValue = (currentIndex - page).abs();
      if (_needValue >= 0 && _needValue < 0.5) {
        scaleVal = _needValue * 2 * (1 - scale) + scale;
      } else {
        scaleVal = scale;
      }
    }

    final double mainAxisMaxValue = widget.scrollDirection == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;

    final double viewportMainAxisExtent =
        mainAxisMaxValue / _controller.viewportFraction;

    /*final double translateVal =
        ((viewportMainAxisExtent - mainAxisMaxValue) * 0.5) *
            (widget.reverse ? 1.0 : -1.0);

    print("##max: viewportMainAxisExtent: $viewportMainAxisExtent");*/

    final Widget transformChild = Transform.scale(
            scale: scaleVal,
            alignment: _getAlignmentReferAxis(
                widget.scrollDirection, widget.reverse, index, currentIndex),
            transformHitTests: true,
            child: child,
          );

    return widget.transformBuilder
            ?.call(context, index, page, viewportMainAxisExtent, child) ??
        transformChild;
  }

  Alignment _getAlignmentReferAxis(
      Axis axis, bool reverse, int widgetIndex, int currentIndex) {
    if (widgetIndex == currentIndex) return Alignment.center;

    final bool isLtCurrentIndex = widgetIndex < currentIndex;
    final bool isRightOrTop =
        (!reverse && isLtCurrentIndex) || (reverse && !isLtCurrentIndex);

    switch (axis) {
      case Axis.horizontal:
        return isRightOrTop ? Alignment.centerRight : Alignment.centerLeft;

      case Axis.vertical:
        return isRightOrTop ? Alignment.topCenter : Alignment.bottomCenter;
    }

    return Alignment.center;
  }

  bool _notificationStartTag = false;
  List<int> _downPointers = [];

  @override
  Widget build(BuildContext context) {
    print("build build build: ${_controller.viewportFraction}");
    return ChangeNotifierProvider.value(
      value: _valueNotifier,
      child: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (_canScroll && notification.depth == 0) {
            if (notification is ScrollStartNotification) {
              _notificationStartTag = true;
              print(
                  "00000ScrollStartNotification##_controller.page: ${_controller.page}");
              if (notification.dragDetails != null) {
                //by human
                _controller.blocked();
              }
            } else if (notification is ScrollEndNotification) {
              if (_notificationStartTag) {
                _notificationStartTag = false;
                final double page = _controller.page;
                final int currentPage = page.round();
                print(
                    "00000ScrollEndNotification##currentPage: $currentPage, page: $page");
                /* double initOffset = _controller.page - currentPage;
                if (initOffset.abs() < precisionErrorTolerance)
                  initOffset = 0;*/
                if (widget.loop) {
                  if (currentPage == 1) {
                    _controller.jumpToPage(_realItemCount + 1);
                  } else if (currentPage == 2 + _realItemCount) {
                    _controller.jumpToPage(2);
                  } else if (currentPage == 0) {
                    _controller.jumpToPage(_realItemCount);
                  } else if (currentPage == 3 + _realItemCount) {
                    _controller.jumpToPage(3);
                  }
                }
              }
              print("pageStartEnd##ScrollEndNotification:_startTag: ");
              _controller.unblocked();

              if (!_hasHandUpHandle) {
                if (widget.onHandUpChanged != null) {
                  final int currentPage = _controller.page.round();
                  final int currentRealPage = _getRealIndex(currentPage);
                  if (currentRealPage != _lastHandUpReportedPage) {
                    _lastHandUpReportedPage = currentRealPage;
                    widget.onHandUpChanged(currentRealPage);
                  }
                }
              }

              _hasHandUpHandle = false;
            } else if (notification is ScrollUpdateNotification) {
              print(
                  "ScrollUpdateNotification####_controller page: ${_controller.page}");
              if (widget.onPageChanged != null) {
                final CustomPageMetrics metrics =
                    notification.metrics as CustomPageMetrics;
                final int currentPage = metrics.page.round();
                final int currentRealPage = _getRealIndex(currentPage);
                if (currentRealPage != _lastReportedPage) {
                  _lastReportedPage = currentRealPage;
                  widget.onPageChanged(currentRealPage);
                }
              }
            }
          }
          return false;
        },
        child: Listener(
          onPointerDown: (PointerDownEvent event) {
            print("1######onPointerDown: ${event.pointer}");
            int pointer = event.pointer;
            _downPointers.add(pointer);
            _hasHandUpHandle = false;
          },
          onPointerCancel: (PointerCancelEvent event) {
            print("1######onPointerCancel: ${event.pointer}");
            _downPointers.remove(event.pointer);
            _hasHandUpHandle = false;
          },
          onPointerHover: (PointerHoverEvent event) {
            print("1######onPointerHover: ${event.pointer}");
          },
          onPointerUp: (PointerUpEvent event) {
            print("1######onPointerUp: ${event.pointer}");
            _downPointers.remove(event.pointer);

            if (_downPointers.isEmpty &&
                _notificationStartTag &&
                widget.onHandUpChanged != null) {
              final int currentPage = _controller.page.round();
              final int currentRealPage = _getRealIndex(currentPage);
              if (currentRealPage != _lastHandUpReportedPage) {
                _lastHandUpReportedPage = currentRealPage;
                widget.onHandUpChanged(currentRealPage);
                _hasHandUpHandle = true;
              }
            }
          },
          child: CustomPageView.custom(
            controller: _controller,
            scrollDirection: widget.scrollDirection,
            reverse: widget.reverse,
            padEnds: widget.padEnds,
            padEndsViewportFraction: widget.padEndsViewportFraction,
            //physics: _physics,//CustomScrollPhysics(itemDimension: 0),//_physics,//widget.physics,
            pageSnapping: widget.pageSnapping,
            dragStartBehavior: widget.dragStartBehavior,
            allowImplicitScrolling: widget.allowImplicitScrolling,
            restorationId: widget.restorationId,
            clipBehavior: widget.clipBehavior,
            childrenDelegate: SliverChildBuilderDelegateWithSameIndex(
              widget.childrenDelegate,
              childCount: _childCount,
              findRealIndex: _getRealIndex,
              builder: (BuildContext context, int index, int realIndex,
                  Widget child) {
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Consumer<ValueNotifier<double>>(
                      builder: (BuildContext context,
                          ValueNotifier<double> notifier, Widget wgt) {
                        print(
                            "log###realIndex: $realIndex, index: $index, notifier.value: ${notifier.value}");
                        return _transformChild(
                            index, notifier.value, child, constraints);
                      },
                    );
                  },
                );
              },
              findChildSameIndexCallback: () {
                return widget.loop
                    ? <int, int>{
                        0: _realItemCount,
                        1: _realItemCount + 1,
                        2: _realItemCount + 2,
                        3: _realItemCount + 3,
                      }
                    : null;
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultCarouselController extends CarouselController {}

class CarouselController extends CustomPageController {
  Timer _autoPlayTimer; //定时器

  bool _autoPlay;

  @nonVirtual
  bool get autoPlay => _autoPlay;

  int _autoPlayDelay;

  Duration _duration;

  Curve _curve;

  //默认锁住
  int _blockObjSum = 0;

  int _initialPage;

  bool _keepPage;

  int _childCount;

  double _viewportFraction;

  @override
  int get initialPage => _initialPage;

  @override
  bool get keepPage => _keepPage;

  @override
  double get viewportFraction => _viewportFraction;

  @nonVirtual
  bool get isBlocked => _blockObjSum > 0;

  bool _init = false;

  set autoPlayDelay(int value) {
    if (value == _autoPlayDelay) return;
    _autoPlayDelay = value;
  }

  set duration(Duration value) {
    if (value == _duration) return;
    _duration = value;
  }

  set curve(Curve value) {
    if (value == _curve) return;
    _curve = value;
  }

  CarouselController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    bool autoPlay = false,
    int autoPlayDelay = _defaultAutoPlayDelay,
    Duration duration = _defaultDuration,
    Curve curve = _defaultCurve,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        assert(autoPlay != null),
        assert(autoPlayDelay != null),
        assert(duration != null),
        assert(curve != null),
        _initialPage = initialPage,
        _keepPage = keepPage,
        _viewportFraction = viewportFraction,
        _autoPlayDelay = autoPlayDelay,
        _duration = duration,
        _autoPlay = autoPlay,
        _curve = curve;

  @nonVirtual
  void startAutoPlay() {
    handleAutoPlay(true);
  }

  @nonVirtual
  void stopAutoPlay() {
    handleAutoPlay(false);
  }

  @nonVirtual
  void blocked() {
    //还没有对象锁住时
    if (_blockObjSum == 0) {
      if (autoPlay) _stopAutoPlay();
    }

    _blockObjSum++;
  }

  @nonVirtual
  void unblocked() {
    //当最后一个对象进行解锁时
    if (_blockObjSum == 1) {
      if (autoPlay) _startAutoPlay();
    }

    if (_blockObjSum > 0) _blockObjSum--;
  }

  void _initAutoPlay() {
    _init = true;
    if (autoPlay && _autoPlayTimer == null) {
      _startAutoPlay();
    }
  }

  @nonVirtual
  void handleAutoPlay(bool autoPlay) {
    if (this.autoPlay == autoPlay) return;

    _autoPlay = autoPlay;
    print(
        "handleAutoPlay: init: $_init, isBlocked: $isBlocked, autoPlay: $autoPlay");
    if (!_init || isBlocked) return;

    if (autoPlay) {
      _startAutoPlay();
    } else {
      _stopAutoPlay();
    }
  }

  void _startAutoPlay() {
    assert(_autoPlayTimer == null, "Timer must be stopped before start!");
    _autoPlayTimer = Timer.periodic(
        Duration(milliseconds: _autoPlayDelay ?? _defaultAutoPlayDelay),
        _onTimer);
  }

  void _onTimer(Timer timer) {
    if (positions.isNotEmpty) {
      animateToPage((page.round() + 1) % _childCount,
          duration: _duration ?? _defaultDuration,
          curve: _curve ?? _defaultCurve);
    }
  }

  void _stopAutoPlay() {
    if (_autoPlayTimer != null) {
      _autoPlayTimer.cancel();
      _autoPlayTimer = null;
    }
  }

  @override
  void dispose() {
    while (isBlocked) {
      unblocked();
    }
    stopAutoPlay();
    super.dispose();
  }
}
