import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:video_list/controllers/choiceness_controller.dart';
import 'package:video_list/pages/home/choiceness/tmp_page.dart';
import 'package:video_list/routes/base_video_page.dart';
import 'package:video_list/ui/popup/popup_view.dart';
import 'package:video_list/ui/views/static_video_view.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/models/choiceness_model.dart';
import 'package:video_list/pages/home/choiceness/video_page_state.dart';
import 'package:video_list/pages/page_controller.dart';
import 'file:///C:/wuchaochao/project/flutter_code_manager/projects/video_list/lib/ui/utils/icons_utils.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'file:///C:/wuchaochao/project/flutter_code_manager/projects/video_list/lib/ui/views/shimmer_indicator.dart';
import 'package:video_list/ui/views/advert_view.dart';
import 'package:video_list/ui/views/static_advert_view.dart';
import 'package:video_list/utils/network_utils.dart';
import 'package:video_list/utils/view_utils.dart';
import 'package:video_player/video_player.dart';
import 'page_header.dart';
import 'app_bar.dart';
import 'sliver_video_item.dart';
import 'package:video_list/resources/export.dart';
import 'video_page_state.dart' as VideoPageUtils;
import 'package:flutter_screenutil/size_extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../page_controller.dart';

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

  final GlobalKey<SliverAnimatedListState> _listKey =
      new GlobalKey<SliverAnimatedListState>();

  ScrollController _scrollController;

  ListModel _list;

  @override
  void onNetworkChange() {
    if (_list._items == null || _list.length <= 0) return;
    print("_ChoicenessPageState => onNetworkChange => hasNetwork: $hasNetwork");
    if (hasNetwork) {
      assert(PaintingBinding.instance.imageCache != null);
      PaintingBinding.instance.imageCache.clear();

      final List<VideoStateMiXin> states = _list.states;
      if (states != null && states.isNotEmpty) {
        for (VideoStateMiXin state in states) {
          if (state is AdvertState && state.playState.isPlaying()) {
            state.changeState(
              playState: PlayState.continuePlay,
            );
          }
        }
      }

      _list.update(_list._items);
    }
  }

  @override
  void initState() {
    print("ChoicenessPage -> initState()");
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ScrollPosition position = _scrollController.position;
      assert(position != null);
      assert(position.hasViewportDimension);
      _resumeStateWhenScrollEnd(
        extentBefore: position.extentBefore,
        viewportDimension: position.viewportDimension,
      );
    });

    _initResources();
  }

  @override
  void dispose() {
    print("ChoicenessPage -> dispose()");
    _disposeResources();
    _refreshController.dispose();
    _scrollController.dispose();
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
    animation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          final ScrollPosition position = _scrollController.position;
          assert(position != null);
          assert(position.hasViewportDimension);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            assert(_scrollController != null);
            assert(_scrollController.position != null);
            final ScrollPosition scrollPosition = _scrollController.position;
            _resumeStateWhenScrollEnd(
              extentBefore: scrollPosition.extentBefore,
              viewportDimension: scrollPosition.viewportDimension,
            );
          });
          break;
      }
    });

    print(
        "remove_wcc => _buildRemovedItem Video Selector build => index: $index list.length:${_list.length} state.length:${_list.states.length}");
    //assert(_list.states != null && _list.states.isNotEmpty);
    return _buildItem(context, index, animation);
  }

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
      assert(_list.states[index] is AdvertState);
      //保存为持久性对象,避免list被修改造成下标错位
      print(
          "Video Selector build22222 => index: $index list.length:${_list.length} state.length:${_list.states.length}");
      final AdvertState _state = _list.states[index];
      child = Selector<ListModel, VideoStateMiXin>(
        builder: (BuildContext context, VideoStateMiXin state, Widget child) {
          assert(state != null);
          assert(state is AdvertState);
          final AdvertState advertState = state;
          assert(advertState.detailHighlightInfo != null);
          print(
              "3333Video Selector build => index: $index list.length:${_list.length} state.length:${_list.states.length} _state:${_state.hashCode} advertState.playState: ${_state.playState}");
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList,
            ),
            child: NormalAdvertView(
              width: Dimens.design_screen_width.w,
              playState: advertState.playState,
              advertItem: data,
              popupDirection: advertState.popupDirection,
              detailHighlight:
                  advertState.detailHighlightInfo.startDetailHighlight,
              onDetailHighlight: (bool highlight) {
                assert(_list.states != null);
                final VideoStateMiXin state = _list.states[index];
                assert(state is AdvertState);
                final AdvertState advertState = state;
                assert(advertState != null);
                final DetailHighlightInfo detailHighlightInfo =
                    advertState.detailHighlightInfo;
                assert(detailHighlightInfo != null);
                advertState.changeState(
                  detailHighlightInfo: detailHighlightInfo.copyWith(
                    finishDetailHighlight: highlight,
                  ),
                );
              },
              onEnd: () {
                assert(_list.states != null);
                final VideoStateMiXin state = _list.states[index];
                assert(state is AdvertState);
                final AdvertState advertState = state;
                assert(advertState != null);
                advertState.changeState(
                  playState: PlayState.end,
                );
              },
              onClick: (VideoPlayerController controller) {
                final VideoStateMiXin state = _list.states[index];
                assert(state is AdvertState);
                final AdvertState advertState = state;
                if (advertState.playState == PlayState.end) return;
                _jumpToPlayVideoPage(index, controller);
              },
              onReplay: (VideoPlayerController controller) {
                _jumpToPlayVideoPage(index, controller);
              },
              onLoseAttention: () {
                _state.keepPlayState();
                var element = _list.removeAt(index);
                assert(element != null);
              },
              videoHeight: HeightMeasurer.advertItemHeight,
              titleHeight: HeightMeasurer.itemVideoTitleHeightWithVerticalList,
            ),
          );
        },
        selector: (BuildContext context, ListModel stateManager) {
          assert(_state != null);
          assert(_state is AdvertState);
          return _state.copyWith();
        },
      );
    }
    return child;
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    assert(index >= 0);
    assert(index < _list.length);
    return SizeTransition(
      sizeFactor: animation.drive(CurveTween(curve: Curves.easeIn)),
      axisAlignment: 1.0,
      child: FadeTransition(
        opacity: animation,
        child: _buildDetailItem(context, index),
      ),
    );
  }

  void _pausePlayingVideos() {
    final ScrollPosition position = _scrollController.position;
    assert(position != null);
    assert(position.hasViewportDimension);
    final List<ViewportOffsetData> viewportOffsetDataList =
        _list.getViewportOffsetData(
            position.extentBefore, position.viewportDimension);
    assert(viewportOffsetDataList != null);
    for (ViewportOffsetData viewportOffsetData in viewportOffsetDataList) {
      assert(viewportOffsetData.index != null);
      assert(_list.states != null);
      VideoStateMiXin state = _list.states[viewportOffsetData.index];
      if (state is AdvertState && state.playState.isPlaying())
        state.changeState(playState: PlayState.startAndPause);
    }
  }

  void _jumpToPlayVideoPage(int index, VideoPlayerController controller) {
    assert(index != null);
    assert(controller != null);
    assert(_list.states != null);
    final VideoStateMiXin state = _list.states[index];
    assert(state is AdvertState);
    final AdvertState advertState = state;

    final BuildContext parentContext =
        Provider.of<PageChangeNotifier>(context, listen: false).context;
    assert(parentContext != null); //PageRouteBuilder
    _pausePlayingVideos();
    final Duration delayDuration = const Duration(milliseconds: 300);
    Navigator.push(
      parentContext,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return null;
        },
        transitionsBuilder:
            (context, animation, secondaryAnimation, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset(0.0, 0.0),
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            ),
            child: BaseVideoPage(
              // 路由参数
              controller: controller,
              animation: animation,
              delayDuration: delayDuration,
              onForward: () {
                advertState.changeState(
                  playState: PlayState.pause,
                );
              },
              onCompleted: () {
                //print("animation animation animation completed55");
                advertState.changeState(
                  playState: PlayState.resume,
                );
              },
              onReverse: () {
                advertState.changeState(
                  playState: PlayState.pause,
                );
              },
              onDismissed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  assert(_scrollController != null);
                  assert(_scrollController.position != null);
                  final ScrollPosition scrollPosition =
                      _scrollController.position;
                  _resumeStateWhenScrollEnd(
                    extentBefore: scrollPosition.extentBefore,
                    viewportDimension: scrollPosition.viewportDimension,
                  );
                });
              },
            ),
          );
        },
        reverseTransitionDuration: delayDuration,
        transitionDuration: delayDuration,
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

  void _resumeStateWhenScrollEnd(
      {double extentBefore, double viewportDimension}) {
    print("##scroll => _resumeStateWhenScrollEnd!!!!!!!!");
    assert(_list != null);
    assert(extentBefore != null);
    assert(viewportDimension != null);
    final List<ViewportOffsetData> viewportOffsetDataList =
        _list.getViewportOffsetData(extentBefore, viewportDimension);
    VideoPageUtils.computerVideoStateValueWhenScrollEnd(
        _list, viewportOffsetDataList, NormalAdvertView.needVisibleHeight);
  }

  void _resumeStateWhenScrollUpdate(
      {double extentBefore, double viewportDimension}) {
    print("##scroll => _resumeStateWhenScrollUpdate!!!!!!!!");
    assert(_list != null);
    assert(extentBefore != null);
    assert(viewportDimension != null);
    final List<ViewportOffsetData> viewportOffsetDataList =
        _list.getViewportOffsetData(
      extentBefore,
      viewportDimension,
    );

    VideoPageUtils.computerVideoStateValueWhenScrollUpdate(
        _list, viewportOffsetDataList);
  }

  @override
  Widget build(BuildContext context) {
    print("choiceness build page");
    super.build(context);
    return MultiProvider(
      //create: (context) => widget.pageVisibleNotifier,
      providers: [
        ChangeNotifierProvider.value(value: widget.pageVisibleNotifier),
        ChangeNotifierProvider.value(value: _list),
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
            print("##scroll => ScrollNotification!!!!!!!!");
            if (metrics.axis == Axis.vertical) {
              print("##scroll => ScrollNotification2!!!!!!!!");
              if (notification is ScrollEndNotification) {
                _resumeStateWhenScrollEnd(
                  extentBefore: metrics.extentBefore,
                  viewportDimension: metrics.viewportDimension,
                );
              } else if (notification is ScrollUpdateNotification) {
                _resumeStateWhenScrollUpdate(
                  extentBefore: metrics.extentBefore,
                  viewportDimension: metrics.viewportDimension,
                );
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
              controller: _scrollController,
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

class ListModel<E> with ChangeNotifier, ItemStateManager, HeightMeasurer {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = new List<E>.from(initialItems ?? <E>[]) {
    initAllHeight(_items);
    initAllState(_items);
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
    insertState(index, item);
  }

  //插入不进行任何动画
  void addAll(List<E> items) {
    int addLength = items.length;
    int lastIndex = _items.length;
    _items.addAll(items);
    addAllHeight(items);
    addAllState(items);
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
        print("remove_wcc at index: $index length:${_items.length}");
        final E removedItem = _items.removeAt(index);

        assert(removedItem != null);
        assert(removedItem == waitingRemovedItem);
        removeHeight(index);
        removeState(index);
        return widget;
      }, duration: const Duration(milliseconds: 300));
    }
    return waitingRemovedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
