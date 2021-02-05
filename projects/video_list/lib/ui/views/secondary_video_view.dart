import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/resources/export.dart';
import 'package:video_list/ui/animations/impliclit_transition.dart';
import 'package:video_list/ui/views/secondary_video_portrait_layout.dart';
import 'package:video_list/ui/views/video_indicator.dart';
import 'package:video_list/utils/simple_utils.dart';
import 'package:video_player/video_player.dart';
import '../../utils/view_utils.dart';
import 'secondary_video_landscape_layout.dart';
import 'static_video_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Duration _kPlayButtonAnimationDuration = Duration(milliseconds: 300);
const Duration _kPlayActiveDuration = Duration(seconds: 5);
typedef ActiveWidgetListener = void Function(bool showActiveWidget);

mixin PlayControllerMixin<T extends StatefulWidget> on State<T> {
  FToast _fToast;

  bool _pause = true;
  bool get pause => _pause;

  bool get showActiveWidget => _showActiveWidget;
  bool _showActiveWidget = true;

  Timer _activeTimer;
  List<ActiveWidgetListener> _activeWidgetListeners;

  void resetShowActiveWidget({bool showActiveWidget = true}) {
    assert(showActiveWidget != null);
    if (_showActiveWidget == showActiveWidget)
      return;

    _showActiveWidget = showActiveWidget;
  }

  void addActiveWidgetListener(ActiveWidgetListener listener) {
    assert(listener != null);
    _activeWidgetListeners ??= [];
    _activeWidgetListeners.add(listener);
  }

  void removeActiveWidgetListener(ActiveWidgetListener listener) {
    assert(listener != null);
    if (_activeWidgetListeners == null || !_activeWidgetListeners.contains(listener))
      return;
    var element = _activeWidgetListeners.remove(listener);
    assert(element != null);
  }

  void _notifyActiveWidget(bool showActiveWidget) {
    assert(showActiveWidget != null);
    if (_activeWidgetListeners == null || _activeWidgetListeners.isEmpty)
      return;

    for (ActiveWidgetListener listener in _activeWidgetListeners) {
      assert(listener != null);
      listener(showActiveWidget);
    }
  }

  handlePlayState({bool pause, bool isSetState = true});

  Duration get position => Duration.zero;

  Duration get duration => Duration.zero;

  bool get playEnd => true;

  bool get isPlaying => false;

  bool get initialized => false;

  VideoPlayerController get controller => null;

  @override
  void initState() {
    super.initState();
    _fToast = FToast();
    _fToast.init(context);

    handleActiveTimer(force: true, changeState: false);
  }

  @override
  void dispose() {
    assert(_fToast != null);
    Fluttertoast.cancel();
    _fToast.removeQueuedCustomToasts();
    _activeWidgetListeners?.clear();
    _activeWidgetListeners = null;
    super.dispose();
  }

  void hidePauseToast() {
    assert(_fToast != null);
    Fluttertoast.cancel();
    _fToast.removeQueuedCustomToasts();
  }

  void showPauseToast(GlobalKey _sizeKey,
      {bool hasStatusBar = true, Orientation orientation}) {
    assert(_fToast != null);
    assert(_sizeKey != null);
    assert(orientation != null);
    assert(hasStatusBar != null);
    // Custom Toast Position
    final RenderBox videoSizeRenderBox =
        _sizeKey.currentContext?.findRenderObject();
    assert(videoSizeRenderBox != null);
    final Size videoSize = videoSizeRenderBox.size;
    assert(videoSize != null);

    Size toastSize;
    double iconSize;
    double textSize;
    double radius;

    if (orientation == Orientation.portrait) {
      toastSize = Size(180.w, 80.w);
      iconSize = 42.sp;
      textSize = 24.sp;
      radius = 10.w;
    } else {
      toastSize = Size(120.w, 50.w);
      iconSize = 26.sp;
      textSize = 16.sp;
      radius = 8.w;
    }

    final double leftOffset = (videoSize.width - toastSize.width) / 2;
    final double topOffset =
        (hasStatusBar ? MediaQueryData.fromWindow(window).padding.top : 0) +
            (videoSize.height - toastSize.height) / 2;
    _fToast.showToast(
      child: buildIconText(
        icon: Icon(
          Icons.pause,
          color: Colors.white,
          size: iconSize,
        ),
        text: Text(
          Strings.toast_video_pause,
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
          ),
        ),
        width: toastSize.width,
        height: toastSize.height,
        alignment: Alignment.center,
        gap: 8.w,
        /*padding: EdgeInsets.symmetric(
          vertical: 16.w,
          horizontal: 24.w,
        ),*/
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
      ),
      toastDuration: Duration(seconds: 4),
      positionedToastBuilder: (context, child) {
        return Positioned(
          left: leftOffset,
          top: topOffset,
          child: child,
        );
      },
    );
  }

  void resetActiveTimer() {
    if (_activeTimer != null) {
      _activeTimer.cancel();
      _activeTimer = null;
    }

    _activeTimer = Timer(_kPlayActiveDuration, () {
      if (_showActiveWidget) {
        setState(() {
          _showActiveWidget = false;
          _activeTimer = null;
        });
        _notifyActiveWidget(false);
      }
    });
  }

  void handleActiveTimer({bool force = false, bool changeState = true}) {
    assert(force != null);
    assert(pause != null);
    assert(changeState != null);
    if (!force && pause) return;

    if (_activeTimer != null) {
      _activeTimer.cancel();
      _activeTimer = null;
    }

    if (changeState) {
      _showActiveWidget = !_showActiveWidget;
      addBuildAfterCallback(() {
        setState(() {});
      });
      _notifyActiveWidget(_showActiveWidget);
    }

    if (!_showActiveWidget) return;


    _activeTimer = Timer(_kPlayActiveDuration, () {
      if (_showActiveWidget && !pause) {
        setState(() {
          _showActiveWidget = false;
          _activeTimer = null;
        });
        _notifyActiveWidget(false);
      }
    });
  }

  void changePlayState({bool pause, bool isSetState = true}) {
    assert(_pause != null);
    assert(isSetState != null);
    print("changePlayState!!!!!!!$pause");

    if (pause != null) {
      if (pause != _pause) {
        _pause = pause;
      } else {
        return;
      }
    } else {
      _pause = !_pause;
    }

    handleActiveTimer(changeState: false);

    if (isSetState) {
      addBuildAfterCallback(() {
        setState(() {});
      });
    }
  }

  Widget buildPlayButton({VoidCallback onTap, double size}) {
    assert(size != null);
    return StatefulBuilder(
      builder: (_, StateSetter setState) {
        return GestureDetector(
          onTap: () {
            onTap?.call();
          },
          child: AnimatedSwitcher(
            duration: _kPlayButtonAnimationDuration,
            child: Text(
              pause
                  ? String.fromCharCode(Icons.play_arrow_rounded.codePoint)
                  : String.fromCharCode(Icons.pause_rounded.codePoint),
              style: TextStyle(
                fontFamily: pause
                    ? Icons.play_arrow_rounded.fontFamily
                    : Icons.pause.fontFamily,
                fontSize: size,
              ),
              key: pause ? const ValueKey("pause") : const ValueKey("play"),
            ),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> value) {
              final double begin = pause ? .75 : .25;
              final double end = pause ? 1.0 : .0;

              return _Reverse2ForwardRotationTransition(
                animation: Tween(begin: begin, end: end).animate(value),
                child: FadeTransition(
                  opacity: value,
                  child: child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

mixin VideoUtilsMiXin<T extends StatefulWidget> on State<T> {
  Map<dynamic, bool> _showHoverState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextStyle getStandardStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 14.sp,
      shadows: getStandardShadows(),
    );
  }

  String getFormatDuration(Duration duration) {
    if (duration == null) return '00:00';
    int hours = duration.inHours;
    duration = duration - Duration(hours: hours);
    int minutes = duration.inMinutes;
    duration = duration - Duration(minutes: minutes);
    int seconds = duration.inSeconds;

    hours = hours.clamp(0, 100);

    var hoursStr = hours <= 0 ? '' : (hours < 10 ? "0$hours:" : "$hours:");

    return "$hoursStr${minutes < 10 ? "0$minutes" : minutes}:${seconds < 10 ? "0$seconds" : seconds}";
  }

  List<Shadow> getStandardShadows() {
    return [
      BoxShadow(
        color: Colors.black54,
        offset: Offset(0.01, 0.01), //阴影xy轴偏移量
        blurRadius: 1.6, //阴影模糊程度
        spreadRadius: 0.0, //阴影扩散程度
      ),
    ];
  }

  Widget buildStandardButton(
      {IconData iconData,
      String text,
      double size,
      Color color = Colors.white,
      VoidCallback onTap}) {
    assert(iconData != null || text != null);
    assert(color != null);
    return _buildHoverStateWidget(
      iconData?.codePoint ?? text,
      Text(
        iconData != null ? String.fromCharCode(iconData.codePoint) : text,
        style: TextStyle(
          fontFamily: iconData?.fontFamily,
          fontSize: size,
        ),
      ),
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildHoverStateWidget(dynamic stateId, Widget child,
      {VoidCallback onTap, Color color = Colors.white}) {
    assert(stateId != null);
    assert(child != null);
    assert(color != null);
    _showHoverState ??= {};
    _showHoverState.putIfAbsent(stateId, () => false);
    return StatefulBuilder(
      builder: (_, StateSetter setState) {
        return InkWell(
          onTap: () {
            onTap?.call();
            setState(() {
              _showHoverState[stateId] = !_showHoverState[stateId];
            });
          },
          //highlightColor: Colors.black26,
          /*onHighlightChanged: (bool isHighlight) {
            setState(() {
              _backHover = isHighlight;
            });
          },*/
          onTapCancel: () {
            setState(() {
              _showHoverState[stateId] = false;
            });
          },
          onTapDown: (TapDownDetails details) {
            setState(() {
              _showHoverState[stateId] = true;
            });
          },

          child: DefaultTextStyle(
            style: TextStyle(
              color: _showHoverState[stateId] ? Colors.grey : color,
              shadows: getStandardShadows(),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _SecondaryVideoViewState extends State<SecondaryVideoView>
    with PlayControllerMixin, VideoUtilsMiXin {
  VideoPlayerController _controller;
  final GlobalKey _portraitVideoSizeKey = GlobalKey();
  final GlobalKey _landscapeVideoSizeKey = GlobalKey();
  Duration _totalDuration;
//_buildVideoView(orientation)

  @override
  VideoPlayerController get controller {
    assert(_controller != null);
    return _controller;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        orientation = MediaQuery.of(context).size.width >
                MediaQuery.of(context).size.height
            ? Orientation.landscape
            : Orientation.portrait;
        print("orientation: $orientation");
        //return _buildVideoView(orientation);
        return WillPopScope(
          onWillPop: () async {
            if (orientation == Orientation.landscape) {
              hidePauseToast();
              setPortraitScreen();
              //返回false路由不会弹出
              return false;
            }
            return true;
          },
          child: _buildVideoView(orientation),
        );
      },
    );
  }

  Widget _buildVideoView(Orientation orientation) {
    assert(orientation != null);
    final GlobalKey videoSizeKey = orientation == Orientation.portrait
        ? _portraitVideoSizeKey
        : _landscapeVideoSizeKey;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GestureDetector(
        onTap: () {
          print("fdjaljfdklajfkd");
          handleActiveTimer(force: true);
        },
        onDoubleTap: () {
          handlePlayState();

          if (!playEnd) {
            if (pause) {
              showPauseToast(videoSizeKey, orientation: orientation);
            } else {
              hidePauseToast();
            }
          }
        },
        child: VideoView(
          videoUrl: widget.url,
          controller: _controller,
          contentFit: StackFit.expand,
          errorBuilder: (context, _) {
            return Container(
              alignment: Alignment.center,
              child: Text("播放错误!!!"),
            );
          },
          contentStackBuilder:
              (BuildContext context, VideoPlayerController controller) {
            assert(controller != null);
            _totalDuration ??= controller.value.duration;
            if (!controller.value.initialized) {
              resetShowActiveWidget(showActiveWidget: true);
              handlePlayState(
                pause: true,
                isSetState: false,
              );
            } else if (playEnd) {
              handlePlayState(
                pause: true,
                isSetState: false,
              );
            } else {
              handlePlayState(
                pause: !isPlaying,
                isSetState: false,
              );
            }

            return orientation == Orientation.portrait
                ? SecondaryPortraitVideoLayout(
                    this,
                    key: _portraitVideoSizeKey,
                    onBack: widget.onBack,
                  )
                : SecondaryLandscapeVideoLayout(
                    this,
                    key: _landscapeVideoSizeKey,
                  );
          },
        ),
      );
    });
  }

  void handlePlayState({bool pause, bool isSetState = true}) {
    assert(isSetState != null);
    assert(_controller != null);
    if (playEnd) {
      pause = true;
    }

    final bool oldPause = this.pause;

    changePlayState(pause: pause, isSetState: isSetState);

    if (oldPause == this.pause) return;

    if (this.pause) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant SecondaryVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      assert(widget.url != null);
      _controller = VideoPlayerController.network(
        widget.url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      _controller = widget.controller;
    }
  }


  @override
  void dispose() {
    if (_controller != widget.controller) _controller.dispose();
    super.dispose();
  }

  @override
  bool get playEnd {
    assert(_controller != null);
    return _controller.value.duration == null ||
        _controller.value.position == _controller.value.duration;
  }

  @override
  Duration get position {
    assert(_controller != null);
    return _controller.value.position;
  }

  @override
  Duration get duration {
    assert(_controller != null);
    return _totalDuration ?? _controller.value?.duration ?? Duration.zero;
  }

  @override
  bool get initialized {
    assert(_controller != null);
    return _controller.value.initialized;
  }

  @override
  bool get isPlaying {
    assert(_controller != null);
    return _controller.value.initialized && _controller.value.isPlaying;
  }
}

class SecondaryVideoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SecondaryVideoViewState();

  SecondaryVideoView({
    this.advertUrl,
    this.url,
    this.controller,
    this.onBack,
  }) : assert(url != null || controller != null);

  final String advertUrl;
  final String url;
  final VideoPlayerController controller;
  final VoidCallback onBack;
}

class _Reverse2ForwardRotationTransition extends AnimatedWidget {
  _Reverse2ForwardRotationTransition({
    Key key,
    @required Animation<double> animation,
    this.child,
  })  : assert(animation != null),
        super(key: key, listenable: animation);

  Animation<double> get animation => listenable;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Animation<double> forwardAnimation = animation;
    //动画反向执行时，调整x偏移，实现“从左边滑出隐藏”
    if (animation.status == AnimationStatus.reverse) {
      forwardAnimation = forwardAnimation.drive(Tween(begin: 1.0, end: 0.0));
    }

    return RotationTransition(
      turns: forwardAnimation,
      child: child,
    );
  }
}
