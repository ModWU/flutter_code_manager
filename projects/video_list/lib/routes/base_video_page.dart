import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/resources/export.dart';
import 'package:video_list/ui/controller/play_controller.dart';
import 'package:video_list/ui/views/secondary_video_view.dart';
import 'package:video_list/ui/views/static_video_view.dart';
import 'package:video_list/utils/simple_utils.dart';
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

class _BaseVideoPageState extends State<BaseVideoPage>
    with PlayControllerMixin {
  VideoPlayerController _controller;

  @override
  bool get playEnd {
    assert(_controller != null);
    return _controller.value.duration == null ||
        _controller.value.position == _controller.value.duration;
  }

  @override
  VideoPlayerController get controller => _controller;

  @override
  Duration get position {
    assert(_controller != null);
    return _controller.value.position;
  }

  @override
  Duration get duration {
    assert(_controller != null);
    return _controller.value?.duration ?? Duration.zero;
  }

  @override
  bool get initialized {
    assert(_controller != null);
    return _controller.value.initialized;
  }

  @override
  bool get isPlaying {
    assert(_controller != null);
    return _controller.value.initialized && _controller.value.isPlaying;
  }

  void handlePlayState({bool pause, bool isSetState = true}) {
    assert(isSetState != null);
    assert(_controller != null);
    if (playEnd) {
      pause = true;
    }

    final bool oldPause = this.pause;

    changePlayState(pause: pause, isSetState: isSetState);

    if (oldPause == this.pause) return;

    if (this.pause) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorTween statusColor =
        ColorTween(begin: Colors.transparent, end: Colors.black);
    // final Orientation orientation = isPortrait ? ;
    /* MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
        ? Orientation.landscape
        : Orientation.portrait;*/
    // print("base video page build orientaion: $orientation");
    print("base video build isPortrait: $isPortrait");
    return OrientationBuilder(builder: (_, Orientation orientation) {
      return Scaffold(
        appBar: isPortrait
            ? AppBar(
                toolbarHeight: 0,
                elevation: 0,
                backgroundColor: statusColor.evaluate(widget.animation),
                brightness: Brightness.dark,
              )
            : null,
        body: Column(
          children: [
            _buildVideo(),
            if (isPortrait)
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  //color: Colors.red,
                  child: Text("哈哈哈哈哈哈哈"),
                ),
              ),
          ],
        ),
      );
    });

    /*return OrientationBuilder(builder: (_, Orientation orientation) {
      print("base video page build orientation: $orientation");
      orientation = MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height
          ? Orientation.landscape
          : Orientation.portrait;
      print("base video page build orientation2: $orientation");

    });*/
  }

  Widget _buildVideo() {
    print("base video build isPortrait2: $isPortrait");
    return ChangeNotifierProvider.value(
      value: progressControllerNotify,
      child: Container(
        height: isPortrait
            ? Dimens.design_screen_width.w * 0.5
            : Dimens.design_screen_height.h,
        width: double.infinity,
        child: SecondaryVideoView(
          controller: this,
          onBack: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _videoPlayListener() {
    //handlePlayState(pause: false);
    if (!initialized) {
      resetShowActiveWidget(showActiveWidget: true);
      resetActiveTimer();
      handlePlayState(
        pause: true,
        isSetState: false,
      );
    } else if (playEnd) {
      handlePlayState(
        pause: true,
        isSetState: false,
      );
    } else {
      handlePlayState(
        pause: !isPlaying,
        isSetState: false,
      );
    }
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
          _controller.addListener(_videoPlayListener);
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
    /* SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);*/
  }

  @override
  void dispose() {
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);*/
    _controller.removeListener(_videoPlayListener);
    if (widget.controller != _controller) {
      _controller.dispose();
    }
    super.dispose();
  }
}
