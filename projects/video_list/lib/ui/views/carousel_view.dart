import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_list/ui/views/widgets/sliver.dart';
import 'widgets/custom_pageview.dart';

class CarouselView extends StatefulWidget {
  CarouselView.custom(
      {Key key,
      this.scrollDirection = Axis.horizontal,
      this.childrenDelegate,
      this.reverse = false,
      this.physics,
      this.pageSnapping = true,
      this.dragStartBehavior = DragStartBehavior.start,
      this.clipBehavior = Clip.hardEdge,
      this.allowImplicitScrolling = false,
      this.restorationId,
      this.controller,
      this.autoPlayDelay,
      this.autoPlay = true,
      this.onPageChanged,
      this.onHandUpChanged,
      this.padding = 0.0,
      this.loop = true,
      this.scale = 1.0,
      this.initViewportFraction = 1.0,
      this.duration,
      this.curve})
      : assert(reverse != null),
        assert(scrollDirection != null),
        assert(autoPlay != null),
        assert(loop != null),
        assert(scale != null),
        assert(initViewportFraction != null),
        assert(childrenDelegate != null),
        assert(allowImplicitScrolling != null),
        assert(clipBehavior != null),
        super(key: key);

  CarouselView.builder(
      {Key key,
      this.scrollDirection = Axis.horizontal,
      IndexedWidgetBuilder itemBuilder,
      int itemCount,
      this.reverse = false,
      this.physics,
      this.pageSnapping = true,
      this.dragStartBehavior = DragStartBehavior.start,
      this.clipBehavior = Clip.hardEdge,
      this.allowImplicitScrolling = false,
      this.restorationId,
      this.controller,
      this.autoPlayDelay,
      this.autoPlay = true,
      this.onPageChanged,
      this.onHandUpChanged,
      this.padding = 0.0,
      this.loop = true,
      this.scale = 1.0,
      this.initViewportFraction = 1.0,
      this.duration,
      this.curve})
      : assert(reverse != null),
        assert(scrollDirection != null),
        assert(autoPlay != null),
        assert(loop != null),
        assert(scale != null),
        assert(initViewportFraction != null),
        assert(allowImplicitScrolling != null),
        assert(clipBehavior != null),
        childrenDelegate = CustomSliverChildBuilderDelegate(itemBuilder,
            childCount: itemCount),
        super(key: key);

  CarouselView(
      {Key key,
      this.scrollDirection = Axis.horizontal,
      List<Widget> children = const <Widget>[],
      this.reverse = false,
      this.physics,
      this.pageSnapping = true,
      this.dragStartBehavior = DragStartBehavior.start,
      this.clipBehavior = Clip.hardEdge,
      this.allowImplicitScrolling = false,
      this.restorationId,
      this.controller,
      this.autoPlayDelay,
      this.autoPlay = true,
      this.onPageChanged,
      this.onHandUpChanged,
      this.padding = 0.0,
      this.loop = true,
      this.scale = 1.0,
      this.initViewportFraction = 1.0,
      this.duration,
      this.curve})
      : assert(children != null),
        assert(reverse != null),
        assert(scrollDirection != null),
        assert(autoPlay != null),
        assert(loop != null),
        assert(scale != null),
        assert(initViewportFraction != null),
        childrenDelegate = CustomSliverChildListDelegate(children),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _CarouselViewState();

  final CustomSliverChildDelegate childrenDelegate;

  final CarouselController controller;

  ///单位毫秒
  final int autoPlayDelay;

  ///页的改变
  final ValueChanged<int> onPageChanged;

  ///页的改变，手指抬起的瞬间
  final ValueChanged<int> onHandUpChanged;

  final int duration;

  final Curve curve;

  final double padding;

  final Axis scrollDirection;

  final bool reverse;

  final ScrollPhysics physics;

  final bool pageSnapping;

  final DragStartBehavior dragStartBehavior;

  final Clip clipBehavior;

  final bool allowImplicitScrolling;

  final String restorationId;

  final bool autoPlay;

  final bool loop;

  final double scale;

  final double initViewportFraction;
}

const int _defaultAutoPlayDelay = 5000;
const Curve _defaultCurve = Curves.ease;
const Duration _defaultDuration = Duration(milliseconds: 500);

class _CarouselViewState extends State<CarouselView> {
  Timer _autoPlayTimer; //定时器

  CarouselController _controller;
  ValueNotifier<double> _valueNotifier = new ValueNotifier<double>(0.0);

  int _lastReportedPage = 0;
  int _lastHandUpReportedPage = 0;
  bool _hasHandUpHandle = false;

  @override
  void didUpdateWidget(CarouselView oldWidget) {
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller.removeListener(_onEvent);
        oldWidget.controller.dispose();
      }

