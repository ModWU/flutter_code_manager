import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:video_list/controllers/choiceness_controller.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/models/choiceness_model.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/pages/page_utils.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'choiceness_body_header.dart';
import 'choiceness_page_bar.dart';
import 'choiceness_video_item.dart';

class ChoicenessPage extends StatefulWidget with PageVisibleMixin {
  ChoicenessPage();

  //const ChoicenessPage(this.tabIndex);

  @override
  State<StatefulWidget> createState() => _ChoicenessPageState();
}

class _ChoicenessPageState extends State<ChoicenessPage>
    with AutomaticKeepAliveClientMixin {
  static const _barLeadingLeft = 12.0;
  static const _appBarHeight = Dimens.action_bar_height - 10.0;

  List<ChoicenessHeaderItem> _headerImages;

  List<ItemMiXin> _videoItems;

  @override
  void initState() {
    print("ChoicenessPage -> initState()");
    super.initState();
    _initResources();

  }

  @override
  void dispose() {
    print("ChoicenessPage -> dispose()");
    super.dispose();
  }

  void _initResources() {
    List list = ChoicenessController().getChoicenessData();

    _headerImages = list.whereType<ChoicenessHeaderItem>().toList();
    _videoItems = list.whereType<ItemMiXin>().toList();

    print("_initResources: videoItems size: ${_videoItems.length}");
  }

  void _appBarListener(ClickState state) {
    switch (state) {
      case ClickState.search:
        print("appbar click search");
        break;
      case ClickState.game:
        print("appbar click game");
        break;
      case ClickState.download:
        print("appbar click download");
        break;
      case ClickState.history:
        print("appbar click history");
        break;
      case ClickState.delete:
        print("appbar click delete");
        break;
    }
  }

  Future<Null> _refresh() async {
    print("刷新成功");
  }

  @override
  Widget build(BuildContext context) {
    print("choiceness build page");
    return ChangeNotifierProvider(
      create: (context) => widget.pageVisibleNotifier,
      child: Scaffold(
        appBar: PreferredSize(
          //preferredSize: Size(20, 20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _barLeadingLeft),
            child: ChoicenessBar(
              _appBarListener,
              searchDesc: "成都双流车祸",
              searchCategor: '[热门]',
            ),
          ),
          preferredSize: Size.fromHeight(_appBarHeight),
        ),
        floatingActionButton: null,
        body: Container(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
                itemCount: _videoItems.length + 1,
                //itemExtent: 50.0, //强制高度为50.0

                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0)
                    return ChoicenessHeader(
                        _headerImages, widget.pageVisibleNotifier, widget.pageScrollNotifier);

                  return VideoItemWidget(index, _videoItems[index - 1]);
                }),
          ),
        ), //ChoicenessHeader(widget.pageIndex, widget.tabIndex, _headerImages),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
