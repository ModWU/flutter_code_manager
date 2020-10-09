import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_list/models/base_model.dart';
import 'package:flutter_screenutil/size_extension.dart';

Widget getTextAnimatedContainer(String text,
    {Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double fontSize,
    bool animated,
    Matrix4 transform,
    Duration duration,
    Curve curve,
    EdgeInsets margin,
    VoidCallback onTap,
    VoidCallback onEnd,
    double radius}) {
  return getTextSpanAnimatedContainer(TextSpan(text: text),
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontWeight: fontWeight,
      horizontalSpace: horizontalSpace,
      verticalSpace: verticalSpace,
      fontSize: fontSize,
      transform: transform,
      duration: duration,
      margin: margin,
      curve: curve,
      onTap: onTap,
      onEnd: onEnd,
      radius: radius);
}

Widget getTextContainer(String text,
    {Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double fontSize,
    EdgeInsets margin,
    VoidCallback onTap,
    bool animated,
    double radius}) {
  return getTextSpanContainer(TextSpan(text: text),
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontWeight: fontWeight,
      horizontalSpace: horizontalSpace,
      verticalSpace: verticalSpace,
      fontSize: fontSize,
      margin: margin,
      onTap: onTap,
      animated: animated,
      radius: radius);
}

Widget getTextSpanAnimatedContainer(
  TextSpan textSpan, {
  Color backgroundColor = Colors.grey,
  Duration duration,
  Curve curve,
  VoidCallback onEnd,
  Color textColor = Colors.white,
  FontWeight fontWeight = FontWeight.w500,
  double horizontalSpace,
  double verticalSpace,
  double fontSize,
  EdgeInsets margin,
  double radius,
  VoidCallback onTap,
  Matrix4 transform,
}) {
  if (horizontalSpace == null) horizontalSpace = 6.w;

  if (verticalSpace == null) verticalSpace = 2.w;

  if (fontSize == null) fontSize = 20.sp;

  if (radius == null) radius = 6.w;

  print("getTextAnimatedContainer2 => $curve");

  Widget child = AnimatedContainer(
    transform: transform,
    duration: duration,
    curve: curve,
    onEnd: onEnd,
    margin: margin,
    decoration: BoxDecoration(
      color: backgroundColor, //Colors.orangeAccent,
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: horizontalSpace,
      vertical: verticalSpace,
    ),
    child: Text.rich(
      textSpan,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    ),
  );

  return onTap == null
      ? child
      : GestureDetector(
          onTap: onTap,
          child: child,
        );
}

Widget getTextSpanContainer(TextSpan textSpan,
    {Color backgroundColor = Colors.grey,
    bool animated = false,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double fontSize,
    EdgeInsets margin,
    VoidCallback onTap,
    double radius}) {
  if (horizontalSpace == null) horizontalSpace = 6.w;

  if (verticalSpace == null) verticalSpace = 2.w;

  if (fontSize == null) fontSize = 20.sp;

  if (radius == null) radius = 6.w;

  return getRadiusContainer(
      Text.rich(
        textSpan,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontWeight: fontWeight,
      horizontalSpace: horizontalSpace,
      verticalSpace: verticalSpace,
      fontSize: fontSize,
      onTap: onTap,
      margin: margin,
      animated: animated,
      radius: radius);
}

Widget getRadiusContainer(Widget child,
    {Color backgroundColor = Colors.grey,
    bool animated = false,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double fontSize,
    EdgeInsets margin,
    VoidCallback onTap,
    double radius}) {
  if (horizontalSpace == null) horizontalSpace = 6.w;

  if (verticalSpace == null) verticalSpace = 2.w;

  if (fontSize == null) fontSize = 20.sp;

  if (radius == null) radius = 6.w;

  Widget widget = Container(
    decoration: BoxDecoration(
      color: backgroundColor, //Colors.orangeAccent,
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    margin: margin,
    padding: EdgeInsets.symmetric(
      horizontal: horizontalSpace,
      vertical: verticalSpace,
    ),
    child: child,
  );

  return onTap == null
      ? widget
      : GestureDetector(
          onTap: onTap,
          child: widget,
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
