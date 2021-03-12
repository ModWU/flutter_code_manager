import 'package:flutter/material.dart';
import 'package:video_list/constants/error_code.dart';
import 'package:video_list/utils/network_utils.dart';
import 'package:video_list/utils/simple_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:video_list/utils/view_utils.dart' as ViewUtils;
import 'dart:async';

enum PlayState {
  startAndPlay,
  startAndPause,
  resume,
  pause,
  continuePlay,
  end,
}

extension PlayStateExtension on PlayState {
  bool isPlaying() {
    return this == PlayState.startAndPlay ||
        this == PlayState.resume ||
        this == PlayState.continuePlay;
  }

  PlayState keepPlayState() {
    if (this == PlayState.startAndPlay) return PlayState.resume;

    //if (this == PlayState.startAndPause) return PlayState.pause;

    return this;
  }

  bool isEnd() {
    return this == PlayState.end;
  }

  bool isPause() {
    return this == PlayState.pause ||
        this == PlayState.startAndPause ||
        this == PlayState.end;
  }
}

enum _InitState {
  have_already,
  just_already,
}

typedef ContentStackBuilder = dynamic Function(
    BuildContext context, VideoPlayerController controller);

typedef VideoErrorWidgetBuilder = Widget Function(
  BuildContext context,
  Object error,
);

