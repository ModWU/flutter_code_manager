import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_list/ui/views/video_indicator.dart';
import 'package:video_list/resources/export.dart';
import 'package:video_list/utils/simple_utils.dart';
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
    _initPlayState();
  }

  void _initPlayState() {
    assert(_playController != null);
    print("111111111111${_playController.showActiveWidget}");
    _playController.resetActiveTimer();
    print("22222222222${_playController.showActiveWidget}");
    if (_playController.pause) _playController.handlePlayState(pause: false);
  }

  void _onActiveWidgetListener(bool showActiveWidget) {
    assert(showActiveWidget != null);
    assert(_slideController != null);
    print("11showActiveWidget: $showActiveWidget");
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
            _buildVideoInnerWidget(),
            _buildVideoOuterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletScreen() {
    return Text("弹幕..");
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
              padding: EdgeInsets.symmetric(horizontal: 62.w),
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

  Widget _buildVideoInnerWidget() {
    return Column(
      children: [
        _buildVideoTitle(),
        Spacer(),
        _buildVideoController(),
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
            setPortraitScreen();
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
            padding: EdgeInsets.symmetric(horizontal: 66.w, vertical: 100.h),
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
        child: _buildShadowMask(
          reverse: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 62.h),
            child: Column(
              children: [
                _buildProgressTimer(),
                _buildProgressIndicator(),
                _buildProgressController(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressController() {
    return Padding(
      padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 52.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLeftControllerButton(),
          _buildRightControllerButton(),
        ],
      ),
    );
  }

  Widget _buildLeftControllerButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _playController.buildPlayButton(
          size: 28.sp,
          onTap: () {
            print("ddddddd");
            _playController.handlePlayState();
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: buildStandardButton(
            iconData: Icons.fast_forward_rounded,
            size: 28.sp,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildRightControllerButton() {
    return SizedBox(
      width: 200.w,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStandardButton(
            iconData: Icons.edit,
            size: 23.sp,
            onTap: () {},
          ),
          buildStandardButton(
            text: "倍速",
            size: 16.sp,
            onTap: () {},
          ),
          buildStandardButton(
            iconData: Icons.hdr_enhanced_select,
            size: 23.sp,
            onTap: () {},
          ),
          buildStandardButton(
            text: "选集",
            size: 16.sp,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimer() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.h,
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
    );
  }

  Widget _buildProgressIndicator() {
    return VideoProgressOwnerIndicator(
      _playController.controller,
      allowScrubbing: false,
      minHeight: 2.2,
      padding: EdgeInsets.zero,
      colors: VideoProgressColors(
        playedColor: Color(0xFFFF6633),
        backgroundColor: Colors.black26,
        bufferedColor: Colors.blueGrey,
      ),
    );
  }

  Widget _buildShadowMask(
      {Widget child, Color color = Colors.black54, bool reverse = false}) {
    assert(child != null);
    assert(color != null);
    assert(reverse != null);
    return Container(
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
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 62.w,
      ),
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
