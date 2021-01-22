import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:video_list/controllers/choiceness_controller.dart';
import 'package:video_list/ui/popup/popup_view.dart';
import 'package:video_list/ui/views/static_video_view.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/models/choiceness_model.dart';
import 'package:video_list/pages/home/choiceness/video_page_utils.dart';
import 'package:video_list/pages/page_controller.dart';
import 'file:///C:/wuchaochao/project/flutter_code_manager/projects/video_list/lib/ui/utils/icons_utils.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'file:///C:/wuchaochao/project/flutter_code_manager/projects/video_list/lib/ui/views/shimmer_indicator.dart';
import 'package:video_list/ui/views/advert_view.dart';
import 'package:video_list/ui/views/static_advert_view.dart';
import 'package:video_list/utils/network_utils.dart';
import 'page_header.dart';
import 'app_bar.dart';
import 'sliver_video_item.dart';
import 'package:video_list/resources/export.dart';
import 'video_page_utils.dart' as VideoPageUtils;
import 'package:flutter_screenutil/size_extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChoicenessPage extends StatefulWidget with PageVisibleMixin {
  ChoicenessPage();

  //const ChoicenessPage(this.tabIndex);

  @override
  State<StatefulWidget> createState() => _ChoicenessPageState();
}

class _ChoicenessPageState extends State<ChoicenessPage>
    with AutomaticKeepAliveClientMixin, NetworkStateMiXin {
  static const _barLeadingLeft = 12.0;
  static const _appBarHeight = Dimens.action_bar_height - 10.0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ValueNotifier<VideoPlayInfo> _videoPlayNotifier =
      ValueNotifier<VideoPlayInfo>(null);

  final GlobalKey<SliverAnimatedListState> _listKey =
      new GlobalKey<SliverAnimatedListState>();

  //List _headerItems;

  ListModel _list;

  @override
  void onNetworkChange() {
    if (_list._items == null || _list.length <= 0) return;
    print("_ChoicenessPageState => onNetworkChange => hasNetwork: $hasNetwork");
    if (hasNetwork) {
      assert(PaintingBinding.instance.imageCache != null);
      PaintingBinding.instance.imageCache.clear();
      if (_videoPlayNotifier.value != null) {
        _videoPlayNotifier.value.playState = PlayState.continuePlay;
      }
      _list.update(_list._items);
    }
  }

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
    print("_buildRemovedItem: $index   size: ${_list.length}");
    if (_videoPlayNotifier.value != null) {
      _videoPlayNotifier.value.playState = PlayState.keepState;
    }
    return _buildItem(context, index, animation);
  }

  Random random = Random();

  Widget _buildDetailItem(BuildContext context, int index) {
    final dynamic data = _list[index];
    Widget child;
    if (index == 0) {
      child = ChoicenessHeader(data, widget.pageVisibleNotifier);
    }

    if (data is VideoItems) {
      child = VideoItemWidget(data);
    } else if (data is AdvertItem) {
      final bool isCanPlay = data.canPlay;
      child = Consumer<ValueNotifier<VideoPlayInfo>>(builder:
          (BuildContext context, ValueNotifier<VideoPlayInfo> playNotifier,
              Widget child) {
        print(
            "==========>index: $index => playNotifier: $playNotifier, playNotifier.value: ${playNotifier.value}, detailHighlights: ${playNotifier.value?.detailHighlights}");
        assert(
            playNotifier.value == null || playNotifier.value.playIndex != null);
        bool startDetailHighlight = false;

        if (playNotifier.value?.detailHighlights != null &&
            playNotifier.value.detailHighlights.containsKey(index)) {
          assert(
              playNotifier.value.detailHighlights[index].startDetailHighlight !=
                  null);
          startDetailHighlight =
              playNotifier.value.detailHighlights[index].startDetailHighlight;
        }

        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList),
          child: StatefulBuilder(builder: (context, StateSetter setState) {
            return NormalAdvertView(
              width: Dimens.design_screen_width.w,
              playState: playNotifier.value?.playState == null ||
                      playNotifier.value.playIndex != index
                  ? PlayState.startAndPause
                  : playNotifier.value.playState,
              advertItem: data,
              popupDirection: playNotifier.value?.popupDirections == null ||
                      !playNotifier.value.popupDirections.containsKey(index)
                  ? PopupDirection.bottom
                  : playNotifier.value.popupDirections[index],
              detailHighlight: startDetailHighlight,
              onDetailHighlight: (bool highlight) {
                if (playNotifier.value?.detailHighlights != null) {
                  DetailHighlightInfo detailHighlightInfo =
                      playNotifier.value.detailHighlights[index];
                  if (detailHighlightInfo != null)
                    detailHighlightInfo.finishDetailHighlight = highlight;
                }
              },
              onEnd: () {
                if (playNotifier.value != null) {
                  print("play end!!!!!!");
                  playNotifier.value.playState = PlayState.end;
                }
              },
              onLoseAttention: () {
                var element = _list.removeAt(index);
                assert(element != null);
              },
              videoHeight: HeightMeasurer.advertItemHeight,
              titleHeight: HeightMeasurer.itemVideoTitleHeightWithVerticalList,
            );
          }),
        );
      });
    }
    return child;
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation.drive(CurveTween(curve: Curves.easeIn)),
      axisAlignment: 1.0,
      child: FadeTransition(
        opacity: animation,
        child: _buildDetailItem(context, index),
      ),
    );
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
        ChangeNotifierProvider.value(value: _videoPlayNotifier),
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

            if (metrics.axis == Axis.vertical) {
              if (notification is ScrollEndNotification) {
                final List<ViewportOffsetData> viewportOffsetDataList =
                    _list.getViewportOffsetData(
                        metrics.extentBefore, metrics.viewportDimension);
                _videoPlayNotifier.value =
                    VideoPageUtils.computerVideoStateValueWhenScrollEnd(
                        _list,
                        viewportOffsetDataList,
                        _videoPlayNotifier.value,
                        NormalAdvertView.needVisibleHeight);
              } else if (notification is ScrollUpdateNotification) {
                final List<ViewportOffsetData> viewportOffsetDataList =
                    _list.getViewportOffsetData(
                  metrics.extentBefore,
                  metrics.viewportDimension,
                );

                _videoPlayNotifier.value =
                    VideoPageUtils.computerVideoStateValueWhenScrollUpdate(
                        _list,
                        viewportOffsetDataList,
                        _videoPlayNotifier.value);
              }
            }
            return false;
          },
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            onOffsetChange: (isUp, offset) {
              print("###offset: $offset, isUp: $isUp");
            },
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

  //插入不进行任何动画
  void insert(int index, E item) {
    _items.insert(index, item);
    _sliverAnimatedList.insertItem(index, duration: Duration.zero);
    insertHeight(index, item);
  }

  //插入不进行任何动画
  void addAll(List<E> items) {
    int addLength = items.length;
    int lastIndex = _items.length;
    _items.addAll(items);
    addAllHeight(items);
    while (addLength-- > 0) {
      _sliverAnimatedList.insertItem(lastIndex++, duration: Duration.zero);
    }
  }

  void update(List<E> items) {
    if (items != _items) {
      this._items.clear();
      this._items.addAll(items);
      initAllHeight(items);
    }
    ((_sliverAnimatedList.context) as Element).markNeedsBuild();
  }

  E removeAt(int index) {
    final E waitingRemovedItem = _items[index];
    if (waitingRemovedItem != null) {
      _sliverAnimatedList.removeItem(index,
          (BuildContext context, Animation<double> animation) {
        final Widget widget =
            removedItemBuilder(context, index, waitingRemovedItem, animation);
        final E removedItem = _items.removeAt(index);
        assert(removedItem != null);
        assert(removedItem == waitingRemovedItem);
        removeHeight(index);
        return widget;
      }, duration: const Duration(milliseconds: 300));
    }
    return waitingRemovedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