class VideoView extends StatefulWidget {
  VideoView({
    Key key,
    this.videoUrl,
    this.controller,
    this.contentStackBuilder,
    this.contentFit = StackFit.loose,
    this.errorBuilder,
    this.padding,
    this.paddingColor = Colors.black,
    this.playState,
  })  : assert(videoUrl != null || controller != null),
        assert(contentFit != null),
        assert(paddingColor != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoViewState();

  final String videoUrl;
  final VideoPlayerController controller;
  final PlayState playState;
  final ContentStackBuilder contentStackBuilder;
  final StackFit contentFit;
  final VideoErrorWidgetBuilder errorBuilder;
  final EdgeInsetsGeometry padding;
  final Color paddingColor;
}

class _VideoViewState extends State<VideoView>
    with WidgetsBindingObserver, NetworkStateMiXin {
  VideoPlayerController _videoController;
  bool _isPlayError = false;
  bool _isNetworkConnectivityError = false;
  bool _isPlayPrepare = false;

  String _getNewVideoUrl() {
    final String oldVideoUrl = _videoController.dataSource;
    assert(oldVideoUrl != null);

    String newVideoUrl = widget.videoUrl; //优先以videoUrl为准

    if ((newVideoUrl == null || newVideoUrl == oldVideoUrl) &&
        widget.controller?.dataSource != null) {
      newVideoUrl = widget.controller.dataSource;
    }
    return newVideoUrl;
  }

  @override
  void didUpdateWidget(VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_videoController != null) {
      final String oldVideoUrl = _videoController.dataSource;
      final String newVideoUrl = _getNewVideoUrl(); //优先以videoUrl为准

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
          "AdvertView didChangeAppLifecycleState ${this.hashCode} -> paused 已经暂停了，用户不可见、不可操作ui");
      _pauseControllerWithLifecycle();
    } else if (state == AppLifecycleState.resumed) {
      print(
          "AdvertView didChangeAppLifecycleState ${this.hashCode} -> resumed 应用可见并可响应用户操作");
      _resumeControllerWithLifecycle();
    } else if (state == AppLifecycleState.detached) {
      print(
          "AdvertView didChangeAppLifecycleState ${this.hashCode} -> AppLifecycleState.detached 操作不了ui并且销毁");
      //_destroyController();
    } else if (state == AppLifecycleState.inactive) {
      print(
          "AdvertView didChangeAppLifecycleState ${this.hashCode} -> inactive 用户可见，可以响应用户操作");
      // _pauseControllerWithLifecycle();
    }
  }

  bool _needReplay = false;

  void _pauseControllerWithLifecycle() {
    print(
        "AdvertView _pauseControllerWithLifecycle -> isPlaying: ${_videoController.value.isPlaying}");
    if (_pauseControllerWithoutListener()) {
      _needReplay = true;
    }
  }

  void _resumeControllerWithLifecycle() {
    _videoController.removeListener(_controllerEvent);
    _videoController.addListener(_controllerEvent);
    if (_needReplay) {
      _videoController.play();
      _needReplay = false;
    }
  }

  bool _pauseControllerWithoutListener() {
    bool isPause = false;

    _videoController.removeListener(_controllerEvent);

    if (_videoController.value.isPlaying) {
      _videoController.pause();
      isPause = true;
    }
    return isPause;
  }

  @override
  void onNetworkChange() {
    _isNetworkConnectivityError = !hasNetwork;
    if (!_isNetworkConnectivityError) {
      _isPlayError = false;
      _initController();
    }
  }

  @override
  void deactivate() {
    print('_VideoViewState => deactivate');
    _pauseControllerWithoutListener();
    super.deactivate();
  }

  @override
  void dispose() {
    print('_VideoViewState => dispose');
    WidgetsBinding.instance.removeObserver(this);
    _destroyController();
    super.dispose();
  }

  Duration _playPosition = Duration.zero;

  Duration _getMaxBuffering() {
    assert(_videoController != null);
    assert(_videoController.value?.buffered != null);
    Duration maxBuffering = Duration.zero;
    for (DurationRange range in _videoController.value.buffered) {
      final Duration end = range.end;
      if (end > maxBuffering) {
        maxBuffering = end;
      }
    }
    return maxBuffering;
  }

  void _controllerEvent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_videoController.value.initialized) return;

      if (_videoController.value.position != Duration.zero) {
        _playPosition = _videoController.value.position;
        print("记录位置 _playPosition:$_playPosition");
      }

      if (_isPlayPrepare && _videoController.value.duration == null) {
        print(
            "播放错误 hasError:${_videoController.value.hasError} error:${_videoController.value.errorDescription} position:${_videoController.value.position} duration: ${_videoController.value.duration} initialized: ${_videoController.value.initialized} _isNetworkConnectivityError: $_isNetworkConnectivityError");
        if (!_isNetworkConnectivityError && !_isPlayError) {
          _isPlayError = true;
        }
      } else {
        print(
            "正在播放 hasError:${_videoController.value.hasError} error:${_videoController.value.errorDescription} position:${_videoController.value.position} duration: ${_videoController.value.duration} _isNetworkConnectivityError: $_isNetworkConnectivityError");
        if (_isPlayError) {
          _isPlayError = false;
        } else if (_isNetworkConnectivityError) {
          print(
              "正在播放 _isNetworkConnectivityError true: _videoController.value.position: ${_videoController.value.position} maxBuffering: ${_getMaxBuffering()}");
          //看缓冲状态
          if (_videoController.value.position >=
              (_getMaxBuffering() - const Duration(milliseconds: 500)))
            _isPlayError = true;
        }
      }

      setState(() {});
    });
  }

  void _destroyController() {
    print(
        "AdvertView _destroyController -> _videoController: ${_videoController}");
    _pauseControllerWithoutListener();
    if (widget.controller == null) _videoController.dispose();

    _videoController = null;
  }

  Future<void> _handleStateAfterInit(_InitState initState) async {
    if (widget.playState == null || !_videoController.value.initialized) return;

    print(
        "AdvertView _handleStateAfterInit -> initState: ${initState.toString()}, playState: ${widget.playState}, isPlaying: ${_videoController.value.isPlaying}");

    switch (widget.playState) {
      case PlayState.startAndPause:
        if (initState != _InitState.just_already) {
          _videoController.seekTo(Duration.zero);
        }
        _videoController.pause();
        //if (_videoController.value.isPlaying) _videoController.pause();
        break;

      case PlayState.startAndPlay:
        if (initState != _InitState.just_already) {
          _videoController.seekTo(Duration.zero);
        }

        if (!_videoController.value.isPlaying) _videoController.play();

        break;

      case PlayState.continuePlay:
        print(
            "AdvertView _handleStateAfterInit -> continuePlay -> playPosition: $_playPosition  currentPosition:${_videoController.value.position}");
        _videoController.seekTo(_playPosition);
        if (!_videoController.value.isPlaying) _videoController.play();
        break;

      case PlayState.resume:
        if (!_videoController.value.isPlaying) _videoController.play();
        break;

      case PlayState.pause:
        _videoController.pause();
        break;

      case PlayState.end:
        if (_videoController.value.position !=
            _videoController.value.duration) {
          _videoController.seekTo(_videoController.value.duration);
        }

        _videoController.pause();

        break;
      default:
    }
  }

  Future<_InitState> _initFinished(_) async {
    _isPlayPrepare = true;
    return _InitState.just_already;
  }

  //重新初始化,初始化过了就忽略
  void _initController() {
    if (_videoController != null) {
      final String oldVideoUrl = _videoController.dataSource;
      final String newVideoUrl = _getNewVideoUrl(); //优先以videoUrl为准
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

  Widget _buildErrorWidget() {
    if (_isPlayError ||
        (!_videoController.value.initialized && _isNetworkConnectivityError)) {
      final String errorCode = _isNetworkConnectivityError
          ? NetworkErrorCode.network_connectivity_error
          : NetworkErrorCode.video_play_error;
      return widget.errorBuilder.call(context, errorCode) ??
          ViewUtils.buildNetworkErrorView(
            width: double.infinity,
            height: double.infinity,
            errorCode: "($errorCode)",
            onTap: () {
              if (_isNetworkConnectivityError) {
                checkConnectivity();
              } else {
                _initController();
              }
            },
          );
    }

    return null;
  }

  Widget _buildVideo() {
    dynamic stackList =
        widget.contentStackBuilder?.call(context, _videoController);
    assert(stackList is List || stackList is Widget);
    if (stackList is List) {
      final List contents = stackList;
      stackList = contents.whereType<Widget>();
    } else if (stackList != null) {
      stackList = [stackList];
    }

    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        fit: widget.contentFit,
        children: [
          widget.padding == null
              ? VideoPlayer(_videoController)
              : Container(
                  padding: widget.padding,
                  color: widget.paddingColor,
                  child: VideoPlayer(_videoController),
                ),
          if (stackList != null) ...stackList,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildErrorWidget() ?? _buildVideo();
  }
}
