import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/resources/res/dimens.dart';
import '../../page_controller.dart';
import '../../../ui/utils/icons_utils.dart' as utils;
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';

double itemVerticalSpacing = 3.0.w, itemHorizontalSpacing = 6.0.w;
double itemVerticalSize = (Dimens.design_screen_width.w - 3.0.w) / 2.0,
    itemHorizontalSize = (Dimens.design_screen_width.w - 6.0.w) / 2.5;

Widget buildVideoTitle(VideoItemTitle title) {
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

Widget buildBottom(VideoBottom bottom, VideoLayout layout) {
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
                      ? itemHorizontalSpacing
                      : itemVerticalSpacing),
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
                      ? itemHorizontalSpacing
                      : itemVerticalSpacing),
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