import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_list/resources/res/strings.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';
import '../pages/page_utils.dart' as PageUtils;
import '../models/base_model.dart';
import '../resources/export.dart';
import 'dart:async';
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

  bool _isPlaying() {
    return _videoController?.value?.isPlaying ?? false;
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
                        width: 86.w,
                        height: 86.w,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 18.h),
                      child: Text(
                        widget.advertItem.name,
                        style: TextStyle(color: Colors.white, fontSize: 26.sp),
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
                child: PageUtils.getTextContainer(Strings.advert_detail_txt,
                    radius: 24.0.w,
                    horizontalSpace: 24.0.w,
                    verticalSpace: 10.0.w,
                    fontSize: 28.sp,
                    margin: EdgeInsets.only(top: 38.h), onTap: () {
                  print("点击了${Strings.advert_detail_txt}");
                }, backgroundColor: Colors.deepOrange),
              ),
            ),
          ],
        ),
        //重新播放
        Positioned(
          //left: 24.w,
          right: 24.w,
          bottom: 24.w,
          child: PageUtils.getTextSpanContainer(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    style: TextStyle(
                      fontSize: 26.sp,
                      //wordSpacing: 20.w
                    ),
                    child: Icon(
                      Icons.replay,
                      color: Colors.white,
                      size: 42.sp,
                    ),
                  ),
                  TextSpan(
                    text: "  ${Strings.advert_replay_txt}",
                    style: TextStyle(
                      fontSize: 26.sp,
                      //wordSpacing: 20.w
                    ),
                  ),
                ],
              ), onTap: () {
            _startPlay();
            print("点击${Strings.advert_replay_txt}");
          },
              fontSize: 20.sp,
              textColor: Colors.white,
              backgroundColor: Color(0x33000000),
              verticalSpace: 4.w,
              horizontalSpace: 8.w),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.paused");
      if (_isPlaying()) {
        _videoController?.pause();
        _needContinuePlay = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.resumed");
      if (_needContinuePlay) {
        _needContinuePlay = false;
        _videoController?.play();
      }
    } else if (state == AppLifecycleState.detached) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.detached 操作不了ui");
      //_videoController?.dispose();
    } else if (state == AppLifecycleState.inactive) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.inactive");
    }
  }

  void _initVideoFinished() {
    print(
        "_initVideoFinished _playClickFlag:$_playClickFlag, _videoController.value.isPlaying: ${_videoController.value.isPlaying}, position:${_videoController.value.position}");
    if (_playClickFlag && !_videoController.value.isPlaying) {
      setState(() {
        _playEnd = false;
        /*if (_videoController.value.position != Duration.zero)
                    _videoController.seekTo(Duration.zero);*/
        _videoController.play();
        _startDetailTxtAnimation();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("AdvertView init....");
    WidgetsBinding.instance.addObserver(this);
    if (widget.advertItem.canPlay) {
      _videoController =
          VideoPlayerController.network(widget.advertItem.videoUrl)
            ..setLooping(false)
            ..initialize().then((_) {
              _initVideoFinished();
            });
      _videoController.addListener(() {
        print(
            "play position: total:${_videoController.value.duration}  position:${_videoController.value.position}");

        if (_videoController.value.duration == null) {
          _videoController.initialize().then((_) {
            _initVideoFinished();
          });
          return;
        }

        if (_videoController.value.position ==
                _videoController.value.duration &&
            !_playEnd &&
            _playClickFlag) {
          widget.onPlay?.call(false, true);
          setState(() {
            //_videoController.pause();
            // _videoController.setLooping(true);
            _playEnd = true;
            _playClickFlag = false;
            _detailTxtStartAnimated = false;
            // _videoController.value = _videoController.value.copyWith(position: Duration.zero);
            _videoController.pause();
            _videoController.initialize().then((_) {
              _initVideoFinished();
            });
            print(
                "player end! _videoController isPlaying: ${_videoController.value.isPlaying}  position: ${_videoController.value.position}");
          });
        }
      });

      /*FlutterVolume.volume.then((volume) {
        setState(() {
          setVolume(volume, volume > 0);
        });
      });*/
    }
  }

  Future<bool> _onPressBack() {
    print("点击了返回键");
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
            left: 24.w,
            right: 24.w,
            bottom: 24.w,
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
                    size: 44.w,
                  ),
                ),
                PageUtils.getTextAnimatedContainer(Strings.advert_detail_txt,
                    radius: 24.0.w,
                    horizontalSpace: 24.0.w,
                    verticalSpace: 10.0.w,
                    fontSize: 24.sp,
                    curve: Curves.easeIn,
                    duration: Duration(
                        milliseconds: (_detailTxtStartAnimated ? 500 : 0)),
                    onTap: () {
                  print("点击了${Strings.advert_detail_txt}");
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
              size: 120.w,
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
          right: 10.w,
          top: 10.w,
          child: PageUtils.getTextSpanContainer(
              TextSpan(text: Strings.advert_txt, children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ]), onTap: () {
            print("点击${Strings.advert_txt}");
          },
              fontSize: 20.sp,
              textColor: Colors.white,
              backgroundColor: Color(0x33000000),
              verticalSpace: 4.w,
              horizontalSpace: 8.w),
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
      print(
          "click play button ${_videoController.value.initialized} ${_videoController.value.position}");
      if (_videoController.value.initialized) {
        _videoController.value =
            _videoController.value.copyWith(position: Duration.zero);
        print("点击了重新播放，当前位置：${_videoController.value.position}");
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
      print('afterTimer=' + DateTime.now().toString()); // 5s之后
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
    _videoController?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
