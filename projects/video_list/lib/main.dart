import 'package:flutter/material.dart';
import 'examples/basic_example.dart';
import 'examples/full_example.dart';
import 'pages/main_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'resources/export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ScreenUtil.init(designSize: Size(Dimens.design_screen_width, Dimens.design_screen_height), allowFontScaling: false);
  runApp(HeartBeatApp());
  //runApp(VideoApp());
  //runApp(FullVideoApp());
}