import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_list/pages/page_controller.dart';
import '../../resources/export.dart';
import 'package:provider/provider.dart';
import '../page_utils.dart';
import 'choiceness/choiceness_page.dart';
import 'choiceness/tmp_page.dart';
import 'home_page_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPage extends StatefulWidget {

  const MainPage();

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {//TickerProviderStateMixin

  TabController _tabController;

  PageController _pageController;

  bool _isPageAnimation = false;

  List<String> _dataList = const [
    "精选",
    "爱看",
    "视频1",
    "视频2",
    "视频3",
    "视频4",
    "视频5",
    "视频6",
    "视频7",
  ];

  List<Widget> _pageList = const [
    ChoicenessPage(PageIndex.main_page, 0),
    TmpPage(PageIndex.main_page, 1, "爱看"),
    TmpPage(PageIndex.main_page, 2, "视频1"),
    TmpPage(PageIndex.main_page, 3,"视频2"),
    TmpPage(PageIndex.main_page, 4,"视频3"),
    TmpPage(PageIndex.main_page, 5,"视频4"),
    TmpPage(PageIndex.main_page, 6,"视频5"),
    TmpPage(PageIndex.main_page, 7,"视频6"),
    TmpPage(PageIndex.main_page, 8,"视频7"),
  ];

  @override
  void initState() {
    super.initState();
    print("_MainPageState -> initState()");

    _tabController = TabController(length: _dataList.length, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging && !_isPageAnimation) {
        _pageController.jumpToPage(_tabController.index);
      }
      _isPageAnimation = false;
    });

    /*_pageController.addListener(() {
     // print("page:${_pageController.page}  offset:${ _pageController.offset}  _tabController:${_tabController.index}");
     if (_pageController.page == _tabController.index) {
       print("_MainPageState page:${_pageController.page}  offset:${ _pageController.offset}  _tabController:${_tabController.index}");
       Provider.of<PageChangeNotifier>(context, listen: false).tabIndex = _tabController.index;
     }

    });*/

  }

  @override
  void dispose() {
    print("_MainPageState -> dispose()");
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "home",
      theme: Theme.of(context).copyWith(),
      home: Scaffold(
        appBar: PreferredSize(
          child: HeartBeatBar(
              _dataList,
              _tabController
          ),
          preferredSize: Size.fromHeight(Dimens.action_bar_height),//可以移动的边距
        ),
        body: PageView(
          children: _pageList,
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            print("_MainPageState onPageChanged: ${index}");
            _isPageAnimation = true;
            _tabController.animateTo(index);
            notifyChangePage(context, tabIndex: index);
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


