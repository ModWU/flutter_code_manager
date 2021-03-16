import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_list/ui/animations/impliclit_transition.dart';
import 'package:video_list/ui/controller/play_controller.dart';
import 'package:video_list/ui/views/video_indicator.dart';
import 'package:video_list/resources/export.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'secondary_video_view.dart';

const Duration _kDefaultSlideDuration = Duration(milliseconds: 500);

class SecondaryLandscapeVideoLayout extends StatefulWidget {
  SecondaryLandscapeVideoLayout(
    this.playController, {
    Key key,
  })  : assert(playController != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SecondaryLandscapeVideoLayoutState();

  final PlayControllerMixin playController;
}

class _SecondaryLandscapeVideoLayoutState
    extends State<SecondaryLandscapeVideoLayout>
    with VideoUtilsMiXin, SingleTickerProviderStateMixin {
  PlayControllerMixin _playController;
  //动画控制器
  AnimationController _slideController;
  Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _playController = widget.playController;
    _initAnimation();

    _playController.addActiveWidgetListener(_onActiveWidgetListener);
    /*_promptVideoPlayerController = VideoPlayerController.network(
      _playController.controller.dataSource,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize();*/
    _initPlayState();
  }

  void _initPlayState() {
    assert(_playController != null);
    _playController.resetActiveTimer();
    if (_playController.pause) _playController.handlePlayState(pause: false);
  }

  void _onActiveWidgetListener(bool showActiveWidget) {
    assert(showActiveWidget != null);
    assert(_slideController != null);
    if (showActiveWidget) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _initAnimation() {
    //Tween(begin: Offset(0, -1), end: Offset(0, 0))
    _slideController =
        AnimationController(duration: _kDefaultSlideDuration, vsync: this)
          ..value = 1.0;
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    );
  }

  void _disposeAnimation() {
    _slideController.dispose();
  }

