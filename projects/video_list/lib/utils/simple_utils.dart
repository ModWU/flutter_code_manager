import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void addBuildAfterCallback(VoidCallback callback) {
  assert(callback != null);
  //可能widget的树被锁定了,虽然WidgetsBinding.instance.hasScheduledFrame为true 此时也需要addPostFrameCallback
  //debugBuildingDirtyElements是为调试模式准备
  if (WidgetsBinding.instance.hasScheduledFrame ||
      WidgetsBinding.instance.debugBuildingDirtyElements) {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      callback();
    });
  } else {
    callback();
  }
}

double getStatusBarHeight() {
  return MediaQueryData.fromWindow(window).padding.top;
}

void setLandscapeScreen() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);
}

void setPortraitScreen() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
}
