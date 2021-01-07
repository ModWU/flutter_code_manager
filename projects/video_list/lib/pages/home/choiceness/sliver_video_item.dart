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
import 'video_page_utils.dart';

class VideoItemWidget extends StatefulWidget {
  final VideoItems items;

  VideoItemWidget(this.items);

  @override
  State<StatefulWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget>
    with AutomaticKeepAliveClientMixin {
  //double _bottomRefreshVerticalSpacing = 32.h;


  @override
  void initState() {
    super.initState();
    print("_VideoItemWidgetState => ${hashCode} initState");
  }

  @override
  void dispose() {
   print("_VideoItemWidgetState => ${hashCode} dispose");
    super.dispose();
  }

  Widget _buildVideoWithHorizontal(VideoItems item) {
    final List<VideoItem> items = item.items;
    final int count = items.length;

    return Container(
      height: HeightMeasurer.itemHeightWithHorizontalList,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        slivers: [
          SliverFixedExtentList(
            itemExtent: HeightMeasurer.itemHeightWithHorizontalList * 1.2,
            delegate: SliverChildBuilderDelegate((content, index) {
              return Padding(
                padding: EdgeInsets.only(right: itemHorizontalSpacing),
                child: _buildVideoItem(items[index]),
              );
            }, childCount: count),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoHeader(VideoItem item) {
    return Column(
      children: [
        Container(
          height: HeightMeasurer.itemHeaderHeightWithVerticalList,
          width: double.infinity,
          child: _buildVideoBody(item),
        ),
        if (item.title?.preTitle != null) _buildVideoTitle(item),
      ],
    );
    /* return Padding(
      padding: EdgeInsets.only(bottom: HeightMeasurer.itemVideoMainAxisSpaceHeightWithVerticalList),
      child: ,
    );*/
  }

  Widget _buildVideoBody(VideoItem item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(item.imgUrl, //"http://via.placeholder.com/288x188",
            fit: BoxFit.cover, errorBuilder:
                (BuildContext context, Object error, StackTrace stackTrace) {
          return SizedBox.shrink();
        }),
        if (item.markType != null)
          Positioned(
            right: 8.w,
            top: 8.w,
            child: utils.getMarkContainer(item.markType),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.all(Radius.circular(28)),
              // border: Border.all(color: Color(0xFFFF0000), width: 0),
              shape: BoxShape.rectangle,
              color: Colors.black26,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: FractionalOffset
                    .topCenter, // 10% of the width, so there are ten blinds.
                colors: [
                  Colors.black,
                  Colors.transparent,
                ], // whitish to gray
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
            ),
          ),
        ),
        if (item.time != null)
          Positioned(
            right: 6,
            bottom: 6,
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
    return Container(
      padding: EdgeInsets.only(left: 24.w, top: 18.w, bottom: 18.w),
      height: HeightMeasurer.itemVideoTitleHeightWithVerticalList,
      //color: Colors.yellow,
      alignment: Alignment.center,
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

  Widget _buildVideoItem(VideoItem item) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildVideoBody(item),
        ),
        if (item.title?.preTitle != null) _buildVideoTitle(item),
      ],
    );
  }

  Widget _buildVideoWithVertical(VideoItems item) {
    final List<VideoItem> items = List.from(item.items);

    final VideoItem headerItem = items.length.isOdd ? items.removeAt(0) : null;

    return Column(
      children: [
        if (headerItem != null)
          Padding(
            padding: items.length > 0
                ? EdgeInsets.only(
                    bottom:
                        HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList)
                : 0,
            child: _buildVideoHeader(headerItem),
          ),
        if (items.length > 0)
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            slivers: [
              SliverGrid.count(
                  crossAxisCount:
                      HeightMeasurer.itemVideoCrossAxisCountWithVerticalList,
                  mainAxisSpacing:
                      HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList,
                  crossAxisSpacing:
                      HeightMeasurer.itemVideoCrossAxisSpaceWithVerticalList,
                  childAspectRatio:
                      HeightMeasurer.itemVideoAspectRatioWithVerticalList,
                  children: items.map((e) => _buildVideoItem(e)).toList()),
            ],
          ),
      ],
    );
  }

  /*Widget buildVideoItem(VideoItem item, {double height}) {
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
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace stackTrace) {
                    return SizedBox.shrink();
                  },
                ),
                if (item.markType != null)
                  Positioned(
                    right: 8.w,
                    top: 8.w,
                    child: utils.getMarkContainer(item.markType),
                  ),
                Container(
                  width: 25.h,
                  height: 25.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red, //底色,阴影颜色
                        offset: Offset(0, 0), //阴影位置,从什么位置开始
                        blurRadius: 1, // 阴影模糊层度
                        spreadRadius: 0,
                      ) //阴影模糊大小
                    ],
                  ),
                  child: Container(),
                ),
                if (item.time != null)
                  Positioned(
                    right: 8,
                    bottom: 8,
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
  }*/

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
        buildVideoTitle(widget.items.title),
        child,
        if (widget.items.bottom != null &&
            (widget.items.bottom.isHasRefresh ||
                widget.items.bottom.playTitle != null))
          buildBottom(widget.items.bottom, widget.items.layout),
      ],
    );
  }

  @override
  bool get wantKeepAlive => false;
}
