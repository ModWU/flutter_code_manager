import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import '../resources/export.dart';

class HeartBeatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PageChangeNotifier>(
      create: (context) => PageChangeNotifier(),
      child: MaterialApp(
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
      ),
    );
  }
}

class _HeartBeatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HeartBeatState();
}

class _HeartBeatState extends State<_HeartBeatPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context,
        PageChangeNotifier pageChangeNotifier, Widget child) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          // 底部导航
          items: PageIndexExtension.bottoms,
          currentIndex: pageChangeNotifier.pageIndex.index,
          fixedColor: Colors.black,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            Provider.of<PageChangeNotifier>(context, listen: false).pageIndex =
                PageIndex.values[index];
          },
        ),
        body: IndexedStack(
          index: pageChangeNotifier.pageIndex.index,
          children: PageIndexExtension.contents,
        ),
      );
    });
  }
}
