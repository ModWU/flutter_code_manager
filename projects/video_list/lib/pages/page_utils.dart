import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_list/models/base_model.dart';
import 'package:flutter_screenutil/size_extension.dart';

Container getTextContainer(String text,
    {Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double fontSize,
    double radius}) {
  if (horizontalSpace == null) horizontalSpace = 6.w;

  if (verticalSpace == null) verticalSpace = 2.w;

  if (fontSize == null) fontSize = 20.sp;

  if (radius == null) radius = 6.w;

  return Container(
    decoration: BoxDecoration(
      color: backgroundColor, //Colors.orangeAccent,
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: horizontalSpace,
      vertical: verticalSpace,
    ),
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    ),
  );
}

Container getMarkContainer(MarkType markType) {
  switch (markType) {
    case MarkType.advance:
      return getTextContainer("预告", backgroundColor: Colors.redAccent);
    case MarkType.advanced_request:
      return getTextContainer("超前点播", backgroundColor: Colors.orangeAccent);

    case MarkType.hynna_bubble_pop:
      return getTextContainer("独播", backgroundColor: Colors.orangeAccent);

    case MarkType.vip:
      return getTextContainer("VIP", backgroundColor: Colors.orangeAccent);

    case MarkType.self_made:
      return getTextContainer("自制", backgroundColor: Colors.redAccent);
  }
}

Icon getSignIcon(VideoSign sign, {double size}) {
  switch (sign) {
    case VideoSign.lightning:
      return Icon(
        Icons.nightlight_round,
        size: size,
        color: Colors.orangeAccent,
      );
    case VideoSign.hot:
      return Icon(
        Icons.whatshot_outlined,
        size: size,
        color: Colors.red,
      );

    case VideoSign.star:
      return Icon(
        Icons.star,
        size: size,
        color: Colors.orangeAccent,
      );

    case VideoSign.favorite:
      return Icon(
        Icons.favorite,
        size: size,
        color: Colors.red,
      );

    case VideoSign.sun:
      return Icon(
        Icons.wb_sunny,
        size: size,
        color: Colors.orangeAccent,
      );
  }
}
