import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/pages/page_utils.dart';
import '../resources/export.dart';

class HeartBeatApp extends StatelessWidget {
  Widget _buildApp(BuildContext context) {
    return MaterialApp(
      title: Strings.app_name,
      theme: ThemeData(
        disabledColor: Colors.grey, //一切按钮不可点击的默认颜色
        iconTheme: IconThemeData(color: Colors.black), //一切包含图标的默认颜色（）
        primaryIconTheme: IconThemeData(color: Colors.black), //包括appBar上图标的颜色
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
          color: Theme.of(context).scaffoldBackgroundColor, //appBar的背景色
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PageChangeNotifier()),
        ChangeNotifierProvider(create: (context) => PageChangeAndScrollNotifier()),
        ChangeNotifierProvider(create: (context) => PageScrollNotifier()),
        /*ChangeNotifierProvider(
            create: (context) => BackgroundToForegroundNotifier()),*/
      ],
      child: _buildApp(context),
    );
  }
}

class _HeartBeatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HeartBeatState();
}

class _HeartBeatState extends State<_HeartBeatPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /*//进入后台不可见，此时任何界面的更新都不会有效果，包括Provider
  void _enterBackground() {
    //Provider.of<PageChangeNotifier>(context, listen: false).visible = false;
  }

  //进入前台可见
  void _enterForeground() {
    //Provider.of<BackgroundToForegroundNotifier>(context, listen: false).notifyAll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("mainPage didChangeAppLifecycleState -> 进入后台");
      _enterBackground();
    }
    if (state == AppLifecycleState.resumed) {
      print("mainPage didChangeAppLifecycleState -> 进入前台");
      _enterForeground();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    print("top top top build...");
    ScreenUtil.init(context,
        designSize:
            Size(Dimens.design_screen_width, Dimens.design_screen_height),
        allowFontScaling: false);
    return Consumer(builder: (BuildContext context,
        PageChangeNotifier pageChangeNotifier, Widget child) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          // 底部导航
          items: PageIndexExtension.bottoms,
          currentIndex: pageChangeNotifier.currentPageIndex.index,
          fixedColor: Colors.black,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            notifyChangePage(context, pageIndex: PageIndex.values[index]);
          },
        ),
        body: IndexedStack(
          index: pageChangeNotifier.currentPageIndex.index,
          children: PageIndexExtension.contents,
        ),
      );
    });
  }
}
