import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_list/pages/page_controller.dart';
import '../../resources/export.dart';
import 'package:provider/provider.dart';
import '../page_utils.dart';
import 'choiceness/page_home.dart';
import 'choiceness/tmp_page.dart';
import 'home_page_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MainPage extends StatefulWidget {

  //MainPage() : super(PageIndex.main_page.pageId);

  @override
  State<StatefulWidget> createState() => _MainPageState();

  /*static const String id_choiceness = "choiceness";

  @override
  Map<String, PageId> getChildrenPageId() {
    return <String, PageId>{
      id_choiceness: PageId(id_choiceness),
    };
  }*/


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

  List<PageVisibleMixin> _pageList = [
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
    print("_MainPageState -> initState()");

    _tabController = TabController(length: _dataList.length, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (!_isPageAnimation)
          _pageController.jumpToPage(_tabController.index);
        //当切换顶部tab时
        print("tab page change=> current:${_tabController.index}, previous:${_tabController.previousIndex}");
        _pageList[_tabController.previousIndex].pageVisibleNotifier.hidePage();
        _pageList[_tabController.index].pageVisibleNotifier.showPage();
      }
      _isPageAnimation = false;
    });

    //当底部按钮切换时
    Provider.of<PageChangeNotifier>(context, listen: false).addListener(() {
      PageIndex pageIndex = Provider.of<PageChangeNotifier>(context, listen: false).pageIndex;
      int currentTabIndex = _tabController.index;
      if (pageIndex == PageIndex.main_page) {
        //通知当前tab页显示了
        print("通知主页的当前tab显示: $currentTabIndex");
        _pageList[currentTabIndex].pageVisibleNotifier.showPage();
      } else {
        //通知当前tab页隐藏了
        print("通知主页的当前tab隐藏: $currentTabIndex");
        _pageList[currentTabIndex].pageVisibleNotifier.hidePage();
      }

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
    super.build(context);
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
        body: NotificationListener(
          onNotification: (ScrollNotification note) {
            //print(note.metrics.pixels.toInt());  // 滚动位置。
            // print("scroll: ${note.metrics.pixels}");
            /*if (note.metrics.axis == Axis.vertical) {
                      print(
                          "axis: ${note.metrics.axis == Axis.horizontal ? "水平" : "垂直"}, extentAfter:${note.metrics.extentAfter}, extentBefore:${note.metrics.extentBefore}, extentInside:${note.metrics.extentInside}, pixels:${note.metrics.pixels}, viewportDimension:${note.metrics.viewportDimension}, minScrollExtent:${note.metrics.minScrollExtent}, maxScrollExtent:${note.metrics.minScrollExtent}");

                      print(
                          "差值：${note.metrics.extentBefore - note.metrics.extentAfter}");
                    }*/
            //notifyScrollPage(context, widget.pageIndex, widget.tabIndex, note.metrics);
            //print(note.metrics.pixels.toInt());

            //当前滚动通知只监听首页的所有tab页的滚动
            _pageList[_tabController.index].pageScrollNotifier.scroll(note.metrics);

            return false;
          },
          child: PageView(
            children: _pageList,
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              _isPageAnimation = true;
              _tabController.animateTo(index);
            },
          ),
        )
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}


