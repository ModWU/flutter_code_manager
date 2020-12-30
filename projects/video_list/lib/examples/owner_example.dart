import 'package:flutter_screenutil/screenutil.dart';
import 'package:video_list/controllers/choiceness_controller.dart';
import 'package:video_list/examples/video_indicator.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;

import 'package:flutter/services.dart';

import 'static_video_view.dart';

class VideoOwnerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VideoOwnerAppState();
}

class _VideoOwnerAppState extends State<VideoOwnerApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    print('VideoOwnerApp => deactivate');
    super.deactivate();
  }

  PlayState playState = PlayState.resume;
  bool isPlaying = true;
  var videoUrl =
      'http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4';
  Math.Random random = Math.Random();

  @override
  Widget build(BuildContext context) {
    print("build");

    return MaterialApp(
        title: 'Video Demo',
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              ScreenUtil.init(context,
                  designSize: Size(
                      Dimens.design_screen_width, Dimens.design_screen_height),
                  allowFontScaling: false);
              return Center(
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      Container(
                        height: 240,
                        width: double.infinity,
                        color: Colors.black12,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Text(
                                "田读帅，我爱你！(๑′ᴗ‵๑)Ｉ Lᵒᵛᵉᵧₒᵤ❤",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.redAccent),
                              ),
                            ),
                            VideoView(
                              videoUrl: videoUrl,
                              playState: playState,
                              contentStackBuilder: (BuildContext context, VideoPlayerController controller) {
                                print("listener## => controller: ${controller.value.position} buffer: ${controller.value.buffered}");
                                return <Widget>[
                                  _PlayPauseOverlay(controller: controller),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: VideoProgressOwnerIndicator(
                                      controller,
                                      allowScrubbing: false,
                                      colors: VideoProgressColors(
                                        playedColor: Colors.orangeAccent,
                                        backgroundColor: Colors.black26,
                                        bufferedColor: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          videoUrl,
                          style: TextStyle(fontSize: 8),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              videoUrl = ChoicenessController.videoUrlList[
                                  random.nextInt(ChoicenessController
                                          .videoUrlList.length) %
                                      ChoicenessController.videoUrlList.length];
                            });
                          },
                          child: Text("更换url"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              isPlaying = !isPlaying;
                              playState = (isPlaying
                                  ? PlayState.resume
                                  : PlayState.pause);
                            });
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "暂停",
                                  style: TextStyle(
                                      color: isPlaying
                                          ? Colors.orangeAccent
                                          : Colors.white,
                                      fontSize: isPlaying
                                          ? 18
                                          : 14),
                                ),
                                TextSpan(text: "/"),
                                TextSpan(
                                    text: "播放",
                                    style: TextStyle(
                                        color: !isPlaying
                                            ? Colors.orangeAccent
                                            : Colors.white,
                                        fontSize: !isPlaying
                                            ? 18
                                            : 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              playState = PlayState.start;
                            });
                          },
                          child: Text("重新初始化"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              playState = PlayState.end;
                            });
                          },
                          child: Text("跳到末尾"),
                        ),
                      ),
                    ],
                  );
                }),
              );
            },
          ),
        ));
  }

  @override
  void dispose() {
    print('VideoOwnerApp => dispose');
    super.dispose();
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 80.0,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
