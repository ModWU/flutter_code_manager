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

enum ProgressControllerState {
  down,
  up,
  startDrag,
  endDrag,
  dragging,
  nothing,
}

enum ProgressValueState {
  increase,
  reduce,
  nothing,
}

class ProgressControllerNotify with ChangeNotifier {
  ProgressControllerState _state = ProgressControllerState.nothing;
  ProgressValueState _valueState = ProgressValueState.nothing;
  double _currentValue;
  double _maxValue;
  Duration _downPositionDuration;
  int _stateSign = 0;
  bool _isTouchBar = false;

  ProgressControllerNotify({
    double currentValue = 0,
    double maxValue,
  })  : assert(maxValue != null),
        assert(maxValue >= 0),
        assert(currentValue != null),
        assert(currentValue >= 0 && currentValue <= maxValue),
        _maxValue = maxValue,
        _currentValue = currentValue;

  ProgressControllerState get state {
    assert(_state != null);
    return _state;
  }

  ProgressValueState get currentState {
    assert(_valueState != null);
    return _valueState;
  }

  double get currentValue {
    assert(_currentValue >= 0 && _currentValue <= _maxValue);
    return _currentValue;
  }

  double get maxValue => _maxValue;

  Duration get downPositionDuration => _downPositionDuration;

  bool get isTouchBar => _isTouchBar;

  bool increasing() {
    return _valueState == ProgressValueState.increase;
  }

  bool reducing() {
    return _valueState == ProgressValueState.reduce;
  }

  bool isHasState(ProgressControllerState state) {
    assert(state != null);
    final int stateValue = 1 << state.index;
    return (_stateSign & stateValue) == stateValue;
  }

  void addState(ProgressControllerState state) {
    assert(state != null);
    _stateSign |= (1 << state.index);
  }

  void change(
      {ProgressControllerState state,
      double currentValue,
      double maxValue,
      Duration downPositionDuration,
      bool isTouchBar = false}) {
    assert(state != null || currentValue != null);
    assert(isTouchBar != null);
    bool isNotify = false;
    if (state != null && state != _state) {
      _state = state;
      _stateSign |= (1 << state.index);
      if (state == ProgressControllerState.endDrag ||
          state == ProgressControllerState.up) {
        _stateSign = 0;
      }
      isNotify = true;
    }

    if (maxValue != null && maxValue != _maxValue) {
      assert(maxValue >= 0);
      _maxValue = maxValue;
      isNotify = true;
    }

    if (currentValue < 0)
      currentValue = 0;
    else if (currentValue > _maxValue) currentValue = _maxValue;

    _valueState = ProgressValueState.nothing;

    if (currentValue != null && currentValue != _currentValue) {
      assert(currentValue >= 0 && currentValue <= _maxValue);
      if (currentValue > _currentValue) {
        _valueState = ProgressValueState.increase;
      } else {
        _valueState = ProgressValueState.reduce;
      }

      _currentValue = currentValue;
      isNotify = true;
    }

    assert(_currentValue <= _maxValue);

    if (downPositionDuration != null &&
        downPositionDuration != _downPositionDuration) {
      _downPositionDuration = downPositionDuration;
      isNotify = true;
    }

    if (isTouchBar != _isTouchBar) {
      _isTouchBar = isTouchBar;
    }

    if (isNotify) notifyListeners();
  }
}

