import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'examples/basic_example.dart';
import 'examples/full_example.dart';
import 'pages/main_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'resources/export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ScreenUtil.init(designSize: Size(Dimens.design_screen_width, Dimens.design_screen_height), allowFontScaling: false);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp(HeartBeatApp());
  });

  //runApp(VideoApp());
  //runApp(FullVideoApp());
}