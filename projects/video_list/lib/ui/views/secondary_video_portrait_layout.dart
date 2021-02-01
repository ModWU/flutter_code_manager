import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/ui/views/video_indicator.dart';
import 'package:video_list/utils/simple_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'secondary_video_view.dart';

const Duration _kPlayButtonAnimationDuration = Duration(milliseconds: 300);
const Duration _kPlayActiveDuration = Duration(seconds: 5);

class SecondaryPortraitVideoLayout extends StatefulWidget {
  SecondaryPortraitVideoLayout({
    Key key,
    this.controller,
    this.onBack,
  })  : assert(controller != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SecondaryPortraitVideoLayoutState();

  final VideoPlayerController controller;
  final VoidCallback onBack;
}

class _SecondaryPortraitVideoLayoutState
    extends State<SecondaryPortraitVideoLayout> with VideoToastMiXin {
  Duration _totalDuration;
  Map<int, bool> _showHoverState;
  bool _pause = false;
  bool _showActiveWidget = true;
  Timer _activeTimer;
  VideoPlayerController _controller;
  GlobalKey _videoSizeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _handleActiveTimer();
  }

  bool _isPlayEnd() {
    assert(_controller != null);
    return _controller.value.duration == null ||
        _controller.value.position == _controller.value.duration;
  }

  void _changePlayState({bool pause, bool isSetState = true}) {
    assert(_pause != null);
    assert(isSetState != null);
    assert(_controller != null);
    if (_isPlayEnd()) {
      pause = true;
    }

    if (pause != null) {
      if (pause != _pause) {
        _pause = pause;
      } else {
        return;
      }
    } else {
      _pause = !_pause;
    }

    if (isSetState) {
      addBuildAfterCallback(() {
        setState(() {});
      });
    }

    if (_pause) {
      _controller.pause();
    } else {
      _controller.play();
    }

    _handleActiveTimer();
  }

  void _handleActiveTimer() {
    assert(_pause != null);
    if (_pause) return;

    if (_activeTimer != null) {
      _activeTimer.cancel();
      _activeTimer = null;
    }

    _activeTimer = Timer(_kPlayActiveDuration, () {
      if (!_pause) {
        setState(() {
          _showActiveWidget = false;
          _activeTimer = null;
        });
      }
    });
  }

  Widget _buildActiveWidget() {
    return Offstage(
      offstage: !_showActiveWidget,
      child: Column(
        children: [
          _buildTopActiveWidget(),
          _buildCenterActiveWidget(),
          _buildBottomActiveWidget(),
        ],
      ),
    );
  }

