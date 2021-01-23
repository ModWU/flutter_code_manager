import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'video_indicator.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/ui/popup/popup_view.dart';
import 'package:video_list/ui/utils/triangle_arrow_decoration.dart';
import 'package:video_list/utils/network_utils.dart';
import 'package:video_list/utils/view_utils.dart' as ViewUtils;
import 'package:video_player/video_player.dart';
import 'static_video_view.dart';
import 'package:video_list/resources/export.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'dart:ui';
import 'dart:math' as Math;
import 'package:connectivity/connectivity.dart';
import 'dart:ui' as ui show ParagraphBuilder, PlaceholderAlignment;

Duration _kDetailHighlightDuration = const Duration(seconds: 5);

typedef OnDetailHighlight = void Function(bool highlight);

class NormalAdvertView extends StatefulWidget {
  NormalAdvertView(
      {this.playState = PlayState.startAndPause,
      this.titleHeight,
      this.videoHeight,
      this.popupDirection = PopupDirection.bottom,
      this.detailHighlight = false,
      this.onLoseAttention,
      this.onDetailHighlight,
      this.width,
      this.onEnd,
      this.advertItem})
      : assert(playState != null),
        assert(advertItem != null),
        assert(detailHighlight != null),
        assert(popupDirection != null),
        assert(titleHeight != null && titleHeight > 0),
        assert(videoHeight != null && videoHeight > 0),
        assert(width == null || width > 0);

  State<StatefulWidget> createState() => _NormalAdvertViewState();

  static double advertButtonTopPadding = 8.w;
  static double advertButtonHeight = 30.h;
  static double popupViewHeight = 112.h;

  //advertButton.topPadding + advertButton.height + popupView.height
  static double needVisibleHeight =
      advertButtonTopPadding + advertButtonHeight + popupViewHeight;

  final PlayState playState;

  final AdvertItem advertItem;

  final double titleHeight;

  final double videoHeight;

  final double width;

  final VoidCallback onEnd;

  final VoidCallback onLoseAttention;

  final OnDetailHighlight onDetailHighlight;

  final PopupDirection popupDirection;

  final bool detailHighlight;
}

