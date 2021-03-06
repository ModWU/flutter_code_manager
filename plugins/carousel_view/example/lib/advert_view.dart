import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'base_model.dart';
import 'utils/circular_utils.dart' as CircularUtils;
//import 'package:flutter_volume/flutter_volume.dart';

typedef PlayListener = void Function(bool isStartPlay, bool isPlayEnd);

class AdvertView extends StatefulWidget {
  AdvertView(this.advertItem, {this.onPlay});

  @override
  State<StatefulWidget> createState() => _AdvertViewState();

  final AdvertItem advertItem;
  final PlayListener onPlay;
}

class _AdvertViewState extends State<AdvertView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  //AutomaticKeepAliveClientMixin
  VideoPlayerController _videoController;
  bool _playEnd = false;
  double _volume = 0;
  bool _hasVolume = false;

  bool _playClickFlag = false;
  bool _needContinuePlay = false;

  bool _detailTxtStartAnimated = false;

  bool _isInitializing = false;

  bool _isPlaying() {
    return _videoController?.value?.isPlaying ?? false;
  }

  bool _isNeedPlay() {
    return _playClickFlag &&
        _videoController.value.initialized &&
        !_videoController.value.isPlaying;
  }

  bool _isPlayEnd() {
    return _playEnd;
  }

  Widget _getIconWhenEnd() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0x90000000),
        ),
        Column(
          children: [
            //图标
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      //剪裁为圆角矩形
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network(
                        widget.advertItem
                            .iconUrl, //"http://via.placeholder.com/288x188",
                        fit: BoxFit.cover,
                        width: 43,
                        height: 43,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 9),
                      child: Text(
                        widget.advertItem.name,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //了解详情
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.topCenter,
                child: CircularUtils.getTextContainer("details",
                    radius: 12.0,
                    horizontalSpace: 12.0,
                    verticalSpace: 5.0,
                    fontSize: 14,
                    margin: EdgeInsets.only(top: 19), onTap: () {
                  print("click details");
                }, backgroundColor: Colors.deepOrange),
              ),
            ),
          ],
        ),
        //重新播放
        Positioned(
          //left: 24.w,
          right: 24,
          bottom: 24,
          child: CircularUtils.getTextSpanContainer(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    style: TextStyle(
                      fontSize: 13,
                      //wordSpacing: 20.w
                    ),
                    child: Icon(
                      Icons.replay,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  TextSpan(
                    text: "  replay",
                    style: TextStyle(
                      fontSize: 13,
                      //wordSpacing: 20.w
                    ),
                  ),
                ],
              ), onTap: () {
            _startPlay();
            print("click replay");
          },
              fontSize: 10,
              textColor: Colors.white,
              backgroundColor: Color(0x33000000),
              verticalSpace: 2,
              horizontalSpace: 4),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
     // print(
         // "AdvertView didChangeAppLifecycleState -> AppLifecycleState.paused");
      if (_isPlaying()) {
        _videoController?.pause();
        _needContinuePlay = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      //print(
        //  "AdvertView didChangeAppLifecycleState -> AppLifecycleState.resumed");
      if (_needContinuePlay || _isNeedPlay()) {
        _needContinuePlay = false;
        _videoController?.play();
      }
    } else if (state == AppLifecycleState.detached) {
     // print(
         // "AdvertView didChangeAppLifecycleState -> AppLifecycleState.detached 操作不了ui");
      //_videoController?.dispose();
    } else if (state == AppLifecycleState.inactive) {
      //print(
         // "AdvertView didChangeAppLifecycleState -> AppLifecycleState.inactive");
    }
  }

  @override
  void didUpdateWidget(AdvertView oldWidget) {
    super.didUpdateWidget(oldWidget);

    //更新控制器
    if (widget.advertItem != oldWidget.advertItem) {
      if (widget.advertItem.canPlay != oldWidget.advertItem.canPlay) {
        if (widget.advertItem.canPlay) {
          _initVideoController(force: true, resetUrl: true);
        } else {
          _disposeVideoController();
        }
      } else if (widget.advertItem.canPlay) {
        if (widget.advertItem.videoUrl != oldWidget.advertItem.videoUrl) {
          _initVideoController(force: true, resetUrl: true);
        }
      }
    }
  }

  Future<void> _initVideoFinished(_) async {
    print(
        "_initVideoFinished _playClickFlag:$_playClickFlag, _videoController.value.isPlaying: ${_videoController.value.isPlaying}, position:${_videoController.value.position} ${_videoController.value.duration}");
    _videoController.addListener(_onPlay);
    if (_isNeedPlay()) {
      setState(() {
        _playEnd = false;
        /*if (_videoController.value.position != Duration.zero)
                    _videoController.seekTo(Duration.zero);*/
        _videoController.play();
        _startDetailTxtAnimation();
      });
    }
    _isInitializing = false;
  }

  void _onPlay() {
    print(
        "play position: total:${_videoController.value.duration}  position:${_videoController.value.position} isPlaying:${_videoController.value.isPlaying}");

    if (_videoController.value.duration == null) {
      _initVideoController(force: true);
      return;
    }

    //print("player end! _videoController isPlaying: ${_videoController.value.isPlaying}  position: ${_videoController.value.position}");

    if (_videoController.value.position == _videoController.value.duration) {
      print(
          "player end! start => isPlaying: ${_videoController.value.isPlaying}  position: ${_videoController.value.position}");
      _videoController.removeListener(_onPlay);
      widget.onPlay?.call(false, true);
      setState(() {
        //_videoController.pause();
        // _videoController.setLooping(true);
        _playEnd = true;
        _playClickFlag = false;
        _detailTxtStartAnimated = false;
        //_videoController.value = null;//_videoController.value.copyWith(position: Duration.zero, duration: Duration.zero);
        _videoController.pause();
        _initVideoController(force: true);
        print(
            "player end! end => _videoController isPlaying: ${_videoController.value.isPlaying}  position: ${_videoController.value.position}");
      });
    }
  }

  void _disposeVideoController() {
    _videoController?.removeListener(_onPlay);
    _videoController?.dispose();
  }

  void _initVideoController({bool force = false, bool resetUrl = false}) {
    print("_initVideoController: force:${force}, resetUrl:${resetUrl}, _isInitializing:${_isInitializing}, _videoController:${_videoController}");
    assert(force != null);
    if (!force && _isInitializing) return;

    _isInitializing = true;

    assert(resetUrl != null);
    if (_videoController == null || resetUrl) {
      _disposeVideoController();
      _videoController =
          VideoPlayerController.network(widget.advertItem.videoUrl)
            ..setLooping(false);
    }

    _videoController.removeListener(_onPlay);
    _videoController.initialize().then(_initVideoFinished);
  }

  @override
  void initState() {
    super.initState();
    print("AdvertView init....");
    WidgetsBinding.instance.addObserver(this);
    if (widget.advertItem.canPlay) {
      _initVideoController();
    }
  }

  Future<bool> _onPressBack() {
    print("_onPressBack");
    if (_isPlaying()) _videoController?.pause();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: _onPressBack,
      child: _buildAdvert(context),
    );
  }

  Widget _buildAdvert(BuildContext context) {
    List<Widget> children = [
      widget.advertItem.canPlay
          ? VideoPlayer(_videoController)
          : Image.asset(
              widget.advertItem.showImgUrl,
              fit: BoxFit.cover,
              //colorBlendMode: hasVideoUrl ? BlendMode.darken : null,
              //color: hasVideoUrl ? Color(0x22000000) : null,
            ),
    ];

    Stack advertStack = Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.center,
      children: children,
    );

    if (widget.advertItem.canPlay) {
      //!_videoController.value.isPlaying
      children.add(Offstage(
        offstage: !_playEnd,
        child: _getIconWhenEnd(),
      ));

      print(
          "build build build build build: ${_videoController.value.isPlaying}  position: ${_videoController.value.position}");
      if (_videoController.value.isPlaying) {
        children.add(
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isPlaying()) {
                        _hasVolume = !_hasVolume;
                        setVolume(_volume, _hasVolume);
                      }
                    });
                  },
                  child: Icon(
                    _hasVolume
                        ? Icons.volume_up_outlined
                        : Icons.volume_off_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                CircularUtils.getTextAnimatedContainer(
                    'details',
                    radius: 12.0,
                    horizontalSpace: 12.0,
                    verticalSpace: 5.0,
                    fontSize: 12,
                    curve: Curves.easeIn,
                    duration: Duration(
                        milliseconds: (_detailTxtStartAnimated ? 500 : 0)),
                    onTap: () {
                  print("click details");
                },
                    backgroundColor: _detailTxtStartAnimated
                        ? Colors.deepOrange
                        : Color(0x44000000)),
              ],
            ),
          ),
        );
      } else if (!_playEnd) {
        if (!_playClickFlag) {
          children.add(GestureDetector(
            onTap: () {
              _startPlay();
            },
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 120,
            ),
          ));
        } else if (!_videoController.value.initialized) {
          children.add(Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child:
                VideoProgressIndicator(_videoController, allowScrubbing: true),
          ));
        }
      }

      children.add(
        Positioned(
            right: 0,
            top: 0,
            child: CircularUtils.getTextSpanContainer(
                TextSpan(text: 'advert', children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 13,
                    ),
                    style: TextStyle(
                      letterSpacing: -1,
                    ),
                  ),
                ]), onTap: () {
              print("click advert");
            },
                fontSize: 10,
                textColor: Colors.white,
                backgroundColor: Color(0x33000000),
                verticalSpace: 7, //14.w,
                horizontalInvisibleSpace: 6,
                verticalInvisibleSpace: 6,
                invisibleSpaceClickable: true,
                horizontalSpace: 9) //18.w),
            ),
      );

      return AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: advertStack,
      );
    }

    return advertStack;
  }

  void _startPlay() {
    if (_playClickFlag) return;

    widget.onPlay?.call(true, false);

    setState(() {
      if (_videoController.value.initialized) {
        _videoController.value =
            _videoController.value.copyWith(position: Duration.zero);
        _videoController.play();
        _startDetailTxtAnimation();
      }

      _playEnd = false;
      _playClickFlag = true;
    });
  }

  void _startDetailTxtAnimation() {
    Timer(const Duration(seconds: 5), () {
      //callback function
      print('afterTimer=' + DateTime.now().toString()); // 5s after
      setState(() {
        _detailTxtStartAnimated = true;
      });
    });
  }

  void setVolume(double volume, bool hasVolume) {
    _volume = volume;
    if (volume > 0) {
      _hasVolume = hasVolume;
      _videoController.setVolume(volume);
    } else {
      _hasVolume = hasVolume;
      _videoController.setVolume(0);
    }
  }

  @override
  void dispose() {
    print("AdvertView dispose...");
    WidgetsBinding.instance.removeObserver(this);
    _disposeVideoController();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
