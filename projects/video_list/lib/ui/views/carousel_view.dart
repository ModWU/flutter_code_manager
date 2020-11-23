import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_list/ui/utils/controller_notifier.dart';
import 'package:video_list/ui/views/widgets/sliver.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'widgets/custom_pageview.dart';
import 'dart:math' as math;

class CarouselView extends StatefulWidget {
  CarouselView(
      {this.itemBuilder,
      this.itemCount,
      this.controller,
      this.autoPlayDelay,
      this.onPageChanged,
      this.padding = 0.0,
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

  final double padding;
}

const int _defaultAutoPlayDelay = 5000;
const Curve _defaultCurve = Curves.ease;
const Duration _defaultDuration = Duration(milliseconds: 500);

class _CarouselViewState extends State<CarouselView> {
  Timer _autoPlayTimer; //定时器

  CarouselController _controller;
  ValueNotifier<double> _valueNotifier = new ValueNotifier<double>(0.0);

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

  void _initController() {
    _controller?.dispose();
    final int initIndex = _realItemCount > 1 ? 2 : 0;
    _controller = widget.controller ??
        new CarouselController(
          initialPage: initIndex,
          initialAutoPlay: true,
          scale: 0.8,
          viewportFraction: 0.95,
        );
    _valueNotifier.value = initIndex * 1.0;
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

  bool _notificationStartTag = false;
  bool _notificationNeedAutoPlay = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _valueNotifier,
      child: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (_canScroll && notification.depth == 0) {
            if (notification is ScrollStartNotification) {
              _notificationStartTag = true;
              print("ScrollStartNotification##_controller.page: ${_controller.page}");
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
                print("ScrollEndNotification##currentPage: $currentPage");
                if (currentPage == 1) {
                  _controller.jumpToPage(_realItemCount + 1);
                } else if (currentPage == 2 + _realItemCount) {
                  _controller.jumpToPage(2);
                }
              }
              print("pageStartEnd##ScrollEndNotification:_startTag: ");
              if (_notificationNeedAutoPlay) {
                _notificationNeedAutoPlay = false;
                _controller.startAutoPlay();
              }
            } else if (notification is ScrollUpdateNotification) {

              print("ScrollUpdateNotification####_controller page: ${_controller.page}");
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
              //print("....当前页：${index} ${_realItemCount}");
              final int widgetIndex = (index - 2) % _realItemCount;

              final Widget itemWidget = widget.itemBuilder(context, widgetIndex);

              return Consumer<ValueNotifier<double>>(
                builder: (BuildContext context, ValueNotifier<double> notifier,
                    Widget wgt) {
                  final int currentIndex = notifier.value.round();

                  final double scale = _controller.scale;

                  double scaleVal = 1.0;

                  if (index != currentIndex) {
                    double _needValue = (currentIndex - notifier.value).abs();
                    if (_needValue >= 0 && _needValue < 0.5) {
                      scaleVal = _needValue * 2 * (1 - scale) + scale;
                    } else {
                      scaleVal = scale;
                    }
                  }

                  print("log###widgetIndex: $widgetIndex, index: $index, notifier.value: ${notifier.value}, currentIndex: $currentIndex scaleVal: $scaleVal");

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.padding),
                    child: Transform.scale(
                      scale: scaleVal,
                      alignment: index == currentIndex
                          ? Alignment.center
                          : (index < currentIndex
                              ? Alignment.centerRight
                              : Alignment.centerLeft),
                      child: itemWidget,
                    ),
                  );
                },
              );
            },
            findChildSameIndexCallback: () {
              return <int, int>{
                0: _realItemCount,
                1: _realItemCount + 1,
                2: _realItemCount + 2,
                3: _realItemCount + 3,
              };
            },
            childCount:
                _realItemCount > 1 ? _realItemCount + 4 : _realItemCount,
          ),
        ),
      ),
    );
  }
}

class CarouselController extends CustomPageController {
  bool _autoPlay;

  bool get autoPlay => _autoPlay ?? initialAutoPlay;

  double _scale;

  double get scale => _scale ?? 1.0;

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
  })  : _scale = scale,
        super(
            initialPage: initialPage,
            keepPage: keepPage,
            viewportFraction: viewportFraction);

  void startAutoPlay() {
    if (autoPlay) return;
    _event = EVENT_AUTO_PLAY;
    _autoPlay = true;
    notifyListeners();
    _event = EVENT_SCROLL;
  }

  void stopAutoPlay() {
    if (!autoPlay) return;
    _event = EVENT_AUTO_PLAY;
    _autoPlay = false;
    notifyListeners();
    _event = EVENT_SCROLL;
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