      _initController();
      _handleAutoPlay();
    }

    super.didUpdateWidget(oldWidget);
  }

  bool _autoPlayEnabled() {
    return _controller.autoPlay;
  }

  void _handleAutoPlay() {
    if (!_canScroll) return;

    if (_autoPlayEnabled() && _autoPlayTimer != null) return;
    _stopAutoPlay();
    if (_autoPlayEnabled()) {
      _startAutoPlay();
    }
  }

  void _onEvent() {
    switch (_controller.event) {
      case CarouselController.EVENT_AUTO_PLAY:
        // print("######page自动播放事件: ${_controller.page}");
        if (!_canScroll) return;
        if (_controller.autoPlay) {
          if (_autoPlayTimer == null) {
            _startAutoPlay();
          }
        } else {
          if (_autoPlayTimer != null) {
            _stopAutoPlay();
          }
        }
        break;

      case CarouselController.EVENT_SCROLL:
        // print("######page滚动事件: ${_controller.page}");
        _valueNotifier.value = _controller.page;
        break;
    }
  }

  int _getRealIndex(int index) =>
      widget.loop ? (index - 2) % _realItemCount : index;

  void _initController() {
    //widget.reverse ? 9 : 2;
    _controller = widget.controller ??
        new CarouselController(
          initialPage:
              widget.loop ? (widget.reverse ? _realItemCount + 2 : 2) : 0,
          initialAutoPlay: widget.autoPlay,
          scale: widget.scale,
          viewportFraction: widget.initViewportFraction,
        );
    _valueNotifier.value = _controller.initialPage * 1.0;
    _lastReportedPage = _getRealIndex(_controller.initialPage);
    _lastHandUpReportedPage = _lastReportedPage;
    _controller.removeListener(_onEvent);
    _controller.addListener(_onEvent);
  }

  void _disposeController() {
    _controller.removeListener(_onEvent);
    _controller.dispose();
  }

  //int get _realItemCount => widget.childCount;

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
    _handleAutoPlay();
  }

  @override
  void dispose() {
    _disposeController();
    _stopAutoPlay();
    super.dispose();
  }

  void _startAutoPlay() {
    assert(_autoPlayTimer == null, "Timer must be stopped before start!");
    _autoPlayTimer = Timer.periodic(
        Duration(milliseconds: widget.autoPlayDelay ?? _defaultAutoPlayDelay),
        _onTimer);
  }

  void _onTimer(Timer timer) {
    // _controller.next(animation: true);
    _controller.nextPage(
        duration: widget.duration ?? _defaultDuration,
        curve: widget.curve ?? _defaultCurve);
  }

  void _stopAutoPlay() {
    if (_autoPlayTimer != null) {
      _autoPlayTimer.cancel();
      _autoPlayTimer = null;
    }
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
  bool _notificationNeedAutoPlay = false;
  List<int> _downPointers = [];

  @override
  Widget build(BuildContext context) {
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
                if (_controller.autoPlay) {
                  _notificationNeedAutoPlay = true;
                  _controller.stopAutoPlay();
                }
              }
            } else if (notification is ScrollEndNotification) {
              if (_notificationStartTag) {
                _notificationStartTag = false;
                final int currentPage = _controller.page.round();
                print(
                    "00000ScrollEndNotification##currentPage: $currentPage, page: ${_controller.page}");
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
              if (_notificationNeedAutoPlay) {
                _notificationNeedAutoPlay = false;
                _controller.startAutoPlay();
              }

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
            physics: widget.physics,
            pageSnapping: widget.pageSnapping,
            dragStartBehavior: widget.dragStartBehavior,
            allowImplicitScrolling: widget.allowImplicitScrolling,
            restorationId: widget.restorationId,
            clipBehavior: widget.clipBehavior,
            childrenDelegate: SliverChildBuilderDelegateWithSameIndex(
              widget.childrenDelegate,
              childCount: widget.loop ? _realItemCount + 4 : _realItemCount,
              findRealIndex: (int index) => _getRealIndex(index),
              builder: (BuildContext context, int index, int realIndex,
                  Widget child) {
                return Consumer<ValueNotifier<double>>(
                  builder: (BuildContext context,
                      ValueNotifier<double> notifier, Widget wgt) {
                    final int currentIndex = notifier.value.round();

                    final double scale = widget.scale;

                    double scaleVal = 1.0;

                    if (index != currentIndex) {
                      double _needValue = (currentIndex - notifier.value).abs();
                      if (_needValue >= 0 && _needValue < 0.5) {
                        scaleVal = _needValue * 2 * (1 - scale) + scale;
                      } else {
                        scaleVal = scale;
                      }
                    }

                    print(
                        "log###realIndex: $realIndex, index: $index, notifier.value: ${notifier.value}, currentIndex: $currentIndex scaleVal: $scaleVal");
                    return Padding(
                      padding: widget.scrollDirection == Axis.vertical
                          ? EdgeInsets.symmetric(vertical: widget.padding)
                          : EdgeInsets.symmetric(horizontal: widget.padding),
                      child: Transform.scale(
                        scale: scaleVal,
                        alignment: _getAlignmentReferAxis(
                            widget.scrollDirection,
                            widget.reverse,
                            index,
                            currentIndex),
                        child: child,
                      ),
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

class CarouselController extends CustomPageController {
  bool _autoPlay;

  bool get autoPlay => _autoPlay ?? initialAutoPlay;

  /// The action to auto play when first creating the [CarouselView].
  final bool initialAutoPlay;

  static const int EVENT_SCROLL = 0;

  static const int EVENT_AUTO_PLAY = 1;

  int _event;

  int get event => _event ?? EVENT_SCROLL;

  /*this.initialPage = 0,
  this.keepPage = true,
  this.viewportFraction = 1.0,*/

  CarouselController({
    this.initialAutoPlay = false,
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    double scale = 1.0,
  }) : super(
            initialPage: initialPage,
            keepPage: keepPage,
            viewportFraction: viewportFraction);

  void startAutoPlay() {
    _handleAutoPlay(true);
  }

  void stopAutoPlay() {
    _handleAutoPlay(false);
  }

  void _handleAutoPlay(bool autoPlay) {
    if (this.autoPlay == autoPlay)
      return;
    _autoPlay = autoPlay;
    _sendEventAndRestore(EVENT_AUTO_PLAY);
  }

  void _sendEventAndRestore(int newEvent) {
    final int oldEvent = _event;
    //send event
    _event = newEvent;
    notifyListeners();

    //restore event
    _event = oldEvent;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
