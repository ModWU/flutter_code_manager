import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_list/pages/personal_center/personal_center_page.dart';
import 'package:video_list/pages/video/video_page.dart';
import 'package:video_list/pages/vip/vip_page.dart';
import 'package:video_list/resources/res/strings.dart';
import 'home/home_page.dart';
import 'live_streaming/live_streaming_page.dart';

enum PageIndex {
  main_page,
  video_page,
  vip_page,
  live_streaming_page,
  personal_center_page,
}

extension PageIndexExtension on PageIndex {
  static const List<BottomNavigationBarItem> _btmNavTiles = [
    BottomNavigationBarItem(
        icon: Icon(Icons.home), label: Strings.btm_nav_main_tle),
    BottomNavigationBarItem(
        icon: Icon(Icons.business), label: Strings.btm_nav_video_tle),
    BottomNavigationBarItem(
        icon: Icon(Icons.school), label: Strings.btm_nav_vip_tle),
    BottomNavigationBarItem(
        icon: Icon(Icons.business), label: Strings.btm_nav_live_streaming_tle),
    BottomNavigationBarItem(
        icon: Icon(Icons.school), label: Strings.btm_nav_personal_center_tle),
  ];

  static const List<Widget> _contentWidgets = [
    MainPage(),
    VideoPage(),
    VipPage(),
    LiveStreamingPage(),
    PersonalCenterPage(),
  ];

  get bottom => _btmNavTiles[index];

  get content => _contentWidgets[index];

  static get bottoms => _btmNavTiles;

  static get contents => _contentWidgets;
}

abstract class BaseTabPage extends StatefulWidget {
  final PageIndex pageIndex;
  final int tabIndex;
  const BaseTabPage(this.pageIndex, this.tabIndex);
}

/*class BackgroundToForegroundNotifier with ChangeNotifier {
  void notifyAll() {
    notifyListeners();
  }
}*/

class PageChangeNotifier with ChangeNotifier {
  PageIndex _pageIndex;
  int _tabIndex;

  PageChangeNotifier(
      {PageIndex pageIndex = PageIndex.main_page, int tabIndex = 0})
      : _pageIndex = pageIndex,
        _tabIndex = tabIndex;

  set pageIndex(PageIndex pageIndex) {
    if (pageIndex == _pageIndex) return;
    _pageIndex = pageIndex;
    notifyListeners();
  }

  set tabIndex(int tabIndex) {
    if (tabIndex == _tabIndex) return;
    _tabIndex = tabIndex;
    notifyListeners();
  }

  int get tabIndex => _tabIndex;

  PageIndex get pageIndex => _pageIndex;
}
