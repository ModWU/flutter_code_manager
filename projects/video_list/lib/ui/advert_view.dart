import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/size_extension.dart';
import '../pages/page_utils.dart' as PageUtils;
import '../models/base_model.dart';
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.paused ${_videoController?.value?.isPlaying}");
      _videoController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.resumed");
      _videoController?.play();
    } else if (state == AppLifecycleState.detached) {
      print(
          "AdvertView didChangeAppLifecycleState -> AppLifecycleState.detached ${_videoController?.value?.isPlaying}");
      _videoController?.pause();
    } else if (state == AppLifecycleState.inactive) {
      print("AdvertView didChangeAppLifecycleState -> AppLifecycleState.inactive");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("AdvertView initialize...");
    if (widget.advertItem.canPlay) {
      _videoController =
          VideoPlayerController.network(widget.advertItem.videoUrl)
            ..setLooping(false)
            ..initialize().then((_) {
              if (_playClickFlag)
                setState(() {
                  _videoController.play();
                });
              print("player initialize finished!");
            });
      _videoController.addListener(() {
        print(
            "total: ${_videoController.value.duration} play: ${_videoController.value.position}");

        if (_videoController.value.position ==
            _videoController.value.duration) {
          widget.onPlay?.call(false, true);
          setState(() {
            //_videoController.pause();
            // _videoController.setLooping(true);
            _playEnd = true;
            _playClickFlag = false;
            _videoController.initialize();
          });
          print("player end!");
        }
      });

      /*FlutterVolume.volume.then((volume) {
        setState(() {
          setVolume(volume, volume > 0);
        });
      });*/
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      widget.advertItem.canPlay
          ? VideoPlayer(_videoController)
          : Image.asset(
              widget.advertItem.showImgUrl,
              fit: BoxFit.cover,
              //colorBlendMode: hasVideoUrl ? BlendMode.darken : null,
              //color: hasVideoUrl ? Color(0x22000000) : null,
            ),
      Positioned(
        right: 10.w,
        top: 10.w,
        child: GestureDetector(
          onTap: () {
            print("广告");
          },
          child: PageUtils.getTextContainer2(
              TextSpan(text: "广告", children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ]),
              fontSize: 20.sp,
              textColor: Colors.white,
              backgroundColor: Color(0x33000000),
              verticalSpace: 4.w,
              horizontalSpace: 8.w),
        ),
      ),
    ];

    Stack advertStack = Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.center,
      children: children,
    );

    if (widget.advertItem.canPlay) {
      //!_videoController.value.isPlaying
      if (_playEnd) {
      } else {
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
                        if (_videoController.value.isPlaying) {
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
                  GestureDetector(
                    onTap: () {
                      print("了解详情");
                    },
                    child: PageUtils.getTextContainer("了解详情",
                        radius: 24.0.w,
                        horizontalSpace: 24.0.w,
                        verticalSpace: 10.0.w,
                        fontSize: 24.sp,
                        backgroundColor: Color(0x44000000)),
                  )
                ],
              ),
            ),
          );
        } else {
          if (!_playClickFlag) {
            children.add(GestureDetector(
              onTap: () {
                widget.onPlay?.call(true, false);

                setState(() {
                  print("click play button");
                  if (_videoController.value.initialized)
                    _videoController.play();

                  _playClickFlag = true;
                });
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
              child: VideoProgressIndicator(_videoController,
                  allowScrubbing: true),
            ));
          }
        }
      }

      //videoController.value.position == videoController.value.duration
      /*children.addAll([
        Icon(
          _videoController.value.isPlaying
              ? Icons.pause
              : Icons.play_circle_outline,
          color: Colors.white,
          size: 120.w,
        ),
      ]);*/

      return AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: advertStack,
      );
    }

    return advertStack;
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
    if (_videoController?.value?.isPlaying ?? false) _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
