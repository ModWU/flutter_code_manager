import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/ui/animations/impliclit_transition.dart';
import 'package:video_list/ui/controller/play_controller.dart';
import 'package:video_list/ui/views/video_indicator.dart';
import 'package:video_list/ui/views/video_indicator_impl.dart';
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

  GlobalKey _progressKey = GlobalKey();

  final double _bottomHeight = 80.h;

  @override
  void initState() {
    super.initState();
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
      child: ClipRect(
        child: Column(
          children: [
            _buildTopActiveWidget(),
            _buildCenterActiveWidget(),
            _buildBottomActiveWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWidget() {
    return Positioned(
      left: 8.0,
      top: 0.0,
      child: GestureDetector(
        onTap: () {
          widget.onBack?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 80.h,
          width: 80.h,
          //color: Colors.yellow,
          alignment: Alignment.center,
          child: buildStandardButton(
            iconData: Icons.arrow_back_ios,
            size: 36.sp,
            onTap: () {
              widget.onBack?.call();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        _playController.handlePlayState();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(left: 8),
        child: _playController.buildPlayButton(
          size: 64.sp,
        ),
      ),
    );
  }

  Widget _buildRotateButton() {
    return GestureDetector(
      onTap: () {
        _playController.hidePauseToast();
        _playController.setLandscapeScreen();
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
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
      ),
    );
  }

  Widget _buildProgressPrompt() {
    return Consumer(builder: (BuildContext context,
        ProgressControllerNotify progressControllerNotify, Widget child) {
      final bool isShow = progressControllerNotify.isTouchBar
          ? (progressControllerNotify
                  .isHasState(ProgressControllerState.down) ||
              progressControllerNotify
                  .isHasState(ProgressControllerState.startDrag))
          : progressControllerNotify
              .isHasState(ProgressControllerState.startDrag);
      return Offstage(
        offstage: !isShow,
        child: Container(
          color: Color(0x55000000),
          padding: EdgeInsets.only(
            top: 108.h,
          ),
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getFormatDuration(Duration(seconds: progressControllerNotify.currentValue)),
                style: TextStyle(
                  fontSize: 62.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 26.h),
                child: SizedBox(
                  width: 240.w,
                  child: LinearVideoProgressIndicator(
                    value: progressControllerNotify.percent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 1.8,
                    radius: Radius.circular(1.8),
                    backgroundColor: Colors.grey,
                    //backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /*Widget _buildProgressIndicator(VideoPlayerController controller) {
    assert(controller != null);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _playController.progressControllerNotify.change(
          currentValue: _playController.getBoxPositionPercent(
              _progressKey, details.globalPosition),
          state: ProgressControllerState.startDrag,
        );
        _playController.blockActiveTimer();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _playController.progressControllerNotify.change(
          currentValue: _playController.getBoxPositionPercent(
              _progressKey, details.globalPosition),
          state: ProgressControllerState.dragging,
        );
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        //end 和 down不会同时执行
        if (!controller.value.initialized) {
          return;
        }
        _downingTime = null;
        _playController
            .setDragPositionAndNotify(ProgressControllerState.endDrag);
        controller.play();
        _playController.unblockActiveTimer();
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _downingTime = _playController.position;
        _playController.progressControllerNotify.change(
          currentValue: _playController.getBoxPositionPercent(
              _progressKey, details.globalPosition),
          state: ProgressControllerState.down,
        );
        _playController.blockActiveTimer();
      },
      onTapUp: (TapUpDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _downingTime = null;
        //忽略抬起的位置
        _playController.setDragPositionAndNotify(ProgressControllerState.up);
        controller.play();
        _playController.unblockActiveTimer();
      },
      child: Center(
        child: Consumer(
          builder: (BuildContext context,
              ProgressControllerNotify progressControllerNotify, Widget child) {
            return VideoProgressOwnerIndicator(
              controller,
              allowScrubbing: true,
              showSign: true,
              showSignShade: true,
              showSignHalo: progressControllerNotify
                  .isHasState(ProgressControllerState.startDrag),
              progressKey: _progressKey,
              stop: progressControllerNotify
                      .isHasState(ProgressControllerState.down) ||
                  progressControllerNotify
                      .isHasState(ProgressControllerState.startDrag),
              //minHeight: 50.h,
              positionPercent:
                  progressControllerNotify.state == ProgressControllerState.down
                      ? null
                      : progressControllerNotify.currentValue,
              bufferingMillisecond: 1000,
              bufferingSpeedMillisecond: 0,
              padding: EdgeInsets.zero,
              colors: VideoProgressColors(
                playedColor: Color(0xFFFF6633),
                backgroundColor: Colors.black26,
                bufferedColor: Colors.blueGrey,
              ),
            );
          },
        ),
      ),
    );
  }*/

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
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: 80.h,
        width: 260.w,
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //mainAxisSize: MainAxisSize.min,
          children: [
            _buildTVButton(),
            _buildMusicButton(),
            _buildMoreButton(),
          ],
        ),
      ),
    );
    /* return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: ,
    );*/
  }

  Widget _buildProgressIndicator() {
    assert(_playController.controller != null);
    return Center(
      child: Consumer(
        builder: (BuildContext context,
            ProgressControllerNotify progressControllerNotify, Widget child) {
          return VideoProgressOwnerIndicator(
            _playController.controller,
            allowScrubbing: true,
            showSign: true,
            showSignShade: true,
            showSignHalo: progressControllerNotify
                .isHasState(ProgressControllerState.startDrag),
            progressKey: _progressKey,
            stop: progressControllerNotify
                    .isHasState(ProgressControllerState.down) ||
                progressControllerNotify
                    .isHasState(ProgressControllerState.startDrag),
            //minHeight: 50.h,
            positionPercent:
                progressControllerNotify.state == ProgressControllerState.down
                    ? null
                    : progressControllerNotify.percent,
            bufferingMillisecond: 1000,
            bufferingSpeedMillisecond: 0,
            padding: EdgeInsets.zero,
            colors: VideoProgressColors(
              playedColor: Color(0xFFFF6633),
              backgroundColor: Colors.black26,
              bufferedColor: Colors.blueGrey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActiveWidget() {
    return Container(
      height: _bottomHeight,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPlayButton(),
          Padding(
            padding: EdgeInsets.only(
              left: 18.w,
              right: 12.w,
            ),
            child: Consumer(
              builder: (BuildContext context,
                  ProgressControllerNotify progressControllerNotify,
                  Widget child) {
                final bool hasDrag = progressControllerNotify
                        .isHasState(ProgressControllerState.down) ||
                    progressControllerNotify
                        .isHasState(ProgressControllerState.startDrag);
                final bool downing = progressControllerNotify.state ==
                    ProgressControllerState.down;
                assert(!downing ||
                    progressControllerNotify.downPositionValue != null);
                return Text(
                  hasDrag
                      ? (downing
                          ? getFormatDuration(Duration(
                              seconds:
                                  progressControllerNotify.downPositionValue))
                          : getFormatDuration(Duration(
                              seconds: progressControllerNotify.currentValue)))
                      : getFormatDuration(_playController.position),
                  style: TextStyle(
                    fontSize: 24.sp,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _playController.buildProgressIndicator(
              progressKey: _progressKey,
              child: _buildProgressIndicator(),
            ),
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
            ),
            child: _buildRotateButton(),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant SecondaryPortraitVideoLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  GlobalKey _centerProgressControllerKey = GlobalKey();

  Widget _buildProgressControllerWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _bottomHeight),
      child: _playController
          .buildProgressControllerWidget(_centerProgressControllerKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: getStandardStyle(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildActiveWidget(),
          _buildTopWidget(),
          _buildProgressControllerWidget(),
          _buildProgressPrompt(),
        ],
      ),
    );
  }
}