mixin PlayControllerMixin<T extends StatefulWidget> on State<T> {
  FToast _fToast;

  bool _pause = true;
  bool get pause => _pause;

  bool _isPortrait = true;
  bool get isPortrait => _isPortrait;

  ProgressControllerNotify get progressControllerNotify =>
      _progressControllerNotify;

  ProgressControllerNotify _progressControllerNotify =
      ProgressControllerNotify(maxValue: 1.0);

  void setLandscapeScreen() {
    _isPortrait = false;
    SimpleUtils.setLandscapeScreen();
    /* SimpleUtils.addBuildAfterCallback(() {
      setState(() {});
    });*/
  }

  void setDragPositionAndNotify(ProgressControllerState state,
      {double boxPositionPercent, bool isTouchBar = false}) {
    assert(state != null);
    assert(isTouchBar != null);
    if (!initialized) {
      return;
    }
    final double positionPercent = boxPositionPercent != null
        ? boxPositionPercent
        : progressControllerNotify.currentValue;
    progressControllerNotify.change(
      currentValue: positionPercent,
      state: state,
      isTouchBar: isTouchBar,
    );
    final Duration position = duration * positionPercent;
    controller.seekTo(position);
  }

  double getBoxPositionPercent(GlobalKey boxKey, Offset globalPosition) {
    assert(boxKey?.currentContext != null);
    assert(globalPosition != null);
    final RenderBox box = boxKey.currentContext.findRenderObject();
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = tapPos.dx / box.size.width;
    /*final Duration position = controller.value.duration * relative;
    controller.seekTo(position);*/
    return relative;
  }

  double getProgressPositionPercent(Duration position, Duration duration) {
    assert(position != null);
    assert(duration != null);
    return position.inMilliseconds / duration.inMilliseconds;
  }

  DateTime _lastPressedAdt;
  bool _allowDragController = false;
  Offset _lastPosition;
  //GlobalKey _centerControllerWidgetKey = GlobalKey();

  Widget buildProgressControllerWidget(GlobalKey centerControllerKey) {
    assert(centerControllerKey != null);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        _allowDragController = true;
        if (!initialized ||
            (_lastPressedAdt != null &&
                DateTime.now().difference(_lastPressedAdt).inMilliseconds >=
                    500)) {
          _allowDragController = false;
          return;
        }
        cancelActiveTimer(showActiveWidget: false);
        progressControllerNotify.change(
          currentValue: getProgressPositionPercent(position, duration),
          state: ProgressControllerState.startDrag,
        );
        _lastPosition = details.globalPosition;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!_allowDragController) return;
        assert(_lastPosition != null);
        assert(centerControllerKey.currentContext != null);
        final RenderBox parentBox =
            centerControllerKey.currentContext.findRenderObject();
        assert(parentBox != null);
        assert(parentBox.size != null);
        assert(parentBox.size.width > 0);
        //最多只能滑动十分钟
        final double totalTime = ((details.globalPosition - _lastPosition).dx /
                parentBox.size.width) *
            1000 *
            60 *
            10;

        final double newCurrentValue = (totalTime +
                progressControllerNotify.currentValue *
                    duration.inMilliseconds) /
            duration.inMilliseconds;
        progressControllerNotify.change(
          currentValue: newCurrentValue,
          state: ProgressControllerState.dragging,
        );

        _lastPosition = details.globalPosition;
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        _lastPressedAdt = null;
        if (!_allowDragController) return;
        //end 和 down不会同时执行
        _lastPosition = null;
        setDragPositionAndNotify(ProgressControllerState.endDrag);
        controller.play();
      },
      onTapDown: (TapDownDetails details) {
        _allowDragController = false;
        _lastPressedAdt = DateTime.now();
      },
      onTapUp: (TapUpDetails details) {
        _lastPressedAdt = null;
        if (!_allowDragController) return;
        _lastPosition = null;
        setDragPositionAndNotify(ProgressControllerState.up);
        controller.play();
      },
      onTap: () {
        handleActiveTimer(force: true);
      },
      child: Center(
        key: centerControllerKey,
        child: Container(),
      ),
    );
  }

  Widget buildProgressIndicator({Widget child, GlobalKey progressKey}) {
    assert(child != null);
    assert(progressKey != null);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        print("哈哈哈哈哈onHorizontalDragStart");
        if (!initialized) {
          return;
        }
        progressControllerNotify.change(
          currentValue:
              getBoxPositionPercent(progressKey, details.globalPosition),
          state: ProgressControllerState.startDrag,
          isTouchBar: true,
        );
        blockActiveTimer();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!initialized) {
          return;
        }
        progressControllerNotify.change(
          currentValue:
              getBoxPositionPercent(progressKey, details.globalPosition),
          state: ProgressControllerState.dragging,
          isTouchBar: true,
        );
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        //end 和 down不会同时执行
        if (!initialized) {
          return;
        }

        setDragPositionAndNotify(
          ProgressControllerState.endDrag,
          isTouchBar: true,
        );
        controller.play();
        unblockActiveTimer();
      },
      onTapDown: (TapDownDetails details) {
        if (!initialized) {
          return;
        }
        progressControllerNotify.change(
          currentValue:
              getBoxPositionPercent(progressKey, details.globalPosition),
          downPositionDuration: position,
          state: ProgressControllerState.down,
          isTouchBar: true,
        );
        blockActiveTimer();
      },
      onTapUp: (TapUpDetails details) {
        if (!initialized) {
          return;
        }
        //忽略抬起的位置
        setDragPositionAndNotify(
          ProgressControllerState.up,
          isTouchBar: true,
        );
        controller.play();
        unblockActiveTimer();
      },
      child: child,
    );
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

  void cancelActiveTimer({bool showActiveWidget}) {
    if (_activeTimer != null) {
      _activeTimer.cancel();
      _activeTimer = null;
    }

    if (showActiveWidget != null && showActiveWidget != _showActiveWidget) {
      _showActiveWidget = showActiveWidget;
      _setState();
    }
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

  void blockActiveTimer() {
    if (_activeTimer != null) {
      _activeTimer.cancel();
      _activeTimer = null;
    }

    if (!showActiveWidget) {
      _showActiveWidget = true;
      _setState();
      _notifyActiveWidget(true);
    }
  }

  void unblockActiveTimer() {
    if (_activeTimer != null) return;
    resetActiveTimer();
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
    Widget child = AnimatedSwitcher(
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
    );
    return StatefulBuilder(
      builder: (_, StateSetter setState) {
        return onTap != null
            ? GestureDetector(
                onTap: () {
                  assert(onTap != null);
                  onTap.call();
                },
                child: child,
              )
            : child;
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
