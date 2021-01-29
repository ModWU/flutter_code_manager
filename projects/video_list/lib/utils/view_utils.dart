import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:video_list/constants/error_code.dart';
import 'package:video_list/resources/res/strings.dart';
import 'package:video_list/ui/animations/implicit_animations.dart';

Widget buildText(Text text,
    {BoxDecoration decoration,
      Color backgroundColor,
      EdgeInsetsGeometry padding,
      EdgeInsetsGeometry margin,
      Matrix4 transform,
      GestureTapCallback onTap}) {
  assert(text != null);
  return _buildIconAndText(
    text: text,
    reserve: false,
    decoration: decoration,
    backgroundColor: backgroundColor,
    padding: padding,
    margin: margin,
    transform: transform,
    onTap: onTap,
  );
}

Widget buildIcon(Icon icon,
    {BoxDecoration decoration,
    Color backgroundColor,
    EdgeInsetsGeometry padding,
    EdgeInsetsGeometry margin,
    Matrix4 transform,
    GestureTapCallback onTap}) {
  assert(icon != null);
  return _buildIconAndText(
    icon: icon,
    reserve: false,
    decoration: decoration,
    backgroundColor: backgroundColor,
    padding: padding,
    margin: margin,
    transform: transform,
    onTap: onTap,
  );
}

Widget buildIconText(
        {Icon icon,
        Text text,
        double gap,
        BoxDecoration decoration,
        Color backgroundColor,
        EdgeInsetsGeometry padding,
        EdgeInsetsGeometry margin,
        Matrix4 transform,
        GestureTapCallback onTap}) =>
    _buildIconAndText(
      icon: icon,
      text: text,
      gap: gap,
      reserve: false,
      decoration: decoration,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      transform: transform,
      onTap: onTap,
    );

Widget buildIconTextWithAnimation({
  Icon icon,
  Text text,
  double gap,
  BoxDecoration decoration,
  Duration duration = const Duration(milliseconds: 500),
  TextStyle animationTextStyle,
  IconThemeData animationIconTheme,
  Curve curve = Curves.linear,
  VoidCallback onEnd,
  EdgeInsetsGeometry padding,
  EdgeInsetsGeometry margin,
  Matrix4 transform,
  Color backgroundColor,
  GestureTapCallback onTap,
}) {
  assert(duration != null);
  assert(curve != null);
  return _buildIconAndText(
    icon: icon,
    text: text,
    gap: gap,
    reserve: false,
    decoration: decoration,
    backgroundColor: backgroundColor,
    animationTextStyle: animationTextStyle,
    animationIconTheme: animationIconTheme,
    duration: duration,
    curve: curve,
    onEnd: onEnd,
    padding: padding,
    margin: margin,
    transform: transform,
    onTap: onTap,
  );
}

Widget buildTextIcon(
        {Icon icon,
        Text text,
        double gap,
        BoxDecoration decoration,
        Color backgroundColor,
        EdgeInsetsGeometry padding,
        EdgeInsetsGeometry margin,
        Matrix4 transform,
        GestureTapCallback onTap}) =>
    _buildIconAndText(
      icon: icon,
      text: text,
      gap: gap,
      reserve: true,
      decoration: decoration,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      transform: transform,
      onTap: onTap,
    );

Widget buildTextIconWithAnimation({
  Icon icon,
  Text text,
  double gap,
  BoxDecoration decoration,
  Duration duration = const Duration(milliseconds: 500),
  TextStyle animationTextStyle,
  IconThemeData animationIconTheme,
  Curve curve = Curves.linear,
  VoidCallback onEnd,
  EdgeInsetsGeometry padding,
  EdgeInsetsGeometry margin,
  Matrix4 transform,
  Color backgroundColor,
  GestureTapCallback onTap,
}) {
  assert(duration != null);
  assert(curve != null);
  return _buildIconAndText(
    icon: icon,
    text: text,
    gap: gap,
    reserve: true,
    decoration: decoration,
    backgroundColor: backgroundColor,
    animationTextStyle: animationTextStyle,
    animationIconTheme: animationIconTheme,
    duration: duration,
    curve: curve,
    onEnd: onEnd,
    padding: padding,
    margin: margin,
    transform: transform,
    onTap: onTap,
  );
}

List<Widget> _buildChildrenWithIconAndText(
    {Icon icon, Text text, double gap, bool reserve = false}) {
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
  return children;
}

Widget _buildIconAndText(
    {Icon icon,
    Text text,
    double gap,
    bool reserve = false,
    BoxDecoration decoration,
    Color backgroundColor,
    Duration duration,
    Curve curve,
    VoidCallback onEnd,
    Matrix4 transform,
    TextStyle animationTextStyle,
    IconThemeData animationIconTheme,
    EdgeInsetsGeometry padding,
    EdgeInsetsGeometry margin,
    GestureTapCallback onTap}) {
  assert(icon != null || text != null);
  assert(reserve != null);
  assert(
      backgroundColor == null || decoration == null,
      'Cannot provide both a color and a decoration\n'
      'To provide both, use "decoration: BoxDecoration(color: color)".');

  Widget child;

  final List<Widget> children = _buildChildrenWithIconAndText(
      icon: icon, text: text, gap: gap, reserve: reserve);
  assert(children != null);

  if (children.length > 1) {
    child = Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  } else {
    child = children[0];
  }

  final bool isHasAnimation = onEnd != null || duration != null;

  if (isHasAnimation &&
      (animationTextStyle != null || animationIconTheme != null)) {
    child = AnimatedDefaultIconTextStyle(
      style: animationTextStyle,
      iconTheme: animationIconTheme,
      duration: duration ?? Duration.zero,
      curve: curve ?? Curves.linear,
      onEnd: onEnd,
      child: child,
    );
  }

  return buildDecorationChild(
    child,
    decoration: decoration,
    padding: padding,
    margin: margin,
    backgroundColor: backgroundColor,
    duration: duration,
    curve: curve,
    onEnd: onEnd,
    transform: transform,
    onTap: onTap,
  );
}

Widget buildDecorationChild(Widget child,
    {EdgeInsetsGeometry padding,
    EdgeInsetsGeometry margin,
    BoxDecoration decoration,
    Duration duration,
    Curve curve,
    VoidCallback onEnd,
    Matrix4 transform,
    Color backgroundColor,
    GestureTapCallback onTap}) {
  assert(child != null);
  assert(
      backgroundColor == null || decoration == null,
      'Cannot provide both a color and a decoration\n'
      'To provide both, use "decoration: BoxDecoration(color: color)".');

  final bool isHasAnimation = onEnd != null || duration != null;
  if (isHasAnimation) {
    child = AnimatedContainer(
      transform: transform,
      duration: duration ?? Duration.zero,
      curve: curve ?? Curves.linear,
      onEnd: onEnd,
      decoration: decoration,
      color: backgroundColor,
      padding: padding,
      margin: margin,
      child: child,
    );
  } else {
    child = Container(
      decoration: decoration,
      color: backgroundColor,
      padding: padding,
      transform: transform,
      margin: margin,
      child: child,
    );
  }

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

setStatusBarColor(
    {Brightness brightness = Brightness.light,
    Color statusBarColor = Colors.transparent}) {
  assert(brightness != null);
  assert(statusBarColor != null);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Color(0xFF000000),
    //systemNavigationBarDividerColor: null,
    /// 注意安卓要想实现沉浸式的状态栏 需要底部设置透明色
    statusBarColor: statusBarColor,
    //systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: brightness,
    statusBarBrightness: brightness,
  ));
}