  @override
  void dispose() {
    _disposeAnimation();
    _playController.removeActiveWidgetListener(_onActiveWidgetListener);
    //_promptVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: DefaultTextStyle(
        style: getStandardStyle(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBulletScreen(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildVideoInnerWidget(),
                  _buildVideoOuterWidget(),
                ],
              ),
            ),
            _buildProgressPrompt(),
          ],
        ),
      ),
    );
  }

  ProgressValueState _oldValueState = ProgressValueState.nothing;

  Offset _computerPromptPosition(
      ProgressControllerNotify progressControllerNotify) {
    assert(progressControllerNotify != null);

    print("_computerPromptPosition======>value:${progressControllerNotify.currentValue}  state:${progressControllerNotify.state}  newValueState:[reducing:${progressControllerNotify.reducing()} increasing:${progressControllerNotify.increasing()}] oldValueState: $_oldValueState");

    Offset position;
    if (progressControllerNotify.state == ProgressControllerState.down ||
        progressControllerNotify.state == ProgressControllerState.startDrag) {
      _oldValueState = ProgressValueState.nothing;
      position = progressControllerNotify.isTouchBar
          ? Offset.zero
          : (progressControllerNotify.increasing()
              ? Offset(-0.06, 0)
              : (progressControllerNotify.reducing()
                  ? Offset(0.06, 0)
                  : Offset.zero));
    } else if (progressControllerNotify.state == ProgressControllerState.up ||
        progressControllerNotify.state == ProgressControllerState.endDrag) {
      position = Offset.zero;
    } else {
      if (progressControllerNotify.increasing()) {
        position = Offset(0.06, 0);
        _oldValueState = ProgressValueState.increase;
      } else if (progressControllerNotify.reducing()) {
        position = Offset(-0.06, 0);
        _oldValueState = ProgressValueState.reduce;
      } else {
        if (_oldValueState == null ||
            _oldValueState == ProgressValueState.nothing) {
          position = Offset.zero;
        } else {
          if (_oldValueState == ProgressValueState.increase) {
            position = Offset(0.06, 0);
          } else {
            position = Offset(-0.06, 0);
          }
        }
      }
    }

    assert(position != null);
    return position;
  }

  //VideoPlayerController _promptVideoPlayerController;

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

      /*if (_promptVideoPlayerController.value.initialized) {
        _promptVideoPlayerController.value =
            _playController.controller.value.copyWith();
        _promptVideoPlayerController.seekTo(
            _playController.duration * progressControllerNotify.currentValue);
      }*/

      return Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: !isShow,
            child: Container(
              color: Colors.black26,
            ),
          ),
          Positioned(
            top: 240.h,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedTranslation(
                position: _computerPromptPosition(progressControllerNotify),
                duration: const Duration(milliseconds: 300),
                opacity: isShow ? 1.0 : 0.0,
                hideOpacityAnimation: isShow,
                curve: Curves.easeIn,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      //shadowColor: Colors.transparent,
                      //elevation: 0.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 300.h,
                          width: 480.h,
                          color: Colors.grey,
                          /*child: AspectRatio(
                            aspectRatio:
                                _promptVideoPlayerController.value.aspectRatio,
                            child: VideoPlayer(_promptVideoPlayerController),
                          ),*/
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 36.h,
                      ),
                      child: Text(
                        getFormatDuration(
                            Duration(seconds: progressControllerNotify.currentValue)),
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

      /*return Offstage(
        offstage: !(progressControllerNotify
                .isHasState(ProgressControllerState.down) ||
            progressControllerNotify
                .isHasState(ProgressControllerState.startDrag)),
        child: Container(
          color: Color(0x55000000),
          padding: EdgeInsets.only(
            top: 240.h,
          ),
          alignment: Alignment.topCenter,
          child: AnimatedTranslation(
            position: position,
            duration: const Duration(milliseconds: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  //shadowColor: Colors.transparent,
                  //elevation: 0.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 300.h,
                      width: 480.h,
                      color: Colors.grey,
                      child: AspectRatio(
                        aspectRatio:
                            _playController.controller.value.aspectRatio,
                        child: VideoPlayer(_playController.controller),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 36.h,
                  ),
                  child: Text(
                    getFormatDuration(_playController.duration *
                        progressControllerNotify.currentValue),
                    style: TextStyle(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );*/
    });
  }

  Widget _buildBulletScreen() {
    return Column(
      children: [
        Text(
          "我是弹幕..",
        ),
        Padding(
          padding: EdgeInsets.only(left: 40),
          child: Text(
            "我是弹幕..2222..",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 40, top: 50),
          child: Text(
            "我是弹幕..f454.5555555555555.",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 360, top: 50),
          child: Text(
            "我是弹幕..我是弹幕..我是弹幕66666666666666666..",
          ),
        )
      ],
    );
    //return Visibility(child: child)
  }

  Widget _buildLockButton() {
    return Text(
      String.fromCharCode(Icons.lock_open_rounded.codePoint),
      style: TextStyle(
        fontFamily: Icons.lock_open_rounded.fontFamily,
        fontSize: 28.sp,
      ),
    );
  }

  Widget _buildVideoOuterWidget() {
    return Offstage(
      offstage: !_playController.showActiveWidget,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildShadowMask(
            color: Colors.black12,
            child: _buildStatusBar(),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLockButton(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildStandardButton(
                          iconData: Icons.camera_alt_outlined,
                          size: 28.sp,
                          onTap: () {},
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 48,
                          ),
                          child: buildStandardButton(
                            iconData: Icons.photo_camera_front,
                            size: 28.sp,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GlobalKey _centerProgressControllerKey = GlobalKey();

  Widget _buildVideoInnerWidget() {
    return Column(
      children: [
        _buildVideoTitle(),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _playController
                  .buildProgressControllerWidget(_centerProgressControllerKey),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildVideoController(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackIconAndTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildStandardButton(
          iconData: Icons.arrow_back_ios,
          size: 20.sp,
          onTap: () {
            _playController.hidePauseToast();
            _playController.setPortraitScreen();
          },
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 8,
          ),
          child: Text(
            "山海情[原声版]第13集",
            style: TextStyle(
              fontSize: 16.sp,
              //ontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTopButtons() {
    return SizedBox(
      width: 220.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStandardButton(
            iconData: Icons.hdr_on_rounded,
            size: 28.sp,
            onTap: () {},
          ),
          buildStandardButton(
            iconData: Icons.live_tv,
            size: 28.sp,
            onTap: () {},
          ),
          buildStandardButton(
            iconData: Icons.format_list_bulleted_rounded,
            color: Color(0xFFFF6633),
            size: 28.sp,
            onTap: () {},
          ),
          buildStandardButton(
            iconData: Icons.chat,
            size: 28.sp,
            onTap: () {},
          ),
          buildStandardButton(
            iconData: Icons.more_horiz_rounded,
            size: 28.sp,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTitle() {
    return FadeTransition(
      opacity: _slideAnimation,
      child: SlideTransition(
        position: Tween(begin: Offset(0, -1), end: Offset.zero)
            .animate(_slideAnimation),
        child: _buildShadowMask(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 100.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBackIconAndTitle(),
                _buildTopButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoController() {
    return FadeTransition(
      opacity: _slideAnimation,
      child: SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset.zero)
            .animate(_slideAnimation),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: _buildShadowMask(
                  reverse: true,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h),
              child: Column(
                children: [
                  _buildProgressTimer(),
                  _buildProgressIndicator(),
                  _buildProgressController(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressController() {
    /*return Padding(
      padding: EdgeInsets.only(bottom: 56.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLeftControllerButton(),
          _buildRightControllerButton(),
        ],
      ),
    );*/
    final int leftFlex = 3;
    final int centerFlex = 10;
    final int rightFlex = 6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildLeftControllerButton(),
                flex: leftFlex,
              ),
              Spacer(
                flex: centerFlex,
              ),
              Expanded(
                child: _buildRightControllerButton(),
                flex: rightFlex,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 56.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: Colors.transparent,
                ),
                flex: leftFlex,
              ),
              Spacer(
                flex: centerFlex,
              ),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                ),
                flex: rightFlex,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /* Widget Loading() {
    //宽度是确定的，高度是由最大孩子的高度决定
    return Row(
      children: [
        Text("child1", style: TextStyle(fontSize: 36),),
        //child2
        Text("child3", style: TextStyle(fontSize: 24),),
      ],
    );
  }*/

  Widget _buildLeftControllerButton() {
    return IntrinsicHeight(
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _playController.handlePlayState();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: _playController.buildPlayButton(
                size: 36.sp,
                onTap: () {
                  _playController.handlePlayState();
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
            ),
          ),
          buildStandardButton(
            iconData: Icons.fast_forward_rounded,
            size: 36.sp,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRightControllerButton() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: AbsorbPointer(
            absorbing: true,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            right: 14.w,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildStandardButton(
                iconData: Icons.edit,
                size: 22.sp,
                onTap: () {},
              ),
              buildStandardButton(
                text: "倍速",
                size: 15.sp,
                onTap: () {},
              ),
              buildStandardButton(
                iconData: Icons.hdr_enhanced_select,
                size: 22.sp,
                onTap: () {},
              ),
              buildStandardButton(
                text: "选集",
                size: 15.sp,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTimer() {
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(
          left: 14.w,
          right: 14.w,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(getFormatDuration(_playController.position)),
            Text(getFormatDuration(_playController.duration)),
          ],
        ),
      ),
    );
  }

  GlobalKey _progressKey = GlobalKey();

  Widget _buildProgressIndicator() {
    return _playController.buildProgressIndicator(
      progressKey: _progressKey,
      child: Consumer(
        builder: (BuildContext context,
            ProgressControllerNotify progressControllerNotify, Widget child) {
          return Padding(
            padding: EdgeInsets.only(top: 24.h, bottom: 56.h),
            child: VideoProgressOwnerIndicator(
              _playController.controller,
              progressKey: _progressKey,
              showSign: true,
              allowScrubbing: true,
              showSignHalo: progressControllerNotify
                  .isHasState(ProgressControllerState.startDrag),
              stop: progressControllerNotify
                      .isHasState(ProgressControllerState.down) ||
                  progressControllerNotify
                      .isHasState(ProgressControllerState.startDrag),
              positionPercent:
                  progressControllerNotify.state == ProgressControllerState.down
                      ? null
                      : progressControllerNotify.percent,
              bufferingMillisecond: 1000,
              bufferingSpeedMillisecond: 0,
              signHaloAnimationDuration: const Duration(milliseconds: 400),
              minHeight: 2.8,
              signHaloRadius: 86.h,
              padding: EdgeInsets.zero,
              colors: VideoProgressColors(
                playedColor: Color(0xFFFF6633),
                backgroundColor: Colors.black26,
                bufferedColor: Colors.blueGrey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShadowMask(
      {Widget child, Color color = Colors.black54, bool reverse = false}) {
    assert(color != null);
    assert(reverse != null);
    final Widget childWidget = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.all(Radius.circular(28)),
        // border: Border.all(color: Color(0xFFFF0000), width: 0),
        shape: BoxShape.rectangle,
        color: color,
        gradient: LinearGradient(
          begin: reverse ? Alignment.bottomCenter : Alignment.topCenter,
          end: reverse
              ? Alignment.topCenter
              : Alignment
                  .bottomCenter, // 10% of the width, so there are ten blinds.
          colors: [
            Colors.black,
            Colors.transparent,
          ], // whitish to gray
          tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      child: child,
    );
    return child == null
        ? Center(
            child: childWidget,
          )
        : childWidget;
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: EdgeInsets.only(left: 18.w),
      child: SizedBox(
        width: double.infinity,
        height: 100.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Wi-Fi"),
            Text("4.05"),
            Icon(
              Icons.battery_alert_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
