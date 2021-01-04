import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_list/examples/video_indicator.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/utils/network_utils.dart';
import 'package:video_player/video_player.dart';
import 'static_video_view.dart';
import 'package:video_list/resources/export.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:ui' as ui show ParagraphBuilder, PlaceholderAlignment;

class NormalAdvertView extends StatefulWidget {
  NormalAdvertView(
      {this.playState = PlayState.startAndPause,
      this.titleHeight,
      this.videoHeight,
      this.width,
      this.advertItem})
      : assert(playState != null),
        assert(advertItem != null),
        assert(titleHeight != null && titleHeight > 0),
        assert(videoHeight != null && videoHeight > 0),
        assert(width == null || width > 0);

  State<StatefulWidget> createState() => _NormalAdvertViewState();

  final PlayState playState;

  final AdvertItem advertItem;

  final double titleHeight;

  final double videoHeight;

  final double width;
}

class _NormalAdvertViewState extends State<NormalAdvertView>
    with AutomaticKeepAliveClientMixin, NetworkStateMiXin {

  @override
  void onNetworkChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: _onClickAdvert,
      child: Container(
        width: widget.width ?? Dimens.design_screen_width.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAdvertBody(),
            _buildBottomTitle(),
          ],
        ),
      ),
    );
  }

  void _onClickAdvert() {}

  Widget _buildVideoView() {
    assert(widget.advertItem.videoUrl != null);
    return VideoView(
      videoUrl: widget.advertItem.videoUrl,
      playState: widget.playState,
      contentStackBuilder:
          (BuildContext context, VideoPlayerController controller) {
        assert(controller.value != null);

        if (widget.playState == PlayState.startAndPause) {
          return [
            _PlayPauseOverlay(controller: controller),
          ];
        } else {
          if (!controller.value.initialized) {
            return [
              _buildWaitingProgressIndicator(),
            ];
          } else {
            final bool isEnd =
                controller.value.position >= controller.value.duration;

            if (isEnd) {
              return null;
            } else {
              final bool isNearBuffering = _isNearBuffering(controller);
              return isNearBuffering
                  ? [
                      _buildWaitingProgressIndicator(),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildProgressIndicator(controller),
                      ),
                    ]
                  : [
                      _PlayPauseOverlay(controller: controller),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildProgressIndicator(controller),
                      ),
                    ];
            }
          }
        }

        /*if (!controller.value.initialized) {
          return [
            _buildWaitingProgressIndicator(),
          ];
        } else {
          final bool isEnd =
              controller.value.position >= controller.value.duration;
          if (isEnd) {
            return null;
          } else {
            final bool isNearBuffering = true;//_isNearBuffering(controller);
            return isNearBuffering
                ? [
                    _buildWaitingProgressIndicator(),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildProgressIndicator(controller),
                    ),
                  ]
                : [
                    _PlayPauseOverlay(controller: controller),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildProgressIndicator(controller),
                    ),
                  ];
          }
        }*/
      },
    );
  }

  bool _isNearBuffering(VideoPlayerController controller) {
    assert(controller != null);
    assert(controller.value.initialized);
    Duration maxBufferingDuration = Duration.zero;
    ;
    int maxBuffering = 0;
    for (DurationRange range in controller.value.buffered) {
      final int end = range.end.inMilliseconds;
      if (end > maxBuffering) {
        maxBuffering = end;
        maxBufferingDuration = range.end;
      }
    }

    return controller.value.position >= maxBufferingDuration;
  }

  Widget _buildWaitingProgressIndicator() {
    return CircularProgressIndicator(
      backgroundColor: Colors.black12,
      strokeWidth: 2.4,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
    );
  }

  Widget _buildProgressIndicator(VideoPlayerController controller) {
    return VideoProgressOwnerIndicator(
      controller,
      allowScrubbing: false,
      padding: EdgeInsets.zero,
      colors: VideoProgressColors(
        playedColor: Colors.orangeAccent,
        backgroundColor: Colors.black26,
        bufferedColor: Colors.blueGrey,
      ),
    );
  }


  Widget _buildImageView() {
    assert(widget.advertItem.showImgUrl != null);
    return Image.network(
      widget.advertItem.showImgUrl, //"http://via.placeholder.com/288x188",
      fit: BoxFit.cover,
    );
  }

  Widget _buildAdvertBody() {
    return Container(
      height: widget.videoHeight,
      width: double.infinity,
      child: hasNetwork
          ? (widget.advertItem.canPlay ? _buildVideoView() : _buildImageView())
          : buildNetworkErrorView(),
    );
  }

  Widget _buildBottomTitle() {
    assert(widget.advertItem.introduce != null);
    assert(widget.advertItem.nameDetails != null &&
        widget.advertItem.nameDetails.isNotEmpty);
    return Container(
      height: widget.titleHeight,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: Colors.black,
                  ),
                  text: "${widget.advertItem.introduce}\n",
                ),
                widget.advertItem.nameDetails.length > 1
                    ? TextSpan(
                        children: [
                          for (String name in widget.advertItem.nameDetails)
                            WidgetSpan(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(10, 0, 0, 0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2.w)),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.w, horizontal: 8.w),
                                margin: EdgeInsets.only(right: 8.w),
                                child: Text(
                                  name,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 22.sp),
                                ),
                              ),
                            ),
                        ],
                      )
                    : TextSpan(text: widget.advertItem.nameDetails[0]),
              ],
              style: TextStyle(
                fontSize: 22.sp,
                color: Colors.grey,
              ),
            ),
            strutStyle: StrutStyle(
              leading: 0.4,
            ),
          ),
          RawChip(
            avatar: Icon(
              Icons.workspaces_outline,
              color: Colors.grey,
              size: 32.sp,
            ),
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            onPressed: () {},
            label: Text(
              widget.advertItem.isApplication
                  ? Strings.advert_download_txt
                  : Strings.advert_detail_txt,
              style: TextStyle(
                fontSize: 26.sp,
                color: Colors.grey,
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
                      size: 60.0,
                    ),
                  ),
                ),
        ),
        /* GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),*/
      ],
    );
  }
}