  Widget _buildHoverStateWidget(int stateId, Widget child,
      {VoidCallback onTap}) {
    assert(child != null);
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
              color: _showHoverState[stateId] ? Colors.grey : Colors.white,
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildBackIcon() {
    return _buildStandardButton(
      Icons.arrow_back_ios,
      size: 40.sp,
      onTap: () {
        widget.onBack?.call();
      },
    );
  }

  Widget _buildTopWidget() {
    return Positioned(
      left: 20.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackIcon(),
        ],
      ),
    );
  }

  List<Shadow> _getStandardShadows() {
    return [
      BoxShadow(
        color: Colors.black54,
        offset: Offset(0.01, 0.01), //阴影xy轴偏移量
        blurRadius: 1.6, //阴影模糊程度
        spreadRadius: 0.0, //阴影扩散程度
      ),
    ];
  }

  TextStyle _getStandardStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 24.sp,
      shadows: _getStandardShadows(),
    );
  }

  Widget _buildProgressIndicator(VideoPlayerController controller) {
    assert(controller != null);
    return VideoProgressOwnerIndicator(
      controller,
      allowScrubbing: false,
      padding: EdgeInsets.zero,
      colors: VideoProgressColors(
        playedColor: Color(0xFFFF6633),
        backgroundColor: Colors.black26,
        bufferedColor: Colors.blueGrey,
      ),
    );
  }

  String _getFormatDuration(Duration duration) {
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

  Widget _buildPlayButton() {
    return StatefulBuilder(
      builder: (_, StateSetter setState) {
        return GestureDetector(
          onTap: () {
            print("play => pause:${_pause}");
            _changePlayState();
          },
          child: AnimatedSwitcher(
            duration: _kPlayButtonAnimationDuration,
            child: Text(
              _pause
                  ? String.fromCharCode(Icons.play_arrow_rounded.codePoint)
                  : String.fromCharCode(Icons.pause_rounded.codePoint),
              style: TextStyle(
                fontFamily: _pause
                    ? Icons.play_arrow_rounded.fontFamily
                    : Icons.pause.fontFamily,
                fontSize: 64.sp,
              ),
              key: _pause ? const ValueKey("pause") : const ValueKey("play"),
            ),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> value) {
              final double begin = _pause ? .75 : .25;
              final double end = _pause ? 1.0 : .0;

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

  Widget _buildStandardButton(IconData iconData,
      {double size, VoidCallback onTap}) {
    assert(iconData != null);
    size ??= 48.sp;
    return _buildHoverStateWidget(
      iconData.codePoint,
      Text(
        String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          fontSize: size,
          //shadows: _getStandardShadows(),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMoreButton() {
    return _buildStandardButton(
      Icons.more_horiz_rounded,
      onTap: () {},
    );
  }

  Widget _buildMusicButton() {
    return _buildStandardButton(
      Icons.queue_music,
      onTap: () {},
    );
  }

  Widget _buildTVButton() {
    return _buildStandardButton(
      Icons.live_tv,
      onTap: () {},
    );
  }

  Widget _buildFloatingVideoButton() {
    return _buildStandardButton(
      Icons.fullscreen_exit,
      onTap: () {},
    );
  }

  Widget _buildCenterActiveWidget() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: _buildFloatingVideoButton(),
        ),
      ),
    );
  }

  Widget _buildTopActiveWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 240.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTVButton(),
              _buildMusicButton(),
              _buildMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActiveWidget() {
    return Container(
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.all(Radius.circular(28)),
        // border: Border.all(color: Color(0xFFFF0000), width: 0),
        shape: BoxShape.rectangle,
        color: Colors.black54,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: FractionalOffset
              .topCenter, // 10% of the width, so there are ten blinds.
          colors: [
            Colors.black,
            Colors.transparent,
          ], // whitish to gray
          tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlayButton(),
          Padding(
            padding: EdgeInsets.only(
              left: 18.w,
              right: 12.w,
            ),
            child: Text(
              _getFormatDuration(_controller.value.position),
            ),
          ),
          Expanded(
            child: _buildProgressIndicator(_controller),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 12.w,
            ),
            child: Text(
              _getFormatDuration(_totalDuration),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 34.w,
              right: 16.w,
            ),
            child: _buildStandardButton(
              Icons.screen_rotation_rounded,
              size: 40.sp,
              onTap: () {
                setLandscapeScreen();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant SecondaryPortraitVideoLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    assert(_controller.value != null);
    _totalDuration ??= _controller.value.duration;
    if (_isPlayEnd() || !_controller.value.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        _changePlayState(pause: true, isSetState: false);
      });
    } else {
      _changePlayState(pause: !_controller.value.isPlaying, isSetState: false);
    }
    return DefaultTextStyle(
      style: _getStandardStyle(),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showActiveWidget = !_showActiveWidget;
            _handleActiveTimer();
          });
          print("单击222");
        },
        onDoubleTap: () {
          _changePlayState();

          if (!_isPlayEnd()) {
            if (_pause) {
              showPauseToast(_videoSizeKey);
            } else {
              hidePauseToast();
            }
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          key: _videoSizeKey,
          padding: EdgeInsets.only(
            left: 0.w,
            right: 0.w,
            top: 16.w,
            bottom: 4.w,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildActiveWidget(),
              _buildTopWidget(),
            ],
          ),
        ),
      ),
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
