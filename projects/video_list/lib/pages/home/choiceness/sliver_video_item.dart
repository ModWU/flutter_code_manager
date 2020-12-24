import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/resources/res/dimens.dart';
import '../../page_controller.dart';
import '../../../ui/utils/icons_utils.dart' as utils;
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'dart:ui' as ui show PlaceholderAlignment;
import 'video_page_utils.dart' as VideoPageUtils;

class VideoItemWidget extends StatefulWidget {
  final VideoItems items;

  VideoItemWidget(this.items);

  @override
  State<StatefulWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget>
    with AutomaticKeepAliveClientMixin {
  //double _bottomRefreshVerticalSpacing = 32.h;

  void _initDimens() {}

  @override
  void initState() {
    super.initState();
    _initDimens();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _buildVideoWithHorizontal(VideoItems item) {
    final List<VideoItem> items = item.items;
    final int count = items.length;

    return Container(
      height: VideoPageUtils.itemHorizontalSize,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        slivers: [
          SliverFixedExtentList(
            itemExtent: VideoPageUtils.itemHorizontalSize * 1.2,
            delegate: SliverChildBuilderDelegate((content, index) {
              return Padding(
                padding: EdgeInsets.only(
                    right: VideoPageUtils.itemHorizontalSpacing),
                child: _buildVideoItem(
                    items[index], VideoPageUtils.itemHorizontalSize),
              );
            }, childCount: count),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoHeader(VideoItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.w),
      child: Column(
        children: [
          Container(
            height: Dimens.design_screen_width.w * 0.5,
            width: Dimens.design_screen_width.w,
            child: _buildVideoBody(item),
          ),
          if (item.title?.preTitle != null) _buildVideoTitle(item),
        ],
      ),
    );
  }

  Widget _buildVideoBody(VideoItem item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.imgUrl, //"http://via.placeholder.com/288x188",
          fit: BoxFit.cover,
        ),
        if (item.markType != null)
          Positioned(
            right: 8.w,
            top: 8.w,
            child: utils.getMarkContainer(item.markType),
          ),
        if (item.time != null)
          Positioned(
            right: 8.w,
            bottom: 8.w,
            child: Text(
              item.time,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoTitle(VideoItem item) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 18.w, bottom: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: item.title.preTitle,
              children: item.title.lastTitle == null
                  ? null
                  : [
                      if (item.title.centerSign != null)
                        WidgetSpan(
                          child: utils.getSignIcon(item.title.centerSign,
                              size: 36.sp),
                          alignment: PlaceholderAlignment.middle,
                        ),
                      if (item.title.centerSign == null) TextSpan(text: " · "),
                      TextSpan(text: item.title.lastTitle),
                    ],
            ),
            style: TextStyle(
              fontSize: 28.sp,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (item.title.desc != null)
            Text(
              item.title.desc,
              style: TextStyle(
                fontSize: 22.sp,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(VideoItem item, double height) {
    return Container(
      height: height,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildVideoBody(item),
          ),
          if (item.title?.preTitle != null) _buildVideoTitle(item),
        ],
      ),
    );
  }

  Widget _buildVideoWithVertical(VideoItems item) {
    final List<VideoItem> items = List.from(item.items);
    final int count = items.length;

    final VideoItem headerItem = count.isOdd ? items.removeAt(0) : null;

    print("##count:$count, headerItem: $headerItem");

    return Column(
      children: [
        if (headerItem != null) (_buildVideoHeader(headerItem)),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          slivers: [
            SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 4.w,
                crossAxisSpacing: 4.w,
                childAspectRatio: 1.2,
                children: items
                    .map((e) =>
                        _buildVideoItem(e, VideoPageUtils.itemVerticalSize))
                    .toList()),
          ],
        ),
      ],
    );
  }

  Widget buildVideoItem(VideoItem item, {double height}) {
    return SizedBox(
      height: height,
      //width: 30,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imgUrl, //"http://via.placeholder.com/288x188",
                  fit: BoxFit.cover,
                ),
                if (item.markType != null)
                  Positioned(
                    right: 8.w,
                    top: 8.w,
                    child: utils.getMarkContainer(item.markType),
                  ),
                if (item.time != null)
                  Positioned(
                    right: 8.w,
                    bottom: 8.w,
                    child: Text(
                      item.time,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (item.title?.preTitle != null)
            Padding(
              padding: EdgeInsets.only(left: 24.w, top: 18.w, bottom: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      text: item.title.preTitle,
                      children: item.title.lastTitle == null
                          ? null
                          : [
                              if (item.title.centerSign != null)
                                WidgetSpan(
                                  child: utils.getSignIcon(
                                      item.title.centerSign,
                                      size: 36.sp),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                              if (item.title.centerSign == null)
                                TextSpan(text: " · "),
                              TextSpan(text: item.title.lastTitle),
                            ],
                    ),
                    style: TextStyle(
                      fontSize: 28.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (item.title.desc != null)
                    Text(
                      item.title.desc,
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget child;
    switch (widget.items.layout) {
      case VideoLayout.vertical:
        child = _buildVideoWithVertical(widget.items);
        break;
      default:
        child = _buildVideoWithHorizontal(widget.items);
    }

    return Column(
      children: [
        VideoPageUtils.buildVideoTitle(widget.items.title),
        child,
        if (widget.items.bottom != null)
          VideoPageUtils.buildBottom(widget.items.bottom, widget.items.layout),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
