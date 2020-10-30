import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_list/ui/utils/controller_notifier.dart';
import 'package:video_list/ui/views/widgets/sliver.dart';

import 'widgets/custom_pageview.dart';

class CarouselView extends StatefulWidget {
  CarouselView(
      {this.itemBuilder,
      this.itemCount,
      this.controller,
      this.autoPlayDelay,
      this.onPageChanged,
      this.duration,
      this.curve});

  @override
  State<StatefulWidget> createState() => _CarouselViewState();

  final IndexedWidgetBuilder itemBuilder;

  final CarouselController controller;

  final int itemCount;

  ///单位毫秒
  final int autoPlayDelay;

  ///也的改变
  final ValueChanged<int> onPageChanged;

  final int duration;

  final Curve curve;
}

const int _defaultAutoPlayDelay = 5000;
const Curve _defaultCurve = Curves.ease;
const Duration _defaultDuration = Duration(milliseconds: 500);

class _CarouselViewState extends State<CarouselView> {
  Timer _autoPlayTimer; //定时器

  CarouselController _controller;

  GlobalObjectKey firstChildKey = GlobalObjectKey("first");
  GlobalObjectKey childChildKey = GlobalObjectKey("last");


  @override
  void didUpdateWidget(CarouselView oldWidget) {
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null)
        oldWidget.controller.removeListener(_onEvent);

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
    }
  }

  void _initController() {
    _controller?.dispose();
    _controller = widget.controller ?? new CarouselController();
    _controller.addListener(_onEvent);
  }

  void _disposeController() {
    _controller.removeListener(_onEvent);
    _controller.dispose();
  }

  int get _realItemCount => widget?.itemCount ?? 0;

  bool get _canScroll => _realItemCount > 1;

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

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (_canScroll && notification is ScrollEndNotification) {
          print(
              "wuchaochao => ${notification.metrics.axis == Axis.horizontal ? "水平滚动：" : "垂直滚动："}{ScrollUpdateNotification:${notification is ScrollUpdateNotification}, ScrollEndNotification:${notification is ScrollEndNotification}, ScrollStartNotification:${notification is ScrollStartNotification}, extentInside:${notification.metrics.extentInside}, extentBefore:${notification.metrics.extentBefore}, atEdge:${notification.metrics.atEdge}, axisDirection:${notification.metrics.axisDirection}, hasViewportDimension:${notification.metrics.hasViewportDimension}, viewportDimension:${notification.metrics.viewportDimension}, hasPixels:${notification.metrics.hasPixels}, hasContentDimensions:${notification.metrics.hasContentDimensions}, pixels:${notification.metrics.pixels}，outOfRange:${notification.metrics.outOfRange}，minScrollExtent:${notification.metrics.minScrollExtent}，maxScrollExtent:${notification.metrics.maxScrollExtent}");

          final CustomPageMetrics metrics =
              notification.metrics as CustomPageMetrics;
          final int currentPage = metrics.page.round();
          if (currentPage == 0) {
            // _controller.jumpToPage(1);
          } else if (currentPage == _realItemCount + 1) {
            //  _controller.jumpToPage(1);
          }
        }
        return false;
      },
      child: CustomPageView.custom(
        //physics: const BouncingScrollPhysics(),
        loop: true,
        onPageChanged: (index) {
          /*if (index == 0 || index == _realItemCount + 1) {
            return;
          }*/

          widget?.onPageChanged?.call(index);
        },
        controller: _controller,
        childrenDelegate: SliverChildBuilderDelegateWithSameIndex(
          (BuildContext context, int index) {
            print("....当前页：${index} ${_realItemCount}");

            if (index == 0) {
              return widget.itemBuilder(context, _realItemCount - 1);
            } else if (index == _realItemCount + 1) {
              return widget.itemBuilder(context, 0);
            }

            return widget.itemBuilder(context, index - 1);

          /*  if (index == 0) {
              //return widget.itemBuilder(context, _realItemCount - 1);
              return KeepAlive(
                child: KeepAlive2(
                  child: widget.itemBuilder(context, _realItemCount - 1),
                  key: ValueKey<int>(_realItemCount - 1),
                ),
                  keepAlive: true,
               //key: ValueKey<int>(_realItemCount - 1),
              );
            } else if (index == _realItemCount + 1) {
              //return widget.itemBuilder(context, 0);
              return KeepAlive(
                child: KeepAlive2(
                  child: widget.itemBuilder(context, 0),
                  key: ValueKey<int>(0),
                ),
                keepAlive: true,
                //key: ValueKey<int>(0),
              );
            }

            return KeepAlive(
              child: KeepAlive2(
                child:  widget.itemBuilder(context, index - 1),
                key: ValueKey<int>(index - 1),
              ),
              keepAlive: true,
              //key: ValueKey<int>(index - 1),
            );*/
          },
          findChildSameIndexCallback: (index) {
            if (_realItemCount < 2)
              return null;

            if (index == 0) {
              return _realItemCount;
            }

            if (index == _realItemCount + 1) {
              return 1;
            }

            if (index == _realItemCount) {
              return 0;
            }

            if (index == 1) {
              return _realItemCount + 1;
            }

            return null;
          },
          /*findChildIndexCallback: (Key key) {
            final ValueKey valueKey = key;
            final int index = valueKey.value;
            if (index == 0) {
              return _realItemCount;
            } else if (index == _realItemCount + 1) {
              return 1;
            }


            return index;
          },*/
          childCount: _realItemCount > 1 ? _realItemCount + 2 : _realItemCount,
        ),
      ),
    );
  }
}

/*class KeepAlive2 extends StatefulWidget {
  const KeepAlive2({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _KeepAliveState2 createState() => _KeepAliveState2();
}

class _KeepAliveState2 extends State<KeepAlive2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}*/

class CarouselController extends CustomPageController {
  bool _autoPlay;

  bool get autoPlay => _autoPlay ?? initialAutoPlay;

  /// The action to auto play when first creating the [CarouselView].
  final bool initialAutoPlay;

  static const int EVENT_SCROLL = 0;

  static const int EVENT_AUTO_PLAY = 1;

  int _event;

  int get event => _event;

  /*this.initialPage = 0,
  this.keepPage = true,
  this.viewportFraction = 1.0,*/

  CarouselController(
      {this.initialAutoPlay = false,
      int initialPage = 0,
      bool keepPage = true,
      double viewportFraction = 1.0})
      : super(
            initialPage: initialPage,
            keepPage: keepPage,
            viewportFraction: viewportFraction);

  void startAutoPlay() {
    if (_autoPlay) return;
    _event = EVENT_AUTO_PLAY;
    _autoPlay = true;
    notifyListeners();
  }

  void stopAutoPlay() {
    if (!_autoPlay) return;
    _event = EVENT_AUTO_PLAY;
    _autoPlay = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_event != EVENT_AUTO_PLAY) _event = EVENT_SCROLL;

    super.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
