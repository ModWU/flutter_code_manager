import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:video_player/video_player.dart';

import 'static_video_view.dart';

class SecondaryVideoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SecondaryVideoViewState();

  SecondaryVideoView({this.advertUrl, this.url, this.controller})
      : assert(url != null || controller != null);

  final String advertUrl;
  final String url;
  final VideoPlayerController controller;
}

class _SecondaryVideoViewState extends State<SecondaryVideoView> {
  VideoPlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return _buildVideoView();
  }

  Widget _buildVideoView() {
    return VideoView(
      videoUrl: widget.url,
      controller: _controller,
      contentStackBuilder:
          (BuildContext context, VideoPlayerController controller) {
        assert(controller.value != null);
        if (!controller.value.initialized) {
          return [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Text("正在初始化..."),
              ),
            )
          ];
        }

        return [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Text("正在播放..."),
            ),
          ),
        ];
      },
    );
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
