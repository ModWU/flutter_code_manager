import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'examples/basic_example.dart';
import 'examples/full_example.dart';
import 'examples/owner_example.dart';
import 'pages/main_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'resources/export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp(HeartBeatApp());
  });

  //runApp(FullVideoApp());
  //runApp(VideoOwnerApp());
}