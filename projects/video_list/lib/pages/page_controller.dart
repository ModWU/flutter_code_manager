import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_list/pages/personal_center/personal_center_page.dart';
import 'package:video_list/pages/video/video_page.dart';
import 'package:video_list/pages/vip/vip_page.dart';
import 'package:video_list/resources/res/strings.dart';
import 'package:video_list/ui/popup/popup_view.dart';
import 'package:video_list/ui/views/static_video_view.dart';
import 'home/home_page.dart';
import 'live_streaming/live_streaming_page.dart';

enum PageIndex {
  main_page,
  video_page,
  vip_page,
  live_streaming_page,
  personal_center_page,
}

/*class PageId {
  String _id;
  Map<String, PageId> _children;
  PageId _parent;

  PageId(String id, {List<PageId> children})
      : assert(id != null),
        _id = id {
    if (children != null) setChildren(children);
  }

  String get id => _id;

  String get fullId {
    List<String> id = [_id];
    StringBuffer buffer = StringBuffer();

    PageId parent = _parent;
    while (parent != null) id.add("${parent._id}-");

    buffer.writeAll(id.reversed);
    return buffer.toString();
  }

  PageId findChild(String id) => _children == null ? null : _children[id];

  PageId get parent => _parent;

  void setChild(PageId pageId) {
    assert(pageId != null && pageId._id != null);

    _children ??= {};
    _children[pageId._id] = pageId.._parent = this;
  }

  */ /*void addIndex(List<PageId> pageIds) {
    assert(pageIds != null && pageIds.isNotEmpty);
    _index ??= {};
    pageIds.forEach((pageId) {
      _index[pageId._id] = pageId;
      pageId._parent = this;
    });
  }*/ /*

  void setChildren(List<PageId> pageIds) {
    assert(pageIds != null && pageIds.isNotEmpty);
    _children = {};
    pageIds.forEach((pageId) {
      _children[pageId._id] = pageId;
      pageId._parent = this;
    });
  }
}*/

extension PageIndexExtension on PageIndex {
  /*static const String rootId = "root";

  static final PageId _rootPageId = PageId(rootId, children: [
    PageId(PageIndex.main_page.id),
    PageId(PageIndex.video_page.id),
    PageId(PageIndex.vip_page.id),
    PageId(PageIndex.live_streaming_page.id),
    PageId(PageIndex.personal_center_page.id),
  ]);*/

  static final List<BottomNavigationBarItem> bottoms = [
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

  static final List<Widget> contents = [
    MainPage(),
    VideoPage(),
    VipPage(),
    LiveStreamingPage(),
    PersonalCenterPage(),
  ];

  //PageId get pageId => _rootPageId.findChild(id);

  BottomNavigationBarItem get bottom => bottoms[index];

  Widget get content => contents[index];

  //String get id => toString();
}

class PageVisibleNotifier extends ChangeNotifier {
  bool _visible;

  void showPage() {
    if (_visible != null && _visible) return;
    _visible = true;
    notifyListeners();
  }

  void hidePage() {
    if (_visible != null && !_visible) return;
    _visible = false;
    notifyListeners();
  }

  bool get visible => _visible;
}

mixin PageVisibleMixin on Widget {
  final PageVisibleNotifier pageVisibleNotifier = PageVisibleNotifier();
}

class PageChangeNotifier with ChangeNotifier {
  PageIndex _pageIndex = PageIndex.main_page;

  void changeIndex(PageIndex pageIndex) {
    assert(pageIndex != null);
    if (pageIndex == _pageIndex) return;
    _pageIndex = pageIndex;
    notifyListeners();
  }

  PageIndex get pageIndex => _pageIndex;
}

class DetailHighlightInfo {
  bool _startDetailHighlight;
  bool _finishDetailHighlight;

  bool get startDetailHighlight => _startDetailHighlight;
  bool get finishDetailHighlight => _finishDetailHighlight;

  set startDetailHighlight(bool value) {
    assert(value != null);
    if (value == _startDetailHighlight) return;
    _startDetailHighlight = value;
  }

  set finishDetailHighlight(bool value) {
    assert(value != null);
    if (value == _finishDetailHighlight) return;
    _finishDetailHighlight = value;
  }

  DetailHighlightInfo(
      {bool startDetailHighlight = false, bool finishDetailHighlight = false})
      : assert(startDetailHighlight != null),
        assert(finishDetailHighlight != null),
        _startDetailHighlight = startDetailHighlight,
        _finishDetailHighlight = finishDetailHighlight;

  @override
  String toString() {
    return "DetailHighlightInfo {startDetailHighlight: $startDetailHighlight, finishDetailHighlight: $finishDetailHighlight}";
  }
}

class VideoPlayInfo {
  int playIndex;
  PlayState playState;
  Map<int, DetailHighlightInfo> detailHighlights;
  Map<int, PopupDirection> popupDirections;

  VideoPlayInfo copyWith({
    int playIndex,
    PlayState playState,
    Map<int, DetailHighlightInfo> detailHighlights,
    Map<int, PopupDirection> popupDirections,
  }) =>
      VideoPlayInfo(
        playIndex: playIndex ?? this.playIndex,
        playState: playState ?? this.playState,
        detailHighlights: detailHighlights ?? this.detailHighlights,
        popupDirections: popupDirections ?? this.popupDirections,
      );

  VideoPlayInfo(
      {this.playIndex = -1,
      this.playState,
      this.detailHighlights,
      this.popupDirections})
      : assert(playIndex != null);
}
