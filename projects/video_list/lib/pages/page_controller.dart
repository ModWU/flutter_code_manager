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

mixin PageScrollMiXin on ChangeNotifier {
  Map<String, ScrollMetrics> _saveVerticalPositions;
  Map<String, ScrollMetrics> _saveHorizontalPositions;

  void _putMetrics(PageIndex pageIndex, int tabIndex, ScrollMetrics metrics) {
    _saveVerticalPositions ??= {};
    _saveHorizontalPositions ??= {};

    String actId = "${pageIndex.index}_$tabIndex";

    if (metrics.axis == Axis.vertical)
      _saveVerticalPositions[actId] = metrics;
    else if (metrics.axis == Axis.horizontal)
      _saveHorizontalPositions[actId] = metrics;
  }

  /*void scrollByVertical(
      PageIndex pageIndex, int tabIndex, ScrollMetrics metrics) {
    if (metrics.axis == Axis.vertical) {
      _putMetrics(pageIndex, tabIndex, metrics);
      notifyListeners();
    }
  }

  void scrollByHorizontal(
      PageIndex pageIndex, int tabIndex, ScrollMetrics metrics) {
    if (metrics.axis == Axis.horizontal) {
      _putMetrics(pageIndex, tabIndex, metrics);
      notifyListeners();
    }
  }*/

  void scroll(PageIndex pageIndex, int tabIndex, ScrollMetrics metrics) {
    _putMetrics(pageIndex, tabIndex, metrics);
    notifyListeners();
  }

  ScrollMetrics getMetrics(Axis axis, PageIndex pageIndex, int tabIndex) {
    return axis == Axis.horizontal
        ? (_saveHorizontalPositions == null
            ? null
            : _saveHorizontalPositions["${pageIndex.index}_$tabIndex"])
        : (_saveVerticalPositions == null
            ? null
            : _saveVerticalPositions["${pageIndex.index}_$tabIndex"]);
  }
}

mixin PageChangeMiXin on ChangeNotifier {
  Map<PageIndex, int> _saveIndex = {PageIndex.main_page: 0};
  PageIndex _currentPageIndex = PageIndex.main_page;

  void _putTabIndex(PageIndex pageIndex, int tabIndex) {
    _saveIndex[pageIndex] = tabIndex;
  }

  int getTabIndex(PageIndex pageIndex) {
    return _saveIndex[pageIndex];
  }

  void changeIndex({PageIndex pageIndex, int tabIndex}) {
    tabIndex ??= _saveIndex[pageIndex] ?? 0;

    pageIndex ??= _currentPageIndex;

    if (pageIndex == _currentPageIndex && _saveIndex[pageIndex] == tabIndex)
      return;

    _currentPageIndex = pageIndex;
    _putTabIndex(pageIndex, tabIndex);
    notifyListeners();
  }

  PageIndex get currentPageIndex => _currentPageIndex;
  int get currentTabIndex => _saveIndex[_currentPageIndex];
}

class PageScrollNotifier with ChangeNotifier, PageScrollMiXin {}

class PageChangeNotifier with ChangeNotifier, PageChangeMiXin {}

class PageChangeAndScrollNotifier
    with ChangeNotifier, PageChangeMiXin, PageScrollMiXin {
  bool _isPageChange;

  void changeIndex({PageIndex pageIndex, int tabIndex}) {
    _isPageChange = true;
    super.changeIndex(pageIndex: pageIndex, tabIndex: tabIndex);
  }

  void scroll(PageIndex pageIndex, int tabIndex, ScrollMetrics metrics) {
    _isPageChange = false;
    super.scroll(pageIndex, tabIndex, metrics);
  }

  bool get isPageChange => _isPageChange;
}
