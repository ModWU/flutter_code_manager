import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_list/resources/res/strings.dart';
import 'package:video_list/utils/simple_utils.dart' as SimpleUtils;
import 'package:video_list/utils/view_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';

const Duration _kPlayButtonAnimationDuration = Duration(milliseconds: 300);
const Duration _kPlayActiveDuration = Duration(seconds: 5);
typedef ActiveWidgetListener = void Function(bool showActiveWidget);

mixin PlayControllerMixin<T extends StatefulWidget> on State<T> {
  FToast _fToast;

  bool _pause = true;
  bool get pause => _pause;

  bool _isPortrait = true;
  bool get isPortrait => _isPortrait;

  void setLandscapeScreen() {
    _isPortrait = false;
    SimpleUtils.setLandscapeScreen();
   /* SimpleUtils.addBuildAfterCallback(() {
      setState(() {});
    });*/
  }

  void setPortraitScreen() {
    _isPortrait = true;
    SimpleUtils.setPortraitScreen();
    /*SimpleUtils.addBuildAfterCallback(() {
      setState(() {});
    });*/
  }

  bool get showActiveWidget => _showActiveWidget;
  bool _showActiveWidget = true;

  Timer _activeTimer;
  List<ActiveWidgetListener> _activeWidgetListeners;

  void resetShowActiveWidget({bool showActiveWidget = true}) {
    assert(showActiveWidget != null);
    if (_showActiveWidget == showActiveWidget) return;

    _showActiveWidget = showActiveWidget;
  }

  void addActiveWidgetListener(ActiveWidgetListener listener) {
    assert(listener != null);
    _activeWidgetListeners ??= [];
    _activeWidgetListeners.add(listener);
  }

  void removeActiveWidgetListener(ActiveWidgetListener listener) {
    assert(listener != null);
    if (_activeWidgetListeners == null ||
        !_activeWidgetListeners.contains(listener)) return;
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

  final GlobalKey portraitVideoSizeKey = GlobalKey();
  final GlobalKey landscapeVideoSizeKey = GlobalKey();

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
      {bool hasStatusBar = true, bool isPortrait = true}) {
    assert(_fToast != null);
    assert(_sizeKey != null);
    assert(isPortrait != null);
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

    if (isPortrait) {
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
        _showActiveWidget = false;
        _activeTimer = null;
        _setState();
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
      SimpleUtils.addBuildAfterCallback(() {
        _setState();
      });
      _notifyActiveWidget(_showActiveWidget);
    }

    if (!_showActiveWidget) return;

    _activeTimer = Timer(_kPlayActiveDuration, () {
      if (_showActiveWidget && !pause) {
        _showActiveWidget = false;
        _activeTimer = null;
        _setState();
        _notifyActiveWidget(false);
      }
    });
  }

  void _setState() {
    final Element portraitElement = portraitVideoSizeKey.currentContext;
    if (portraitElement != null) portraitElement.markNeedsBuild();

    final Element landscapeElement = landscapeVideoSizeKey.currentContext;
    if (landscapeElement != null) landscapeElement.markNeedsBuild();
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
      SimpleUtils.addBuildAfterCallback(() {
        _setState();
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
