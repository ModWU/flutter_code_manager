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
import 'static_video_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Duration _kPlayButtonAnimationDuration = Duration(milliseconds: 300);
const Duration _kPlayActiveDuration = Duration(seconds: 5);

mixin VideoToastMiXin<T extends StatefulWidget> on State<T> {
  FToast _fToast;

  @override
  void initState() {
    super.initState();
    _fToast = FToast();
    _fToast.init(context);
  }

  @override
  void dispose() {
    assert(_fToast != null);
    Fluttertoast.cancel();
    _fToast.removeQueuedCustomToasts();
    super.dispose();
  }

  void hidePauseToast() {
    assert(_fToast != null);
    Fluttertoast.cancel();
    _fToast.removeQueuedCustomToasts();
  }

  void showPauseToast(GlobalKey _sizeKey, {bool hasStatusBar = true}) {
    assert(_fToast != null);
    assert(_sizeKey != null);
    assert(hasStatusBar != null);
    // Custom Toast Position
    final RenderBox videoSizeRenderBox =
        _sizeKey.currentContext?.findRenderObject();
    assert(videoSizeRenderBox != null);
    final Size videoSize = videoSizeRenderBox.size;
    assert(videoSize != null);
    final Size toastSize = Size(160.w, 80.w);

    final double leftOffset = (videoSize.width - toastSize.width) / 2;
    final double topOffset =
        (hasStatusBar ? MediaQueryData.fromWindow(window).padding.top : 0) +
            (videoSize.height - toastSize.height) / 2;
    _fToast.showToast(
      child: buildIconText(
        icon: Icon(
          Icons.pause,
          color: Colors.white,
          size: 42.sp,
        ),
        text: Text(
          Strings.toast_video_pause,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
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
            Radius.circular(10.w),
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

class _SecondaryVideoViewState extends State<SecondaryVideoView> {
  VideoPlayerController _controller;
//_buildVideoView(orientation)
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        orientation = MediaQuery.of(context).size.width >
                MediaQuery.of(context).size.height
            ? Orientation.landscape
            : Orientation.portrait;
        print("orientation: $orientation");
        return _buildVideoView(orientation);
      },
    );
  }

  /*bool _isPlayEnd() {
    assert(_controller != null);
    return _controller.value.duration == null ||
        _controller.value.position == _controller.value.duration;
  }*/

  Widget _buildVideoView(Orientation orientation) {
    assert(orientation != null);
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return VideoView(
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
          return orientation == Orientation.portrait
              ? SecondaryPortraitVideoLayout(
                  controller: controller,
                  onBack: widget.onBack,
                )
              : Center(
                  child: Text(
                    "田读帅，你在看吗？我是横屏，我还没被实现呢！",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                    ),
                  ),
                );
        },
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
}
