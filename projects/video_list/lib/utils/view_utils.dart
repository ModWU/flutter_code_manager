import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:video_list/constants/error_code.dart';
import 'package:video_list/resources/res/strings.dart';

Widget buildIconText(
        {Icon icon,
        Text text,
        double gap,
        BoxDecoration decoration,
        EdgeInsetsGeometry padding,
        EdgeInsetsGeometry margin,
        GestureTapCallback onTap}) =>
    _buildIconAndText(
      icon: icon,
      text: text,
      gap: gap,
      reserve: false,
      decoration: decoration,
      padding: padding,
      margin: margin,
      onTap: onTap,
    );

Widget buildTextIcon(
        {Icon icon,
        Text text,
        double gap,
        BoxDecoration decoration,
        EdgeInsetsGeometry padding,
        EdgeInsetsGeometry margin,
        GestureTapCallback onTap}) =>
    _buildIconAndText(
      icon: icon,
      text: text,
      gap: gap,
      reserve: true,
      decoration: decoration,
      padding: padding,
      margin: margin,
      onTap: onTap,
    );

Widget _buildIconAndText(
    {Icon icon,
    Text text,
    double gap,
    bool reserve = false,
    BoxDecoration decoration,
    EdgeInsetsGeometry padding,
    EdgeInsetsGeometry margin,
    GestureTapCallback onTap}) {
  assert(icon != null || text != null);
  assert(reserve != null);

  List<Widget> children;
  if (icon != null && text != null) {
    if (reserve) {
      children = [
        Padding(
          padding: EdgeInsets.only(right: gap ?? 0),
          child: text,
        ),
        icon,
      ];
    } else {
      children = [
        Padding(
          padding: EdgeInsets.only(right: gap ?? 0),
          child: icon,
        ),
        text,
      ];
    }
  } else if (icon != null) {
    children = [icon];
  } else {
    children = [text];
  }

  return buildDecorationChildren(
    children,
    decoration: decoration,
    padding: padding,
    margin: margin,
    onTap: onTap,
  );
}

Widget buildDecorationChildren(List<Widget> children,
    {BoxDecoration decoration,
    EdgeInsetsGeometry padding,
    EdgeInsetsGeometry margin,
    GestureTapCallback onTap}) {
  assert(children != null && children.isNotEmpty);

  Widget innerChild;
  if (children.length > 1) {
    innerChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  } else {
    innerChild = children[0];
  }

  final Widget child = decoration != null || margin != null
      ? Container(
          decoration: decoration,
          padding: padding,
          margin: margin,
          child: innerChild,
        )
      : innerChild;

  return onTap != null
      ? GestureDetector(
          onTap: onTap,
          child: child,
        )
      : child;
}

Widget buildNetworkErrorView(
    {double width = double.infinity,
      double height = double.infinity,
      String errorCode = "(${NetworkErrorCode.network_connectivity_error})",
      GestureTapCallback onTap}) {
  assert(width != null);
  assert(height != null);
  assert(errorCode != null);
  assert(onTap != null);

  return Container(
    height: height,
    width: width,
    color: Colors.black87,
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: Text.rich(
      TextSpan(children: [
        TextSpan(
            text: "${Strings.video_network_error}\n",
            style: TextStyle(
                fontSize: 30.sp, color: Color.fromARGB(220, 255, 255, 255))),
        TextSpan(
            text: "$errorCode\n",
            style: TextStyle(fontSize: 24.sp, color: Colors.grey)),
        WidgetSpan(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: new BoxDecoration(
                color: Colors.white12,
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              margin: EdgeInsets.only(top: 16.0),
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
              child: Text(
                Strings.click_again_text,
                style: TextStyle(
                  fontSize: 30.sp,
                  color: Color.fromARGB(220, 255, 255, 255),
                ),
              ),
            ),
          ),
        ),
      ]),
      textAlign: TextAlign.center,
    ),
  );
}
