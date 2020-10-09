import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HeartBeatBar extends StatefulWidget {
  const HeartBeatBar(this.datas, this.tabController);

  final List<String> datas;
  final TabController tabController;

  @override
  State<StatefulWidget> createState() => _HeartBeatBarState();
}

class _HeartBeatBarState extends State<HeartBeatBar>
    with TickerProviderStateMixin {

  /*Animation<double> _tabTxtAnimation;
  AnimationController _tabTxtAnimationController;*/

  static const double _tabTxtFac = 0.5;
  static const double _tabUnSectedTxtSize = 14;
  static const double _tabSectedTxtSize =
      _tabUnSectedTxtSize * (1 + _tabTxtFac);

  static const double _actionLeadingSpace = 12.0,
                      _tabMargin = 12.0,
                      _barLeadingLeft = 12.0;

  AnimationController scaleController;
  Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();

    scaleController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    Animation scaleCurve =
        new CurvedAnimation(parent: scaleController, curve: Curves.easeIn);

    scaleAnimation = new Tween(begin: _tabTxtFac, end: 1.0).animate(scaleCurve);

    scaleController.value = 1.0;

    widget.tabController.addListener(() {
      if (widget.tabController.indexIsChanging) {
        setState(() {
          scaleController.reset();
          scaleController.forward();
        });
      }
    });

  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  TextStyle _getUnSelectedStyle() {
    return TextStyle(
        fontSize: _tabUnSectedTxtSize,
        color: Colors.black,
        fontWeight: FontWeight.w500);
  }

  TextStyle _getSelectedStyle() {
    return TextStyle(
        fontSize: _tabSectedTxtSize,
        color: Colors.red,
        fontWeight: FontWeight.w500);
  }

  Widget _buildAppBar() {

    return AppBar(
      titleSpacing: 0.0,
      elevation: 0,
      actions: [
        Container(
          padding: EdgeInsets.only(left: _actionLeadingSpace, right: _actionLeadingSpace),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            boxShadow: [
              ///阴影颜色/位置/大小等
              BoxShadow(
                color: Theme.of(context).scaffoldBackgroundColor,
                offset: Offset(-0.0, 0),
                blurRadius: _actionLeadingSpace / 2,
              ),
              BoxShadow(
                color: Theme.of(context).scaffoldBackgroundColor,
                offset: Offset(-0.0, 0),
                blurRadius: _actionLeadingSpace / 2 + 1,
              ),
              BoxShadow(
                color: Theme.of(context).scaffoldBackgroundColor,
                offset: Offset(-0.0, 0),
                blurRadius: _actionLeadingSpace / 2 + 2,
              )
              //BoxShadow(color: Theme.of(context).scaffoldBackgroundColor, offset: Offset(14, 0)),
            ],
          ),

          //color: Colors.red,
          child: Icon(
            Icons.menu,
            //color: Colors.grey,
            //size: 26,
          ),
        ),
      ],
      bottom: PreferredSize(
        //preferredSize: Size(20, 20),
        preferredSize: Size.zero,
        child: Divider(
          color: Color(0xffe5e5e5),
          height: 0.0,
          thickness: 0.5,
          indent: _actionLeadingSpace,
          endIndent: _actionLeadingSpace,
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(left: _barLeadingLeft),
        child: TabBar(
          //生成Tab菜单
          indicatorWeight: 0.0,
          physics: const BouncingScrollPhysics(),
          indicator: const BoxDecoration(),
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.red,
          labelPadding: EdgeInsets.only(left: _tabMargin, right: _tabMargin),
          controller: widget.tabController,
          tabs: _buildTabs(),
        ),
      )
      //toolbarHeight: kToolbarHeight,
      //bottomOpacity: 0.0,
    );
  }

  List<Widget> _buildTabs() {
    final List<Widget> tabs = <Widget>[];

    for (int i = 0; i < widget.datas.length; i++) {
      if (widget.tabController.index != i) {
        tabs.add(Tab(
            child: Container(
          alignment: Alignment.center,
          //height: widget.height,
          child: Text(
            widget.datas[i],
            style: _getUnSelectedStyle(),
          ),
        )));
        continue;
      }
      tabs.add(ScaleTransition(
        scale: scaleAnimation,
        child: Tab(
            child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
              top: (_tabSectedTxtSize - _tabUnSectedTxtSize) / 2),
          //height: widget.height,
          child: Text(
            widget.datas[i],
            style: _getSelectedStyle(),
          ),
        )),
      ));
    }

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return _buildAppBar();
  }
}
