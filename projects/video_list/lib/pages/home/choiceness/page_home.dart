import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:video_list/controllers/choiceness_controller.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/models/choiceness_model.dart';
import 'package:video_list/pages/home/choiceness/video_page_utils.dart';
import 'package:video_list/pages/page_controller.dart';
import 'file:///C:/wuchaochao/project/flutter_code_manager/projects/video_list/lib/ui/utils/icons_utils.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'package:video_list/ui/utils/shimmer_indicator.dart';
import 'package:video_list/ui/views/advert_view.dart';
import 'page_header.dart';
import 'app_bar.dart';
import 'sliver_video_item.dart';
import 'package:video_list/resources/export.dart';
import 'video_page_utils.dart' as VideoPageUtils;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_screenutil/size_extension.dart';

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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final GlobalKey<SliverAnimatedListState> _listKey =
      new GlobalKey<SliverAnimatedListState>();

  //List _headerItems;

  ListModel _list;

  @override
  void initState() {
    print("ChoicenessPage -> initState()");
    super.initState();
    _initResources();
  }

  @override
  void dispose() {
    print("ChoicenessPage -> dispose()");
    _disposeResources();
    _refreshController.dispose();
    super.dispose();
  }

  void _disposeResources() {}

  void _initResources() {
    List dataList = ChoicenessController().initChoicenessData();

    _list = new ListModel(
      listKey: _listKey,
      initialItems: dataList,
      removedItemBuilder: _buildRemovedItem,
    );

    /*_headerItems = [];
    _videoItems = [];

    _headerItems.addAll(list.take(6));
    list.removeRange(0, 6);
    _videoItems.addAll(list);*/

    //print("_initResources: videoItems size: ${_videoItems.length}");
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

  Widget _buildRemovedItem(BuildContext context, int index, dynamic item,
      Animation<double> animation) {
    if (index == 0) {
      return ChoicenessHeader(item, widget.pageVisibleNotifier);
    }

    if (item is VideoItems) {
      return VideoItemWidget(item);
    } else if (item is AdvertItem) {
      return AdvertView(item);
    }
    return null;
  }

  Random random = Random();

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    print("remove notifiy _buildItem: ${index}");
    final dynamic data = _list[index];
    Widget child;
    if (index == 0) {
      child = ChoicenessHeader(data, widget.pageVisibleNotifier);
    }

    if (data is VideoItems) {
      child = Container(
        color: Color.fromARGB(random.nextInt(100) + 155, random.nextInt(255), random.nextInt(255), random.nextInt(255)),
        child: VideoItemWidget(data),
      );
    } else if (data is AdvertItem) {
      child = Container(
        width: Dimens.design_screen_width.w,
        height: HeightMeasurer.itemHeaderHeightWithVerticalList + HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList * 2,
        padding: EdgeInsets.symmetric(vertical: HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList),
        color: Colors.black26,
        child: AdvertView(data),
      );
    }
    return child;
  }

  Future<Null> _onRefresh() async {
    print("刷新成功");
    await Future.delayed(Duration(milliseconds: 1000));
    List newDataList =
        ChoicenessController().updateChoicenessData(_list._items);
    _list.update(newDataList);
    /* setState(() {
      _initResources();
    });
*/
    _refreshController.refreshCompleted();
    //_dataRefreshNotifier.value += 1;
    /*setState(() {

    });*/
  }

  Future<Null> _onLoading() async {
    print("正在刷新");
    await Future.delayed(Duration(milliseconds: 1000));

    List newDataList = ChoicenessController().getRondomDataByAdd();

    _list.addAll(newDataList);

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    print("choiceness build page");
    super.build(context);
    return MultiProvider(
      //create: (context) => widget.pageVisibleNotifier,
      providers: [
        ChangeNotifierProvider.value(value: widget.pageVisibleNotifier),
      ],
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
        body: NotificationListener(
          onNotification: (ScrollNotification notification) {
            final ScrollMetrics metrics = notification.metrics;
            /*print("##123 => ${metrics.runtimeType}");

            if (notification is ScrollStartNotification) {
              print(
                  '##123 => 滚动开始 extentInside:${metrics.extentInside} axis:${metrics.axis} axisDirection:${metrics.axisDirection}');
            }
            if (notification is ScrollUpdateNotification) {
              print(
                  '##123 => 滚动中 extentInside:${metrics.extentInside} axis:${metrics.axis} axisDirection:${metrics.axisDirection}');
            }*/
            if (notification is ScrollEndNotification && metrics.axis == Axis.vertical) {
              /*print(
                  '##123 => 停止滚动 extentInside:${metrics.extentInside} axis:${metrics.axis} axisDirection:${metrics.axisDirection} extentAfter: ${notification.metrics.extentAfter}');
              if (notification.metrics.extentAfter == 0) {
                print(
                    '##123 => 滚动到底部 extentInside:${metrics.extentInside} axis:${metrics.axis} axisDirection:${metrics.axisDirection}');
              }
              if (notification.metrics.extentBefore == 0) {
                print(
                    '##123 => 滚动到头部 extentInside:${metrics.extentInside} axis:${metrics.axis} axisDirection:${metrics.axisDirection}');
              }*/
              //print('##123 => 停止滚动 extentInside:${metrics.extentInside} axis:${metrics.axis} axisDirection:${metrics.axisDirection} extentAfter: ${notification.metrics.extentAfter} extentBefore:${notification.metrics.extentBefore} viewportDimension:${notification.metrics.viewportDimension}');
              final List<ViewportOffsetData> viewportOffsetDataList = _list.getViewportOffsetData(metrics.extentBefore, metrics.viewportDimension);

              print("##123 => viewportOffsetDataList: $viewportOffsetDataList");
            }
            return false;
          },
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            /*onOffsetChange: (isUp, offset) {
              print("###offset: $offset, isUp: $isUp");
            },*/
            controller: _refreshController,
            //// WaterDropHeader、ClassicHeader、CustomHeader、LinkHeader、MaterialClassicHeader、WaterDropMaterialHeader
            header: ShimmerHeader(
              text: Text(
                "PullToRefresh",
                style: TextStyle(color: Colors.grey, fontSize: 22),
              ),
              outerBuilder: (child) {
                return Container(
                  height: 320.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        "images/newyear.jpeg",
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 18.w,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: child,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            footer: ShimmerFooter(
              text: Text(
                "PullToRefresh",
                style: TextStyle(color: Colors.grey, fontSize: 22),
              ),
            ),
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAnimatedList(
                  key: _listKey,
                  initialItemCount: _list.length,
                  itemBuilder: _buildItem,
                ),
              ],
            ),
          ),
        ), //ChoicenessHeader(widget.pageIndex, widget.tabIndex, _headerImages),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

typedef RemovedItemBuilder<E> = Widget Function(
    BuildContext context, int index, E item, Animation<double> animation);

class ListModel<E> with HeightMeasurer {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = new List<E>.from(initialItems ?? <E>[]) {
    initAllHeight(_items);
  }

  final GlobalKey<SliverAnimatedListState> listKey;
  final RemovedItemBuilder removedItemBuilder;
  final List<E> _items;


  SliverAnimatedListState get _sliverAnimatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _sliverAnimatedList.insertItem(index);
    insertHeight(index, item);
  }

  void addAll(List<E> items) {
    int addLength = items.length;
    int lastIndex = _items.length;
    _items.addAll(items);
    addAllHeight(items);
    while (addLength-- > 0) {
      _sliverAnimatedList.insertItem(lastIndex++);
    }
  }

  void update(List<E> items) {
    this._items.clear();
    this._items.addAll(items);
    ((_sliverAnimatedList.context) as Element).markNeedsBuild();
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _sliverAnimatedList.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(context, index, removedItem, animation);
      });

    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
