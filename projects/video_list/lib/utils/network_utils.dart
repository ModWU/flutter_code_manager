import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_list/utils/view_utils.dart' as ViewUtils;

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

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }
}
