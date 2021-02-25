import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_list/pages/page_controller.dart';
import 'file:///C:/wuchaochao/project/flutter_code_manager/projects/video_list/lib/ui/controller/play_controller.dart';
import 'package:video_list/ui/views/video_indicator.dart';
import 'package:video_list/utils/view_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'secondary_video_view.dart';

const Duration _kPlayActiveDuration = Duration(seconds: 5);

class SecondaryPortraitVideoLayout extends StatefulWidget {
  SecondaryPortraitVideoLayout(
    this.playController, {
    Key key,
    this.onBack,
  })  : assert(playController != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SecondaryPortraitVideoLayoutState();

  final VoidCallback onBack;
  final PlayControllerMixin playController;
}

class _SecondaryPortraitVideoLayoutState
    extends State<SecondaryPortraitVideoLayout> with VideoUtilsMiXin {
  PlayControllerMixin _playController;

  @override
  void initState() {
    super.initState();
    print("portrait init hashcode: $hashCode");
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _playController = widget.playController;
    _playController.resetActiveTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildActiveWidget() {
    return Offstage(
      offstage: !_playController.showActiveWidget,
      child: Column(
        children: [
          _buildTopActiveWidget(),
          _buildCenterActiveWidget(),
          _buildBottomActiveWidget(),
        ],
      ),
    );
  }

  Widget _buildBackIcon() {
    return buildStandardButton(
      iconData: Icons.arrow_back_ios,
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

  Widget _buildMoreButton() {
    return buildStandardButton(
      iconData: Icons.more_horiz_rounded,
      size: 48.sp,
      onTap: () {},
    );
  }

  Widget _buildMusicButton() {
    return buildStandardButton(
      iconData: Icons.queue_music,
      size: 48.sp,
      onTap: () {},
    );
  }

  Widget _buildTVButton() {
    return buildStandardButton(
      iconData: Icons.live_tv,
      size: 48.sp,
      onTap: () {},
    );
  }

  Widget _buildFloatingVideoButton() {
    return buildStandardButton(
      iconData: Icons.fullscreen_exit,
      size: 48.sp,
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
          _playController.buildPlayButton(
            size: 64.sp,
            onTap: () {
              _playController.handlePlayState();
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 18.w,
              right: 12.w,
            ),
            child: Text(
              getFormatDuration(_playController.position),
              style: TextStyle(
                fontSize: 24.sp,
              ),
            ),
          ),
          Expanded(
            child: _buildProgressIndicator(_playController.controller),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 12.w,
            ),
            child: Text(
              getFormatDuration(_playController.duration),
              style: TextStyle(
                fontSize: 24.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 34.w,
              right: 16.w,
            ),
            child: buildStandardButton(
              iconData: Icons.screen_rotation_rounded,
              size: 40.sp,
              onTap: () {
                _playController.hidePauseToast();
                _playController.setLandscapeScreen();
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
    return DefaultTextStyle(
      style: getStandardStyle(),
      child: Padding(
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
    );
  }
}
