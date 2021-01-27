import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/resources/export.dart';
import 'package:video_list/ui/views/secondary_video_view.dart';
import 'package:video_list/ui/views/static_video_view.dart';
import 'package:video_list/utils/view_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'dart:ui';

const Duration _kDefaultDelayDuration = const Duration(milliseconds: 300);

class BaseVideoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BaseVideoPageState();

  //暂时搞一个video url 和 一个视频控制器
  BaseVideoPage({
    this.videoUrl,
    this.controller,
    this.animation,
    this.onDismissed,
    this.onCompleted,
    this.onReverse,
    this.onForward,
    this.delayDuration = _kDefaultDelayDuration,
  })  : assert(videoUrl != null || controller != null),
        assert(delayDuration != null),
        assert(animation != null);

  final String videoUrl;
  final VideoPlayerController controller;
  final Animation animation;
  final Duration delayDuration;
  final VoidCallback onDismissed;
  final VoidCallback onCompleted;
  final VoidCallback onReverse;
  final VoidCallback onForward;
}

class _BaseVideoPageState extends State<BaseVideoPage> {
  VideoPlayerController _controller;
  @override
  Widget build(BuildContext context) {
    final ColorTween statusColor =
        ColorTween(begin: Colors.transparent, end: Colors.black);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: statusColor.evaluate(widget.animation),
          brightness: Brightness.dark,
        ),
        body: Column(
          children: [
            _buildVideo(),
            Flexible(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                //color: Colors.red,
                child: Text("哈哈哈哈哈哈哈"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVideo() {
    return Container(
      height: Dimens.design_screen_width.w * 0.5,
      width: double.infinity,
      child: SecondaryVideoView(
        url: widget.videoUrl,
        controller: _controller,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      assert(widget.videoUrl != null);
      _controller = VideoPlayerController.network(
        widget.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      _controller = widget.controller;
    }
    widget.animation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          widget.onCompleted?.call();
          break;
        case AnimationStatus.dismissed:
          widget.onDismissed?.call();
          break;
        case AnimationStatus.forward:
          widget.onForward?.call();
          break;
        case AnimationStatus.reverse:
          widget.onReverse?.call();
          break;
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller != _controller) {
      _controller.dispose();
    }
    super.dispose();
  }
}
