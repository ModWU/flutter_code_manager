import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_list/examples/video_indicator.dart';
import 'package:video_list/resources/res/strings.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';
import '../ui/utils/circular_utils.dart' as CircularUtils;
import 'dart:async';

enum PlayState {
  start,
  resume,
  pause,
  end,
}

enum _InitState {
  have_already,
  just_already,
}

typedef ContentStackBuilder = List<Widget> Function(
    BuildContext context, VideoPlayerController controller);

class VideoView extends StatefulWidget {
  VideoView({
    this.videoUrl,
    this.controller,
    this.contentStackBuilder,
    this.playState = PlayState.start,
  })  : assert(videoUrl != null || controller != null),
        assert(playState != null);

  @override
  State<StatefulWidget> createState() => _VideoViewState();

  final String videoUrl;
  final VideoPlayerController controller;
  final PlayState playState;
  final ContentStackBuilder contentStackBuilder;
}

class _VideoViewState extends State<VideoView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  VideoPlayerController _videoController;

  @override
  void didUpdateWidget(VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_videoController != null) {
      final String oldVideoUrl = _videoController.dataSource;
      final String newVideoUrl =
          widget.controller?.dataSource ?? widget.videoUrl;
      assert(newVideoUrl != null);
      assert(oldVideoUrl != null);
      if (newVideoUrl != oldVideoUrl ||
          (widget.controller != null &&
              widget.controller != _videoController)) {
        _initController();
      } else {
        _handleStateAfterInit(_InitState.have_already);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print(
          "AdvertView didChangeAppLifecycleState -> paused 已经暂停了，用户不可见、不可操作ui");
      _pauseControllerWithLifecycle();
    } else if (state == AppLifecycleState.resumed) {
      print("AdvertView didChangeAppLifecycleState -> resumed 应用可见并可响应用户操作");
      _resumeControllerWithLifecycle();
    } else if (state == AppLifecycleState.detached) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.detached 操作不了ui并且销毁");
      _destroyController();
    } else if (state == AppLifecycleState.inactive) {
      print("AdvertView didChangeAppLifecycleState -> inactive 用户可见，可以响应用户操作");
      _pauseControllerWithLifecycle();
    }
  }

  bool _needReplay = false;

  void _pauseControllerWithLifecycle() {
    print(
        "AdvertView _pauseController -> isPlaying: ${_videoController.value.isPlaying}");
    if (_pauseControllerWithoutListener()) {
      _needReplay = true;
    }
  }

  void _resumeControllerWithLifecycle() {
    _videoController.addListener(_controllerEvent);
    if (_needReplay) {
      _videoController.play();
      _needReplay = false;
    }
  }

  bool _pauseControllerWithoutListener() {
    bool isPause = false;
    if (_videoController.value.isPlaying) {
      _videoController.pause();
      isPause = true;
    }

    _videoController.removeListener(_controllerEvent);
    return isPause;
  }

  @override
  void deactivate() {
    print('_AdvertViewState => deactivate');
    _pauseControllerWithoutListener();
    super.deactivate();
  }

  @override
  void dispose() {
    print('_AdvertViewState => dispose');
    _destroyController();
    super.dispose();
  }

  void _controllerEvent() {
    setState(() {});
  }

  void _destroyController() {
    print(
        "AdvertView _destroyController -> _videoController: ${_videoController}");
    _pauseControllerWithoutListener();
    if (widget.controller == null) _videoController.dispose();

    _videoController = null;
  }

  Future<void> _handleStateAfterInit(_InitState initState) async {
    assert(widget.playState != null);
    print(
        "AdvertView _handleStateAfterInit -> initState: ${initState.toString()}, playState: ${widget.playState.toString()}");
    switch (widget.playState) {
      case PlayState.start:
        if (initState != _InitState.just_already) {
          _videoController.seekTo(Duration.zero);
          // _videoController.pause();
          // _videoController.value = _videoController.value.copyWith(duration: Duration.zero);
        }
        break;

      case PlayState.resume:
        if (!_videoController.value.isPlaying) _videoController.play();
        break;

      case PlayState.pause:
        if (_videoController.value.isPlaying) _videoController.pause();
        break;

      case PlayState.end:
        if (_videoController.value.position != _videoController.value.duration)
          _videoController.seekTo(_videoController.value.duration);
        break;
    }
  }

  Future<_InitState> _initFinished(_) async {
    return _InitState.just_already;
  }

  //重新初始化,初始化过了就忽略
  void _initController() {
    if (_videoController != null) {
      final String oldVideoUrl = _videoController.dataSource;
      final String newVideoUrl =
          widget.controller?.dataSource ?? widget.videoUrl;
      if (oldVideoUrl == newVideoUrl &&
          (widget.controller == null ||
              widget.controller == _videoController)) {
        _pauseControllerWithoutListener();
        _videoController.addListener(_controllerEvent);
        if (!_videoController.value.initialized) {
          _videoController
              .initialize()
              .then(_initFinished)
              .then(_handleStateAfterInit);
        } else {
          _handleStateAfterInit(_InitState.have_already);
        }
        return;
      }
      _pauseControllerWithoutListener();
      _videoController.dispose();
    }

    if (widget.controller != null)
      _videoController = widget.controller;
    else {
      _videoController = VideoPlayerController.network(
        widget.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }

    _videoController.addListener(_controllerEvent);

    _videoController.setLooping(false);
    if (!_videoController.value.initialized) {
      _videoController
          .initialize()
          .then(_initFinished)
          .then(_handleStateAfterInit);
    } else {
      _handleStateAfterInit(_InitState.have_already);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  /*Widget _buildAdvertRightTitle() {
    return Positioned(
        right: 0,
        top: 0,
        child: CircularUtils.getTextSpanContainer(
            TextSpan(text: Strings.advert_txt, children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 26.sp,
                ),
                style: TextStyle(
                  letterSpacing: -1,
                ),
              ),
            ]), onTap: () {
          print("点击${Strings.advert_txt}");
        },
            fontSize: 20.sp,
            textColor: Colors.white,
            backgroundColor: Color(0x33000000),
            verticalSpace: 14.w, //14.w,
            horizontalInvisibleSpace: 12.w,
            verticalInvisibleSpace: 12.w,
            invisibleSpaceClickable: true,
            horizontalSpace: 18.w) //18.w),
        );
  }*/

  Widget _buildAdvertRightTitle() {
    return Chip(
      label: Container(
        color: Colors.red,
        child: Text(
          '老孟',
          style: TextStyle(fontSize: 12),
        ),
      ),
      labelPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      // padding: EdgeInsets.zero,
      deleteIcon: Icon(
        Icons.keyboard_arrow_down,
        size: 18,
      ),
      //deleteIconColor: Colors.blue,
      //deleteButtonTooltipMessage: '删除',
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final List<Widget> stackList = widget.contentStackBuilder?.call(context, _videoController);
    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_videoController),
          if (stackList != null)
            ...stackList,
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
