import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_list/pages/personal_center/personal_center_page.dart';
import 'package:video_list/pages/video/video_page.dart';
import 'package:video_list/pages/vip/vip_page.dart';
import '../resources/export.dart';
import 'package:provider/provider.dart';
import 'home/home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'live_streaming/live_streaming_page.dart';

/*primaryIconTheme:  IconThemeData(color: Colors.black),
appBarTheme: AppBarTheme(
// color: Theme.of(context).scaffoldBackgroundColor,

),
textTheme: TextTheme(

),
splashColor: Colors.transparent, // 点击时的高亮效果设置为透明
highlightColor: Colors.transparent, // 长按时的扩散效果设置为透明*/

class HeartBeatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.app_name,
      theme: ThemeData(
        disabledColor: Colors.grey,//一切按钮不可点击的默认颜色
        iconTheme: IconThemeData(color: Colors.black),//一切包含图标的默认颜色（）
        primaryIconTheme:  IconThemeData(color: Colors.black),//包括appBar上图标的颜色
        //accentIconTheme: IconThemeData(color: Colors.blue),
        //brightness: Brightness.dark,
        /*accentColor: Colors.orange,
        primaryColor: Colors.blue,
        primarySwatch: Colors.yellow,
        textSelectionColor: Colors.red,
        hintColor: Colors.red,
        unselectedWidgetColor: Colors.blue,
        accentTextTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText1: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.blue),
          bodyText2: TextStyle(fontSize: 44.0, fontFamily: 'Hind', color: Colors.red),
        ),*/


        appBarTheme: AppBarTheme(
            color: Theme.of(context).scaffoldBackgroundColor,//appBar的背景色
           /* textTheme:  TextTheme(
              headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
              subtitle1: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
              bodyText1: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.blue),
              bodyText2: TextStyle(fontSize: 44.0, fontFamily: 'Hind', color: Colors.red),
            ),*/
        ),


        /*textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText1: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.blue),
          bodyText2: TextStyle(fontSize: 44.0, fontFamily: 'Hind', color: Colors.red),
        ),*/
        splashColor: Colors.transparent, // 点击时的高亮效果设置为透明，包括tab
        highlightColor: Colors.transparent, // 长按时的扩散效果设置为透明
      ),
      home: _HeartBeatPage(),
    );
  }
}

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
        icon: Icon(Icons.business),
        label: Strings.btm_nav_live_streaming_tle),
    BottomNavigationBarItem(
        icon: Icon(Icons.school),
        label: Strings.btm_nav_personal_center_tle),
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

class _HeartBeatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HeartBeatState();
}

class _HeartBeatState extends State<_HeartBeatPage> {
  PageIndex _pageIndex = PageIndex.main_page;



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBody() {
    switch (_pageIndex) {
      case PageIndex.video_page:
        return VideoPage();

      case PageIndex.vip_page:
        return VipPage();

      case PageIndex.live_streaming_page:
        return LiveStreamingPage();

      case PageIndex.personal_center_page:
        return PersonalCenterPage();

      case PageIndex.main_page:
      default:
        return MainPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        // 底部导航
        items: PageIndexExtension.bottoms,
        currentIndex: _pageIndex.index,
        fixedColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _pageIndex = PageIndex.values[index];
          });
        },
      ),
      body: IndexedStack(
        index: _pageIndex.index,
        children: PageIndexExtension.contents,
      ),
    );
  }
}
