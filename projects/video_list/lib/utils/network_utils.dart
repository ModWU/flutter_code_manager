import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin NetworkStateMiXin<T extends StatefulWidget> on State<T> {
  bool _isHasNetwork = true;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool get hasNetwork => _isHasNetwork;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> checkConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @protected
  void onNetworkStateChange(ConnectivityResult result) {}

  @protected
  void onNetworkChange() {}

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    print("_updateConnectionStatus => result: $result mounted: $mounted");
    if (!mounted) {
      return;
    }
    bool isHasNetwork;
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        isHasNetwork = true;
        break;
      case ConnectivityResult.none:
        isHasNetwork = false;
        break;
      default:
        isHasNetwork = false;
        //'Failed to get connectivity.'
        break;
    }
    assert(isHasNetwork != null);
    if (isHasNetwork != _isHasNetwork) {
      _isHasNetwork = isHasNetwork;
      onNetworkChange();
    }

    onNetworkStateChange(result);
  }

  Widget buildNetworkErrorView({double width = double.infinity, double height = double.infinity}) {
    assert(width != null);
    assert(height != null);

    return Container(
      height: height,
      width: width,
      color: Colors.black87,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 12.0),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
              text: "视频加载失败，请稍后重试\n",
              style: TextStyle(
                  fontSize: 30.sp, color: Color.fromARGB(220, 255, 255, 255))),
          TextSpan(
              text: "(20300.10103)\n",
              style: TextStyle(fontSize: 24.sp, color: Colors.grey)),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                print("点击重试");
                checkConnectivity();
              },
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
                  "点击重试",
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

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }
}