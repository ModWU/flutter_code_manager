import 'package:flutter/material.dart';

Widget getTextAnimatedContainer(String text,
    {Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double horizontalInvisibleSpace = 0,
    double verticalInvisibleSpace = 0,
    bool invisibleSpaceClickable = true,
    double fontSize,
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
      horizontalInvisibleSpace: horizontalInvisibleSpace,
      verticalInvisibleSpace: verticalInvisibleSpace,
      invisibleSpaceClickable: invisibleSpaceClickable,
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
    double horizontalInvisibleSpace = 0,
    double verticalInvisibleSpace = 0,
    bool invisibleSpaceClickable = true,
    double fontSize,
    EdgeInsets margin,
    VoidCallback onTap,
    double radius}) {
  return getTextSpanContainer(TextSpan(text: text),
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontWeight: fontWeight,
      horizontalSpace: horizontalSpace,
      verticalSpace: verticalSpace,
      horizontalInvisibleSpace: horizontalInvisibleSpace,
      verticalInvisibleSpace: verticalInvisibleSpace,
      invisibleSpaceClickable: invisibleSpaceClickable,
      fontSize: fontSize,
      margin: margin,
      onTap: onTap,
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
  double horizontalInvisibleSpace = 0,
  double verticalInvisibleSpace = 0,
  bool invisibleSpaceClickable = true,
  double fontSize,
  EdgeInsets margin,
  double radius,
  VoidCallback onTap,
  Matrix4 transform,
}) {
  horizontalSpace ??= 6;

  verticalSpace ??= 2;

  fontSize ??= 20;

  radius ??= 6;

  Widget animatedChild = AnimatedContainer(
    transform: transform,
    duration: duration,
    curve: curve,
    onEnd: onEnd,
    margin: margin,
    /*decoration: BoxDecoration(
      color: backgroundColor, //Colors.orangeAccent,
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),*/
    color: backgroundColor,
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

  Widget widget = ClipRRect(
    clipper: RRectRangeClipper(
        horizontalSpace: horizontalInvisibleSpace,
        verticalSpace: verticalInvisibleSpace,
        radius: radius),
    child: animatedChild,
  );

  Widget result = onTap == null
      ? widget
      : GestureDetector(
          onTap: onTap,
          behavior: invisibleSpaceClickable ? HitTestBehavior.opaque : null,
          child: widget,
        );

  return margin == null
      ? result
      : Padding(
          padding: margin,
          child: result,
        );
}

Widget getTextSpanContainer(TextSpan textSpan,
    {Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double horizontalInvisibleSpace = 0,
    double verticalInvisibleSpace = 0,
    bool invisibleSpaceClickable = true,
    double fontSize,
    EdgeInsets margin,
    VoidCallback onTap,
    double radius}) {
  fontSize ??= 20;
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
      horizontalInvisibleSpace: horizontalInvisibleSpace,
      verticalInvisibleSpace: verticalInvisibleSpace,
      invisibleSpaceClickable: invisibleSpaceClickable,
      onTap: onTap,
      margin: margin,
      radius: radius);
}

Widget getRadiusContainer(Widget child,
    {Color backgroundColor = Colors.grey,
    Color textColor = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    double horizontalSpace,
    double verticalSpace,
    double horizontalInvisibleSpace,
    double verticalInvisibleSpace,
    bool invisibleSpaceClickable = true,
    EdgeInsets margin,
    VoidCallback onTap,
    double radius}) {
  horizontalSpace ??= 6;

  verticalSpace ??= 2;

  radius ??= 6;

  horizontalInvisibleSpace ??= 0.0;
  verticalInvisibleSpace ??= 0.0;

  print("invisibleSpaceClickable: $invisibleSpaceClickable");
  print("horizontalInvisibleSpace: $horizontalInvisibleSpace");
  print("verticalInvisibleSpace: $verticalInvisibleSpace");
  print("radius: $radius");

  //bool isHasInvisibleSpace = horizontalInvisibleSpace > 0 || verticalInvisibleSpace > 0;

  Widget container = Container(
    color: backgroundColor,
    padding: EdgeInsets.symmetric(
      horizontal: horizontalSpace,
      vertical: verticalSpace,
    ),
    child: child,
  );

  Widget widget = ClipRRect(
    clipper: RRectRangeClipper(
        horizontalSpace: horizontalInvisibleSpace,
        verticalSpace: verticalInvisibleSpace,
        radius: radius),
    child: container,
  );

  Widget result = onTap == null
      ? widget
      : GestureDetector(
          onTap: onTap,
          behavior: invisibleSpaceClickable ? HitTestBehavior.opaque : null,
          child: widget,
        );

  return margin == null
      ? result
      : Padding(
          padding: margin,
          child: result,
        );
}

class RRectRangeClipper extends CustomClipper<RRect> {
  RRectRangeClipper(
      {this.verticalSpace = 0, this.horizontalSpace = 0, this.radius = 0});

  final double verticalSpace;
  final double horizontalSpace;
  final double radius;

  @override
  RRect getClip(Size size) => RRect.fromLTRBR(
      horizontalSpace,
      verticalSpace,
      size.width - horizontalSpace,
      size.height - verticalSpace,
      Radius.circular(radius));

  @override
  bool shouldReclip(RRectRangeClipper oldClipper) {
    return oldClipper.verticalSpace != verticalSpace ||
        oldClipper.horizontalSpace != horizontalSpace ||
        oldClipper.radius != radius;
  }
}
