import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../resources/export.dart';
import 'package:provider/provider.dart';
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
    ChoicenessPage(),
    TmpPage("爱看"),
    TmpPage("视频1"),
    TmpPage("视频2"),
    TmpPage("视频3"),
    TmpPage("视频4"),
    TmpPage("视频5"),
    TmpPage("视频6"),
    TmpPage("视频7"),
  ];

  @override
  void initState() {
    super.initState();
    print("MainPage -> initState()");

    _tabController = TabController(length: _dataList.length, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      //_tabTxtAnimationController.reset();
      if (_tabController.indexIsChanging && !_isPageAnimation) {
        _pageController.jumpToPage(_tabController.index);
      }
      _isPageAnimation = false;
    });

  }

  @override
  void dispose() {
    print("MainPage -> dispose()");
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
            _isPageAnimation = true;
            _tabController.animateTo(index);
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