class _NormalAdvertViewState extends State<NormalAdvertView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(_detailHighlightNotifier != null);
    return ChangeNotifierProvider.value(
      value: _detailHighlightNotifier,
      child: GestureDetector(
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
      ),
    );
  }

  void _onClickAdvert() {
    print("点击了Advert body");
  }

  Widget _buildVideoView() {
    assert(widget.advertItem.videoUrl != null);
    return VideoView(
      videoUrl: widget.advertItem.videoUrl,
      playState: widget.playState,
      contentStackBuilder:
          (BuildContext context, VideoPlayerController controller) {
        assert(controller.value != null);

        final List<Widget> children = [];

        bool isEnd = false;

        print("current current playState: ${widget.playState}");

        if (widget.playState == PlayState.startAndPause) {
          children.addAll([
            _buildShowImageView(),
            _PlayPauseOverlay(controller: controller),
          ]);
        } else {
          if (!controller.value.initialized) {
            children.addAll([
              _buildShowImageView(),
              _buildWaitingProgressIndicator(),
            ]);
          } else {
            isEnd = controller.value.position >= controller.value.duration;

            if (!isEnd) {
              final bool isNearBuffering = _isNeedBuffering(controller);
              print("isNearBuffering => $isNearBuffering");
              children.addAll([
                if (isNearBuffering) _buildWaitingProgressIndicator(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildProgressIndicator(controller),
                ),
              ]);
            }
          }
        }

        if (isEnd) {
          widget.onEnd?.call();
          children.addAll([
            _buildShowImageView(),
            _buildCoverShape(),
          ]);
        }

        children.addAll([
          _buildAdvertEnd(!isEnd),
          _buildAdvertHint(),
        ]);

        return children;
      },
    );
  }

  Duration _currentPlayPosition = Duration.zero;

  bool _isNeedBuffering(VideoPlayerController controller) {
    assert(controller != null);
    assert(controller.value.initialized);
    print(
        "_isNearBuffering => controller.value.position: ${controller.value.position}  controller.value.buffered: ${controller.value.buffered} isBuffering: ${controller.value.isBuffering} isPlaying: ${controller.value.isPlaying}");
    final int totalValue = controller.value.duration?.inMilliseconds;

    if (totalValue == null)
      return false;

    assert(controller.value.position != null);

    final int overflowValue = 500;
    final int position = controller.value.position.inMilliseconds;
    final int limitValue = overflowValue + position;

    int maxBuffering = 0;
    for (DurationRange range in controller.value.buffered) {
      final int end = range.end.inMilliseconds;
      if (end > maxBuffering) {
        maxBuffering = end;
      }
    }

    return limitValue < totalValue &&
        limitValue >= maxBuffering;
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

  Widget _buildShowImageView() {
    assert(widget.advertItem.showImgUrl != null);
    return Image.network(
      widget.advertItem.showImgUrl, //"http://via.placeholder.com/288x188",
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent loadingProgress,
      ) {
        return Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFFA9A9A9),
            child: child);
      },
    );
  }

  Widget _buildCoverShape() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black54,
    );
  }

  Widget _buildAdvertBody() {
    return Container(
        height: widget.videoHeight,
        width: double.infinity,
        child: (widget.advertItem.canPlay
            ? _buildVideoView()
            : _buildShowImageView()));
  }

  Timer _detailHighlightAnimationTimer;
  ValueNotifier<bool> _detailHighlightNotifier = ValueNotifier(false);

  Widget _buildAdvertHint() {
    final double top = NormalAdvertView.advertButtonTopPadding;
    final double right = 8.w;
    final double popupRight = 16.w;
    final double popupLeft = 32.w;
    return Positioned(
      top: top,
      right: right,
      child: PopupMenuView(
        itemBuilder: (context) {
          return <PopupViewEntry<String>>[
            PopupViewItem<String>(
              value: '${widget.advertItem}',
              child: Padding(
                padding: EdgeInsets.only(left: 38.w, top: 32.w, bottom: 32.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Colors.grey,
                      size: 38.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 18.w),
                      child: Text(
                        Strings.advert_bored_text,
                        style: TextStyle(fontSize: 28.sp),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ];
        },
        onSelected: (v) {
          widget.onLoseAttention?.call();
        },
        width: Dimens.design_screen_width.w,
        barrierColor: Colors.black26,
        reverseTransitionDuration: Duration.zero,
        //transitionDuration: Duration(milliseconds: 3000),
        //elevation: 50,
        //padding: EdgeInsets.all(0),
        menuScreenPadding:
            EdgeInsets.only(left: popupLeft, right: popupRight, top: 0),
        outerBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
            RenderBox targetBox) {
          assert(targetBox.size != null);
          assert(targetBox.size.width != null);
          final bool popupDirectionBottom =
              widget.popupDirection == PopupDirection.bottom;
          final double radius = 6;
          final double arrowWidth = 18.w;
          final double arrowHeight = 12.w; //arrowWidth * Math.sin(Math.pi / 3);

          final double finishOffset = popupRight - right;
          final double needOffset = targetBox.size.width * 0.5 -
              finishOffset -
              radius -
              arrowWidth / 2;
          print("widget.popupDirection: ${widget.popupDirection}");
          final CurveTween opacity =
              CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;
              print("====> width: $width, height: $height");
              final double scaleAlignmentFactor = 1.0 -
                  (arrowWidth * 0.5 + radius + needOffset) / (width * 0.5);
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget child) {
                  return Transform.scale(
                    scale: animation.value,
                    alignment: Alignment(scaleAlignmentFactor,
                        popupDirectionBottom ? -1.0 : 1.0),
                    child: Opacity(
                      opacity: opacity.evaluate(animation),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  height: NormalAdvertView.popupViewHeight,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                      left: 0,
                      top: popupDirectionBottom ? arrowHeight : 0,
                      bottom: !popupDirectionBottom ? arrowHeight : 0),
                  decoration: TriangleArrowDecoration(
                    color: Colors.white,
                    triangleArrowDirection: popupDirectionBottom
                        ? TriangleArrowDirection.topRight
                        : TriangleArrowDirection.bottomRight,
                    arrowOffset: needOffset,
                    arrowHeight: arrowHeight,
                    arrowWidth: arrowWidth,
                    arrowSmoothness: 1.5.w,
                    arrowBreadth: 0.2.w,
                    borderRadius: BorderRadius.all(
                      Radius.circular(radius),
                    ),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
        //color: Colors.blue,
        coverTarget: false,
        popupDirection: widget.popupDirection,
        child: Container(
          height: NormalAdvertView.advertButtonHeight,
          padding: EdgeInsets.symmetric(
            horizontal: 6.w,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(4.w)),
          ),
          child: Row(
            children: [
              Text(
                Strings.advert_txt,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 26.sp,
              ),
            ],
          ),
        ), /*ViewUtils.buildTextIcon(
          text: Text(
            Strings.advert_txt,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 26.sp,
          ),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(4.w)),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 2.w,
            horizontal: 6.w,
          ),
        ),*/
      ),
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
              leading: widget.advertItem.nameDetails.length > 1 ? 0.4 : 0.2,
            ),
          ),
          Consumer<ValueNotifier<bool>>(
            builder: (context, detailHighlightNotifier, _) {
              print(
                  "${this.hashCode} detailHighlightNotifier.value: ${detailHighlightNotifier.value}");

              return ViewUtils.buildIconTextWithAnimation(
                icon: Icon(
                  Icons.workspaces_outline,
                  size: 30.sp,
                ),
                text: Text(
                  widget.advertItem.isApplication
                      ? Strings.advert_download_txt
                      : Strings.advert_detail_txt,
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                animationIconTheme: IconThemeData(
                  color: detailHighlightNotifier.value
                      ? Color(0xFFFF6633)
                      : Colors.grey,
                ),
                animationTextStyle: TextStyle(
                  color: detailHighlightNotifier.value
                      ? Color(0xFFFF6633)
                      : Colors.grey,
                ),
                gap: 8.w,
                curve: Curves.ease,
                duration: Duration(
                  milliseconds: (detailHighlightNotifier.value ? 500 : 0),
                ),
                onTap: () {
                  print("底部");
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertEnd(bool offstage) {
    return Offstage(
      offstage: offstage,
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 70.h),
            child: GestureDetector(
              onTap: () {
                print("点击了图标");
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.w),
                child: Image.network(
                  widget.advertItem.iconUrl,
                  width: 80.w,
                  height: 80.w,
                ),
              ),
            ),
          ),
          Text(
            widget.advertItem.iconName,
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.white,
            ),
            strutStyle: StrutStyle(
              leading: 1.2,
            ),
          ),
          ViewUtils.buildIconText(
            text: Text(
              Strings.advert_detail_txt,
              style: TextStyle(
                fontSize: 28.sp,
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              //设置四周圆角 角度
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              //设置四周边框
              //border: new Border.all(width: 1, color: Colors.red),
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            margin: EdgeInsets.only(top: 6.0),
            onTap: () {
              print("了解详情");
            },
          ),
          Expanded(
            child: Align(
              alignment: Alignment(0.95, 0.2),
              child: ViewUtils.buildIconText(
                icon: Icon(
                  Icons.replay,
                  size: 34.w,
                  color: Colors.white,
                ),
                text: Text(
                  Strings.advert_replay_txt,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                  ),
                ),
                gap: 10.w,
                onTap: () {
                  print("重新播放1");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant NormalAdvertView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleDetailTxtAnimation(oldWidget);
  }

  void _handleDetailTxtAnimation(NormalAdvertView oldWidget) {
    assert(oldWidget != null);
    if (_detailHighlightAnimationTimer != null)
      _detailHighlightAnimationTimer.cancel();

    if (_detailHighlightNotifier.value != widget.detailHighlight) {
      if (!widget.detailHighlight) {
        widget.onDetailHighlight?.call(false);
        _detailHighlightNotifier.value = false;
      } else {
        _detailHighlightAnimationTimer = Timer(_kDetailHighlightDuration, () {
          //callback function
          print('afterTimer=' + DateTime.now().toString()); // 5s之后
          widget.onDetailHighlight?.call(true);
          _detailHighlightNotifier.value = widget.detailHighlight;
          _detailHighlightAnimationTimer = null;
        });
      }
    }
  }

  void _initDetailHighlightNotifier() {
    if (widget.detailHighlight) {
      _detailHighlightAnimationTimer = Timer(_kDetailHighlightDuration, () {
        //callback function
        print('afterTimer=' + DateTime.now().toString()); // 5s之后
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDetailHighlight?.call(true);
          _detailHighlightNotifier.value = widget.detailHighlight;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("NormalAdvertView => ${hashCode} initState");
    _initDetailHighlightNotifier();
  }

  @override
  void dispose() {
    print("NormalAdvertView => ${hashCode} dispose");
    super.dispose();
  }

  @override
  bool get wantKeepAlive => false;
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
