import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:video_player/video_player.dart';
import '../../utils/view_utils.dart';
import 'static_video_view.dart';

class SecondaryVideoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SecondaryVideoViewState();

  SecondaryVideoView({this.advertUrl, this.url, this.controller, this.onBack})
      : assert(url != null || controller != null);

  final String advertUrl;
  final String url;
  final VideoPlayerController controller;
  final VoidCallback onBack;
}

class _SecondaryVideoViewState extends State<SecondaryVideoView> {
  VideoPlayerController _controller;
  bool _backHover = false;

  @override
  Widget build(BuildContext context) {
    return _buildVideoView();
  }

  Widget _buildVideoView() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GestureDetector(
        onTap: () {},
        child: VideoView(
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
            assert(controller.value != null);
            return Padding(
              padding: EdgeInsets.only(
                left: 32.w,
                right: 24.w,
                top: 24.w,
                bottom: 24.w,
              ),
              child: Column(
                children: [
                  _buildTopWidget(),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBackIcon() {
    return StatefulBuilder(
      builder: (_, StateSetter setState) {
        return InkWell(
          onTap: () {
            widget.onBack?.call();
          },
          //highlightColor: Colors.black26,
          /*onHighlightChanged: (bool isHighlight) {
            setState(() {
              _backHover = isHighlight;
            });
          },*/
          onTapCancel: () {
            setState(() {
              _backHover = false;
            });
          },
          onTapDown: (TapDownDetails details) {
            setState(() {
              _backHover = true;
            });
          },
          child: Text(
            String.fromCharCode(Icons.arrow_back_ios.codePoint),
            style: TextStyle(
              color: _backHover ? Colors.grey : Colors.white,
              fontFamily: Icons.arrow_back_ios.fontFamily,
              fontSize: 36.sp,
              shadows: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.01, 0.01), //阴影xy轴偏移量
                  blurRadius: 4.0, //阴影模糊程度
                  spreadRadius: 0.0, //阴影扩散程度
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBackIcon(),
      ],
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
