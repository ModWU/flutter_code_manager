import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_list/models/base_model.dart';
import 'package:video_list/pages/home/choiceness/page_home.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'package:video_list/ui/popup/popup_view.dart';
import 'package:video_list/ui/views/static_video_view.dart';
import '../../page_controller.dart';
import '../../../ui/utils/icons_utils.dart' as utils;
import 'package:flutter_screenutil/size_extension.dart';

double itemVerticalSpacing = 3.0.w, itemHorizontalSpacing = 6.0.w;

class ViewportOffsetData {
  final double visibleOffset;
  final double height;
  final int index;

  const ViewportOffsetData(this.index, this.height, this.visibleOffset);

  @override
  String toString() {
    return 'ViewportOffsetData{"index": $index, "height": $height, "visibleOffset": $visibleOffset}';
  }
}

mixin ItemStateManager on ChangeNotifier {
  List<VideoStateMiXin> _states;

  List<VideoStateMiXin> get states => _states;

  void _stateListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void initAllState(List items) {
    assert(items != null && items.isNotEmpty);
    _states?.clear();
    _states ??= [];
    //final List tmpItems = List.from(items);
    //int startIndex = items.length;
    for (int index = 0; index < items.length; index++) {
      _states.add(_getItemState(index, items[index]));
    }
  }

  VideoStateMiXin _getItemState(int index, dynamic item) {
    assert(index != null);
    assert(item != null);
    VideoStateMiXin state;
    if (item is AdvertItem) {
      state = AdvertState(
        playState: PlayState.startAndPause,
        detailHighlightInfo: DetailHighlightInfo(
            startDetailHighlight: false, finishDetailHighlight: false),
        popupDirection: PopupDirection.bottom,
      );
    } else {
      //不要等于空
      state = VideoState();
    }

    if (state != null) {
      state.addListener(_stateListener);
    }
    return state;
  }

  void insertState(int index, dynamic item) {
    assert(_states != null);
    assert(index != null && index >= 0 && index <= _states.length);
    assert(item is VideoItems || item is AdvertItem);
    var state = _getItemState(index, item);
    _states.insert(index, state);
  }

  void removeState(int index) {
    assert(_states != null);
    assert(index != null && index >= 0 && index < _states.length);
    var item = _states.removeAt(index);
    assert(item != null);
    item.removeListener(notifyListeners);
  }

  void addState(dynamic item) {
    assert(_states != null);
    assert(item is VideoItems || item is AdvertItem);
    var state = _getItemState(_states.length, item);
    _states.add(state);
  }

  void addAllState(List items) {
    assert(_states != null);
    assert(items != null && items.isNotEmpty);
    int startIndex = _states.length;
    for (int index = 0; index < items.length; index++) {
      var state = _getItemState(startIndex + index, items[index]);
      _states.add(state);
    }
  }
}

