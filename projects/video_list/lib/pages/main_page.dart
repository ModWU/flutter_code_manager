import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/ui/utils/triangle_arrow_decoration.dart';
import 'package:video_list/utils/view_utils.dart';
import 'file:///C:/wuchaochao/project/flutter_code_manager/projects/video_list/lib/ui/utils/icons_utils.dart';
import '../resources/export.dart';

class HeartBeatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      home:
          /*Center(
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.only(left: 0, top: 0),
          decoration: TriangleArrowDecoration(
            color: Colors.red,
            triangleArrowDirection: TriangleArrowDirection.topRight,
            arrowOffset: 12,
            arrowHeight: 12,
            arrowWidth: 12,
            arrowBreadth: 0,
            arrowSmoothness: 0,
            borderRadius: BorderRadius.all(
              Radius.elliptical(12, 12),
            ),
          ),
          child: Container(
            width: 200,
            height: 200,
            //color: Colors.yellow,
          ),
        ),
      ),*/
          Builder(
        builder: (BuildContext context) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (context) => PageChangeNotifier(context)),
            ],
            child: _HeartBeatPage(),
          );
        },
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
    print("statestatestatestate");
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
          currentIndex: pageChangeNotifier.pageIndex.index,
          fixedColor: Colors.black,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            //notifyChangePage(context, pageIndex: PageIndex.values[index]);
            Provider.of<PageChangeNotifier>(context, listen: false)
                .changeIndex(PageIndex.values[index]);
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
