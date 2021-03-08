import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/resources/export.dart';
import 'package:video_list/ui/animations/impliclit_transition.dart';
import 'package:video_list/ui/controller/play_controller.dart';
import 'package:video_list/ui/views/secondary_video_portrait_layout.dart';
import 'package:video_list/ui/views/video_indicator.dart';
import 'package:video_player/video_player.dart';
import '../../utils/view_utils.dart';
import 'secondary_video_landscape_layout.dart';
import 'static_video_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  double getPositionPercent(GlobalKey boxKey, Offset globalPosition) {
    assert(boxKey?.currentContext != null);
    assert(globalPosition != null);
    final RenderBox box = boxKey.currentContext.findRenderObject();
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = tapPos.dx / box.size.width;
    /*final Duration position = controller.value.duration * relative;
    controller.seekTo(position);*/
    return relative;
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
    with VideoUtilsMiXin {
  PlayControllerMixin _controller;

//_buildVideoView(orientation)

  @override
  Widget build(BuildContext context) {
    print("_SecondaryVideoViewState build build");
    return WillPopScope(
      onWillPop: () async {
        if (!_controller.isPortrait) {
          _controller.hidePauseToast();
          _controller.setPortraitScreen();
          //返回false路由不会弹出
          return false;
        }
        return true;
      },
      child: _buildVideoView(),
    );
  }

  Widget _buildVideoView() {
    final GlobalKey videoSizeKey = _controller.isPortrait
        ? _controller.portraitVideoSizeKey
        : _controller.landscapeVideoSizeKey;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GestureDetector(
        onTap: () {
          print("fdjaljfdklajfkd");
          _controller.handleActiveTimer(force: true);
        },
        onDoubleTap: () {
          assert(_controller != null);
          print("fdjaljfdklajfkd...........");
          _controller.handlePlayState();

          if (!_controller.playEnd) {
            if (_controller.pause) {
              _controller.showPauseToast(videoSizeKey,
                  isPortrait: _controller.isPortrait);
            } else {
              _controller.hidePauseToast();
            }
          }
        },
        child: VideoView(
          controller: _controller.controller,
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
            assert(_controller != null);

            return _controller.isPortrait
                ? SecondaryPortraitVideoLayout(
                    _controller,
                    key: _controller.portraitVideoSizeKey,
                    onBack: widget.onBack,
                  )
                : SecondaryLandscapeVideoLayout(
                    _controller,
                    key: _controller.landscapeVideoSizeKey,
                  );
          },
        ),
      );
    });
  }

  @override
  void didUpdateWidget(covariant SecondaryVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }
}

class SecondaryVideoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SecondaryVideoViewState();

  SecondaryVideoView({
    this.advertUrl,
    this.controller,
    this.onBack,
  }) : assert(controller != null);

  final String advertUrl;
  final PlayControllerMixin controller;
  final VoidCallback onBack;
}