mixin HeightMeasurer {
  List<double> _heightList;

  static final double headItemHeight = 440.h;
  static final double advertItemHeight = Dimens.design_screen_width.w * 0.5;
  static final double itemHeightWithHorizontalList =
      (Dimens.design_screen_width.w - 6.0.w) / 2.5;

  static final double primaryTitleHeight = 96.h;
  static final double bottomRefreshHeight = 90.h;

  static final double itemHeaderHeightWithVerticalList =
      Dimens.design_screen_width.w * 0.5;
  static final double itemVideoTitleHeightWithVerticalList = 120.h;
  static final double itemVideoMainAxisSpaceWithVerticalList = 4.h;
  static final double itemVideoCrossAxisSpaceWithVerticalList = 4.h;
  static final double itemVideoAspectRatioWithVerticalList = 1.0; //宽比高：1:1
  static final int itemVideoCrossAxisCountWithVerticalList = 2; //水平方向的数量

  double getHeight(int index) {
    assert(_heightList != null);
    assert(index != null && index >= 0 && index < _heightList.length);
    return _heightList[index];
  }

  List<ViewportOffsetData> getViewportOffsetData(
      double extentBefore, double viewportDimension) {
    assert(extentBefore != null && extentBefore >= 0);
    assert(_heightList != null && _heightList.isNotEmpty);
    final List<ViewportOffsetData> list = [];
    final double viewportAfter = extentBefore + viewportDimension;
    double totalHeight = 0;
    bool isFindStart = false;
    for (int i = 0; i < _heightList.length; i++) {
      totalHeight += _heightList[i];
      //visibleWrap = VisibleWrap(i, _heightList[i], totalHeight - extentBefore);
      //先找头
      if (list.isEmpty && (extentBefore <= totalHeight)) {
        list.add(
            ViewportOffsetData(i, _heightList[i], totalHeight - extentBefore));
        isFindStart = true;
        continue;
      }

      //再找尾
      if (viewportAfter <= totalHeight) {
        final double visibleOffset =
            _heightList[i] - (totalHeight - viewportAfter);
        if (visibleOffset > 0)
          list.add(ViewportOffsetData(i, _heightList[i], visibleOffset));
        break;
      }

      if (isFindStart)
        list.add(ViewportOffsetData(i, _heightList[i], _heightList[i]));
    }

    return list;
  }

  void removeHeight(int index) {
    assert(_heightList != null);
    assert(index != null && index >= 0 && index < _heightList.length);
    var item = _heightList.removeAt(index);
    assert(item != null);
  }

  void insertHeight(int index, dynamic item) {
    assert(_heightList != null);
    assert(index != null && index >= 0 && index <= _heightList.length);
    assert(item is VideoItems || item is AdvertItem);
    double height = _computerHeight(index, item);
    assert(height > 0);
    _heightList.insert(index, height);
  }

  void addHeight(dynamic item) {
    assert(_heightList != null);
    assert(item is VideoItems || item is AdvertItem);
    double height = _computerHeight(_heightList.length, item);
    assert(height > 0);
    _heightList.add(height);
  }

  void addAllHeight(List items) {
    assert(_heightList != null);
    assert(items != null && items.isNotEmpty);
    int startIndex = _heightList.length;
    for (int index = 0; index < items.length; index++) {
      double height = _computerHeight(startIndex + index, items[index]);
      assert(height > 0);
      _heightList.add(height);
    }
  }

  double _computerHeight(int index, dynamic item) {
    print("_computerHeight => item.runtimeType: ${item.runtimeType}");
    assert(item is VideoItems || item is AdvertItem);
    double totalHeight = 0;
    if (item is VideoItems) {
      //顶部一定都有标题
      totalHeight += primaryTitleHeight;
      if (item.layout == VideoLayout.vertical) {
        //计算垂直高
        int length = item.items.length;

        if (length.isOdd) {
          totalHeight += itemHeaderHeightWithVerticalList;
          if (item.items[0].title?.preTitle != null) {
            totalHeight += itemVideoTitleHeightWithVerticalList;
          }
          length--;

          if (length > 0) {
            totalHeight += itemVideoMainAxisSpaceWithVerticalList;
          }
        }

        if (length > 0) {
          final int lineCount =
              (length / itemVideoCrossAxisCountWithVerticalList).ceil();
          final double itemWidth = (Dimens.design_screen_width.w -
                  itemVideoCrossAxisSpaceWithVerticalList *
                      (itemVideoCrossAxisCountWithVerticalList - 1)) /
              itemVideoCrossAxisCountWithVerticalList;

          final double itemHeight =
              itemWidth / itemVideoAspectRatioWithVerticalList;

          totalHeight += (lineCount * itemHeight +
              itemVideoMainAxisSpaceWithVerticalList * (lineCount - 1));
        }
      } else {
        totalHeight += itemHeightWithHorizontalList;
      }

      //判断底部是否有刷新
      if (item.bottom != null &&
          (item.bottom.isHasRefresh || item.bottom.playTitle != null)) {
        totalHeight += HeightMeasurer.bottomRefreshHeight;
      }
    } else if (item is AdvertItem) {
      //广告上下都有间距
      totalHeight += advertItemHeight +
          itemVideoTitleHeightWithVerticalList +
          itemVideoMainAxisSpaceWithVerticalList * 2;
    }

    return totalHeight;
  }

  void initAllHeight(List items) {
    assert(items != null && items.isNotEmpty);
    final List tmpItems = List.from(items);
    //头部高度固定
    tmpItems.removeAt(0);

    _heightList = [];
    _heightList.add(headItemHeight);

    addAllHeight(tmpItems);
  }
}

