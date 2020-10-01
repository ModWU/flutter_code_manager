import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/resources/res/dimens.dart';
import '../../page_controller.dart';
import '../../page_utils.dart' as utils;
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'dart:ui' as ui show PlaceholderAlignment;

class VideoItemWidget extends BaseTabPage {
  final ItemMiXin items;
  final int index;

  const VideoItemWidget(
      PageIndex pageIndex, int tabIndex, this.index, this.items)
      : super(pageIndex, tabIndex);

  @override
  State<StatefulWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget> with AutomaticKeepAliveClientMixin {
  double _itemVerticalSpacing = 3.0.w, _itemHorizontalSpacing = 6.0.w;
  double _itemVerticalSize = (Dimens.design_screen_width.w - 3.0.w) / 2.0,
      _itemHorizontalSize = (Dimens.design_screen_width.w - 6.0.w) / 2.5;

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
    List<VideoItem> items = item.items;
    int count = items.length;

    //double height = item.title?.preTitle == null ? _itemHorizontalSizeWithoutTitle : _itemHorizontalSizeWithTitle;

    return Container(
      height: _itemHorizontalSize,
      width: Dimens.design_screen_width.w,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: count,
          //padding: EdgeInsets.only(left: 5, right: 5),
          itemExtent: _itemHorizontalSize * 1.2,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),

          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(right: _itemHorizontalSpacing),
              child: _buildVideoItem(items[index], height: _itemHorizontalSize),
            );
          }),
    );
  }

  Widget _buildVideoItem(VideoItem item, {double height}) {
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

  Widget _buildVideoWithVertical(VideoItems item) {
    List<VideoItem> items = item.items;

    int count = items.length;

    VideoItem headVideoItem;

    if (count.isOdd) {
      headVideoItem = items.removeAt(0);
      count--;
    }

    return Column(
      children: [
        if (headVideoItem != null)
          _buildVideoItem(headVideoItem,
              height: Dimens.design_screen_width.w / 2.0),
        if (count > 0)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: _itemVerticalSpacing,
            //maxCrossAxisExtent: 120.0,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: items
                .map((e) => _buildVideoItem(e, height: _itemVerticalSize))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildTitle(VideoItemTitle title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 28.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              print("点击了左边标题");
            },
            child: Text.rich(
              TextSpan(
                text: title.preTitle,
                children: [
                  if (title.centerSign != null)
                    WidgetSpan(
                      child: utils.getSignIcon(title.centerSign, size: 36.sp),
                      alignment: PlaceholderAlignment.middle,
                    ),
                  if (title.centerSign != null && title.lastTitle != null)
                    TextSpan(text: (title.lastTitle)),
                  if (title.rightArrow)
                    WidgetSpan(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 26.sp,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                ],
              ),
              overflow: TextOverflow.visible,
              maxLines: 1,
              // textWidthBasis: TextWidthBasis.longestLine,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (title.desc != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: GestureDetector(
                onTap: () {
                  print("点击了右边描述按钮");
                },
                child: Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.descSign != null)
                        utils.getSignIcon(title.descSign, size: 32.sp),
                      Text(
                        title.desc,
                        style: TextStyle(
                          fontSize: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData iconData, TextSpan textSpan,
      {GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(
              iconData,
              color: Colors.red,
              size: 36.w,
            ),
          ),
          Text.rich(
            textSpan,
            overflow: TextOverflow.visible,
            maxLines: 1,
            style: TextStyle(
              fontSize: 22.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(VideoBottom bottom, VideoLayout layout) {
    if (bottom == null) return null;

    if (!bottom.isHasRefresh && bottom.playTitle == null) return null;

    bool isOnlyOne =
        bottom.isHasRefresh ? (bottom.playTitle != null ? false : true) : true;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        /* mainAxisAlignment: isOnlyOne
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,*/

        children: [
          if (bottom.playTitle != null)
            Expanded(
              flex: 1,
              child: Padding(
                padding: isOnlyOne
                    ? EdgeInsets.zero
                    : EdgeInsets.only(
                        right: layout == VideoLayout.horizontal
                            ? _itemHorizontalSpacing
                            : _itemVerticalSpacing),
                child: Center(
                  child: _buildBottomIcon(
                    Icons.play_circle_outline,
                    TextSpan(
                      text: bottom.playTitle,
                      children: bottom.playSign == null
                          ? null
                          : [
                              WidgetSpan(
                                child: utils.getSignIcon(bottom.playSign,
                                    size: 12),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              if (bottom.playDesc != null)
                                TextSpan(
                                  text: bottom.playDesc,
                                ),
                            ],
                    ),
                    onTap: () {
                      print("点击了${bottom.playTitle}");
                    },
                  ),
                ),
              ),
            ),
          if (bottom.isHasRefresh)
            Expanded(
              flex: 1,
              child: Padding(
                padding: isOnlyOne
                    ? EdgeInsets.zero
                    : EdgeInsets.only(
                        left: layout == VideoLayout.horizontal
                            ? _itemHorizontalSpacing
                            : _itemVerticalSpacing),
                child: Center(
                  child: _buildBottomIcon(
                    Icons.refresh,
                    TextSpan(text: "换一换"),
                    onTap: () {
                      print("换一换");
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoItems(BuildContext context, VideoItems items) {
    Widget child;

    Widget titleWidget = _buildTitle(items.title);

    Widget bottomWidget = _buildBottom(items.bottom, items.layout);

    switch (items.layout) {
      case VideoLayout.horizontal:
        child = _buildVideoWithHorizontal(items);
        break;

      case VideoLayout.vertical:
        child = _buildVideoWithVertical(items);
        break;
    }

    return Column(
      children: [
        titleWidget,
        child,
        if (bottomWidget != null) bottomWidget,
      ],
    );
  }

  Widget _buildAdvertItem(BuildContext context, AdvertItem item) {
    return Text(
      "广告",
      style: TextStyle(fontSize: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items is VideoItems) {
      return _buildVideoItems(context, widget.items as VideoItems);
    } else if (widget.items is AdvertItem) {
      return _buildAdvertItem(context, widget.items as AdvertItem);
    }

    return null;
  }

  @override
  bool get wantKeepAlive => true;
}