Widget buildVideoTitle(VideoItemTitle title) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 28.w),
    height: HeightMeasurer.primaryTitleHeight,
    //color: Colors.green,
    //alignment: Alignment.center,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            print("点击了左边标题");
          },
          child: Text.rich(
            TextSpan(
              text: title.preTitle,
              children: [
                if (title.centerSign != null)
                  WidgetSpan(
                    child: utils.getSignIcon(title.centerSign, size: 36.sp),
                    alignment: PlaceholderAlignment.middle,
                  ),
                if (title.centerSign != null && title.lastTitle != null)
                  TextSpan(text: (title.lastTitle)),
                if (title.rightArrow)
                  WidgetSpan(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 26.sp,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
              ],
            ),
            overflow: TextOverflow.visible,
            maxLines: 1,
            // textWidthBasis: TextWidthBasis.longestLine,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (title.desc != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: GestureDetector(
              onTap: () {
                print("点击了右边描述按钮");
              },
              child: Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 8.w,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.descSign != null)
                      utils.getSignIcon(title.descSign, size: 32.sp),
                    Text(
                      title.desc,
                      style: TextStyle(
                        fontSize: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget buildBottom(VideoBottom bottom, VideoLayout layout) {
  assert(bottom != null);
  assert(layout != null);
  assert(bottom.isHasRefresh || bottom.playTitle != null);

  bool isOnlyOne =
      bottom.isHasRefresh ? (bottom.playTitle != null ? false : true) : true;

  return Container(
    //padding: EdgeInsets.symmetric(vertical: 32.h),
    height: HeightMeasurer.bottomRefreshHeight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      /* mainAxisAlignment: isOnlyOne
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,*/

      children: [
        if (bottom.playTitle != null)
          Expanded(
            flex: 1,
            child: Padding(
              padding: isOnlyOne
                  ? EdgeInsets.zero
                  : EdgeInsets.only(
                      right: layout == VideoLayout.horizontal
                          ? itemHorizontalSpacing
                          : itemVerticalSpacing),
              child: Center(
                child: _buildBottomIcon(
                  Icons.play_circle_outline,
                  TextSpan(
                    text: bottom.playTitle,
                    children: bottom.playSign == null
                        ? null
                        : [
                            WidgetSpan(
                              child:
                                  utils.getSignIcon(bottom.playSign, size: 12),
                              alignment: PlaceholderAlignment.middle,
                            ),
                            if (bottom.playDesc != null)
                              TextSpan(
                                text: bottom.playDesc,
                              ),
                          ],
                  ),
                  onTap: () {
                    print("点击了${bottom.playTitle}");
                  },
                ),
              ),
            ),
          ),
        if (bottom.isHasRefresh)
          Expanded(
            flex: 1,
            child: Padding(
              padding: isOnlyOne
                  ? EdgeInsets.zero
                  : EdgeInsets.only(
                      left: layout == VideoLayout.horizontal
                          ? itemHorizontalSpacing
                          : itemVerticalSpacing),
              child: Center(
                child: _buildBottomIcon(
                  Icons.refresh,
                  TextSpan(text: "换一换"),
                  onTap: () {
                    print("换一换");
                  },
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildBottomIcon(IconData iconData, TextSpan textSpan,
    {GestureTapCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Icon(
            iconData,
            color: Colors.red,
            size: 36.w,
          ),
        ),
        Text.rich(
          textSpan,
          overflow: TextOverflow.visible,
          maxLines: 1,
          style: TextStyle(
            fontSize: 22.sp,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

bool _isPlayVideo(ListModel list, int index) {
  assert(index != null && index >= 0 && index < list.length);
  final dynamic item = list[index];
  assert(item != null);
  return item is AdvertItem && item.canPlay;
}

void computerVideoStateValueWhenScrollUpdate(
    ListModel list, List<ViewportOffsetData> viewportOffsetDataList) {
  assert(list != null);
  assert(viewportOffsetDataList != null);
  assert(viewportOffsetDataList.isNotEmpty);

  _computerPauseVideoWhenScrollUpdate(list, viewportOffsetDataList);

  for (ViewportOffsetData viewportOffsetData in viewportOffsetDataList) {
    final int index = viewportOffsetData.index;
    assert(list.states != null);
    assert(list.states.length > index);
    final VideoStateMiXin state = list.states[index];
    if (state is AdvertState) {
      final AdvertState advertState = state;
      assert(advertState.detailHighlightInfo != null);
      if (advertState.detailHighlightInfo.startDetailHighlight &&
          !advertState.detailHighlightInfo.finishDetailHighlight) {
        advertState.detailHighlightInfo.startDetailHighlight = false;
      }
    }
  }
}

void _computerPauseVideoWhenScrollUpdate(
    ListModel list, List<ViewportOffsetData> viewportOffsetDataList) {
  assert(list != null);
  assert(viewportOffsetDataList != null);
  final Map<int, VideoStateMiXin> waitingPauseStates = {};

  if (viewportOffsetDataList.length > 0) {
    final ViewportOffsetData first = viewportOffsetDataList.first;

    if (first.index > 0 &&
        first.visibleOffset <
            (first.height - HeightMeasurer.primaryTitleHeight)) {
      final int preIndex = first.index - 1;
      final VideoStateMiXin state = list.states[preIndex];
      assert(state != null);
      if (state is AdvertState) {
        waitingPauseStates[preIndex] = state;
      }
    }

    final ViewportOffsetData last = viewportOffsetDataList.last;
    final int lastIndex = last.index + 1;
    if (lastIndex < list.length) {
      final VideoStateMiXin state = list.states[lastIndex];
      assert(state != null);
      if (state is AdvertState) {
        waitingPauseStates[lastIndex] = state;
      }
    }
  }

  if (waitingPauseStates.isEmpty) return;

  for (VideoStateMiXin state in waitingPauseStates.values) {
    final AdvertState advertState = state;
    assert(advertState?.playState != null);
    if (advertState.playState.isPlaying() || advertState.playState.isEnd()) {
      final PlayState playState = PlayState.startAndPause;
      DetailHighlightInfo detailHighlightInfo;
      assert(advertState.detailHighlightInfo != null);
      if (advertState.detailHighlightInfo.startDetailHighlight) {
        detailHighlightInfo = DetailHighlightInfo(
            startDetailHighlight: false, finishDetailHighlight: false);
      }
      advertState.changeState(
        playState: playState,
        detailHighlightInfo: detailHighlightInfo,
      );
    }
  }
}

int _computerPlayIndexWhenScrollEnd(
    ListModel list, List<ViewportOffsetData> viewportOffsetDataList) {
  if (viewportOffsetDataList.length == 1) {
    final ViewportOffsetData viewportOffsetData = viewportOffsetDataList[0];
    final int index = viewportOffsetData.index;

    if (_isPlayVideo(list, index) &&
        viewportOffsetData.visibleOffset == viewportOffsetData.height * 0.5) {
      return index;
    }
  } else if (viewportOffsetDataList.length > 1) {
    final List<ViewportOffsetData> tmpViewportOffsetData =
        List.from(viewportOffsetDataList);
    final ViewportOffsetData first = tmpViewportOffsetData.removeAt(0);

    if (_isPlayVideo(list, first.index)) {
      final double videoHeight = HeightMeasurer.advertItemHeight;
      final double viewportVideoHeight = first.visibleOffset -
          HeightMeasurer.itemVideoTitleHeightWithVerticalList -
          HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList;
      final double boundaryValue = 2 / 3;
      if (viewportVideoHeight / videoHeight >= boundaryValue) {
        return first.index;
      }
    }

    final ViewportOffsetData last = tmpViewportOffsetData.removeLast();

    for (ViewportOffsetData viewportOffsetData in tmpViewportOffsetData) {
      if (_isPlayVideo(list, viewportOffsetData.index))
        return viewportOffsetData.index;
    }

    if (_isPlayVideo(list, last.index)) {
      final double videoHeight = HeightMeasurer.advertItemHeight;
      final double viewportVideoHeight = last.visibleOffset -
          HeightMeasurer.itemVideoMainAxisSpaceWithVerticalList;
      final double boundaryValue = 0.5;
      if (viewportVideoHeight / videoHeight >= boundaryValue) {
        return last.index;
      }
    }
  }

  return -1;
}

void _computerPlayVideoWhenScrollEnd(
    ListModel list, List<ViewportOffsetData> viewportOffsetDataList) {
  assert(list != null);
  assert(viewportOffsetDataList != null);

  //播放状态一定要最后修改
  final int index =
      _computerPlayIndexWhenScrollEnd(list, viewportOffsetDataList);

  assert(list.states != null);

  if (index < 0) {
    for (VideoStateMiXin state in list.states) {
      assert(state != null);
      if (!(state is AdvertState)) continue;
      final AdvertState advertState = state;
      assert(advertState.playState != null);
      if (advertState.playState.isPlaying()) {
        advertState.changeState(
          playState: PlayState.startAndPause,
        );
      }
    }
  } else {
    final VideoStateMiXin state = list.states[index];
    assert(state is AdvertState);
    final AdvertState advertState = state;
    assert(advertState.playState != null);
    if (!advertState.playState.isPlaying() && !advertState.playState.isEnd()) {
      advertState.changeState(
        playState: PlayState.startAndPlay,
      );
    }
  }
}

void _computerVideoPopDirection(
    ListModel list,
    List<ViewportOffsetData> viewportOffsetDataList,
    double videoPopupViewport) {
  assert(viewportOffsetDataList != null && viewportOffsetDataList.length > 0);

  final ViewportOffsetData last = viewportOffsetDataList.last;
  assert(last != null);

  final int index = last.index;

  assert(list.length > index);

  if (!_isPlayVideo(list, index)) return;

  final VideoStateMiXin state = list.states[index];
  assert(state != null);
  assert(state is AdvertState);
  final AdvertState advertState = state;

  if (last.visibleOffset >= videoPopupViewport) {
    if (advertState.popupDirection != PopupDirection.bottom) {
      advertState.changeState(
        popupDirection: PopupDirection.bottom,
      );
    }
  } else {
    if (advertState.popupDirection != PopupDirection.top) {
      advertState.changeState(
        popupDirection: PopupDirection.top,
      );
    }
  }
}

void _computerVideoDetailHighlight(
    ListModel list,
    List<ViewportOffsetData> viewportOffsetDataList,
    double videoPopupViewport) {
  assert(viewportOffsetDataList != null && viewportOffsetDataList.length > 0);

  for (ViewportOffsetData offsetData in viewportOffsetDataList) {
    if (!_isPlayVideo(list, offsetData.index)) continue;

    VideoStateMiXin state = list.states[offsetData.index];
    assert(state != null);
    assert(state is AdvertState);
    final AdvertState advertState = state;
    assert(advertState.detailHighlightInfo?.startDetailHighlight != null);
    final bool _defaultDetailHighlight =
        advertState.detailHighlightInfo.startDetailHighlight;

    if (offsetData.visibleOffset >= offsetData.height * 0.5) {
      if (!_defaultDetailHighlight) {
        advertState.changeState(
          detailHighlightInfo: DetailHighlightInfo(
            startDetailHighlight: true,
            finishDetailHighlight:
                advertState.detailHighlightInfo.finishDetailHighlight,
          ),
        );
      }
    }
  }
}

//头永远不会被移除
void computerVideoStateValueWhenScrollEnd(
    ListModel list,
    List<ViewportOffsetData> viewportOffsetDataList,
    double videoPopupViewport) {
  assert(list != null);
  assert(viewportOffsetDataList != null);
  assert(videoPopupViewport != null);
  assert(videoPopupViewport > 0);

  _computerVideoPopDirection(list, viewportOffsetDataList, videoPopupViewport);

  _computerVideoDetailHighlight(
      list, viewportOffsetDataList, videoPopupViewport);

  _computerPlayVideoWhenScrollEnd(list, viewportOffsetDataList);
}
