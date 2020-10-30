import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:video_list/models/choiceness_model.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../ui/views/advert_view.dart';
import '../../../ui/views/carousel_view.dart';
import 'package:video_player/video_player.dart';
import '../../page_controller.dart';
import '../../../resources/export.dart';
import '../../../models/base_model.dart';
import '../../../ui/utils/icons_utils.dart' as utils;

class ChoicenessHeader extends StatefulWidget {
  const ChoicenessHeader(
      this.items, this.pageVisibleNotifier, this.pageScrollNotifier);

  @override
  State<StatefulWidget> createState() => _ChoicenessHeaderState();

  final PageVisibleNotifier pageVisibleNotifier;

  final PageScrollNotifier pageScrollNotifier;

  final List items;
}

class _ChoicenessHeaderState extends State<ChoicenessHeader>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  ValueNotifier<dynamic> _bottomTextNotifier;

  //int _index = 0;
  double _height = 440.h;
  SwiperController _swiperController = SwiperController()
    ..autoplay = true
    ..index = 0;
  bool _cannelAutoPlayInBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //print(
         // "_ChoicenessHeaderState didChangeAppLifecycleState -> 进入后台 ${_swiperController.autoplay}");
      if (_swiperController.autoplay) {
        _swiperController.stopAutoplay();
        _cannelAutoPlayInBackground = true;
      }
    } else if (state == AppLifecycleState.resumed) {
     // print(
         // "_ChoicenessHeaderState didChangeAppLifecycleState -> 进入前台 ${_swiperController.autoplay}");
      if (_cannelAutoPlayInBackground) {
        _swiperController.startAutoplay();
        _cannelAutoPlayInBackground = false;
      }
    } else if (state == AppLifecycleState.inactive) {
     // print("_ChoicenessHeaderState didChangeAppLifecycleState -> 可见，不能响应用户操作");
    } else if (state == AppLifecycleState.detached) {
      //print(
        //  "_ChoicenessHeaderState didChangeAppLifecycleState -> 虽然还在运行，但已经没有任何存在的界面");
    }
  }

  //保存最后一次垂直滚动的值
  ScrollMetrics _lastMetrics;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (widget.items.length > 0) {
      var firstItem = widget.items[0];

      if (firstItem is AdvertItem) {
        AdvertItem item = firstItem;
        _bottomTextNotifier = ValueNotifier(item.introduce);
      } else {
        VideoItem item = firstItem;
        _bottomTextNotifier = ValueNotifier(item.title);
      }
    }

    //当前滚动对象只针对当前页的滚动，初始化页面滚动监听
    widget.pageScrollNotifier.addListener(() {
      ScrollMetrics scrollMetrics = widget.pageScrollNotifier.metrics;
      //当垂直滚动时判断头部可视范围
      if (scrollMetrics.axis == Axis.vertical) {
        //因为肯定是在当前页可视情况下发生滚动，所以直接切换可视状态
        bool visible = _isVisible(scrollMetrics);
        print(
            "首页精选页垂直滚动收到通知：${scrollMetrics.pixels} visible: $visible autoplay: ${_swiperController.autoplay}");
        //bool autoPlay = _autoPlayNotifier.value;
        if (_swiperController.autoplay) {
          //正在自动播放时，滚动到不可视范围时将自动播放停止，并且重置下标为第一张图片
          if (!visible) {
            _swiperController.move(0, animation: false);
            _swiperController.stopAutoplay();
          }
        } else {
          //不在自动播放时，滚动到可视范围时开始自动播放
          if (visible) _swiperController.startAutoplay();
        }
        _lastMetrics = scrollMetrics;
      }
    });

    widget.pageVisibleNotifier.addListener(() {
      print("首页精选页的可视切换收到通知：${widget.pageVisibleNotifier.visible}");
      //此时需要判断最后一次滚动位置是否是可视范围内：
      //如果不是可视范围内说明肯定是停止播放的，此时无需处理；
      if (_isVisible(_lastMetrics)) {
        // _autoPlayNotifier.value = widget.pageVisibleNotifier.visible;
        if (widget.pageVisibleNotifier.visible) {
          _swiperController.startAutoplay();
        } else {
          _swiperController.stopAutoplay();
        }
      }
    });

    _initVideos();
  }

  void _initVideos() {
    /* for (int i = 0; i < widget.headerImages.length; i++) {
      HeaderItem headerItem = widget.headerImages[i];
      if (headerItem.isAdvert && headerItem.videoUrl != null) {
        _videoControllers ??= {};
        _videoControllers[i] =
            VideoPlayerController.network(headerItem.videoUrl)
              ..initialize().then((_) {
                print("player$i initialize finished!");
                setState(() {});
              });
       // _videoControllers[i].setLooping(false);
      }
    }*/
  }

  @override
  void didUpdateWidget(covariant ChoicenessHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      //_imageDescNotifier.text = widget.headerImages[0].imageDesc;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    /*if (_videoControllers != null) {
      for (VideoPlayerController videoController in _videoControllers.values)
        videoController.dispose();
    }*/
    _swiperController.dispose();
    super.dispose();
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    if (widget.items[index] is AdvertItem) {
      return AdvertView(widget.items[index], onPlay: (isStartPlay, isPlayEnd) {
        if (isStartPlay) {
          _swiperController.stopAutoplay();
        } else if (isPlayEnd) {
          _swiperController.startAutoplay();
        }
      });
    } else {
      return Image.asset(
        widget.items[index].imgUrl,
        fit: BoxFit.cover,
      );
    }
  }

  /*Widget _swiperBuilder2(BuildContext context, dynamic item) {
    if (item is AdvertItem) {
      //print("rebuild swiper item: $index");
      return AdvertView(item, onPlay: (isStartPlay, isPlayEnd) {
        if (isStartPlay) {
          _swiperController.stopAutoplay();
        } else if (isPlayEnd) {
          _swiperController.startAutoplay();
        }
      });
    } else {
      return Image.asset(
        item.imgUrl,
        fit: BoxFit.cover,
      );
    }
  }*/

  /*Widget _buildSwiper() {
    print("_buildSwiper........");
    return Swiper(
      itemBuilder: _swiperBuilder,
      itemCount: widget.items.length + 1,
      */ /*children: widget.items.map((item) {
        return _swiperBuilder2(context, item);
      }).toList(),*/ /*
      //control: _swiperControl, //new SwiperControl(),
      controller: _swiperController,
      pagination: null,
      scrollDirection: Axis.horizontal,
      //layout: SwiperLayout.CUSTOM,
      loop: false,
      autoplay: true,
      duration: 500,
      index: 0,
      physics: const BouncingScrollPhysics(),
      viewportFraction: 0.94,
      scale: 0.986,
      autoplayDelay: 5000,
      //onTap: (index) => print('点击了第$index个'),
      onIndexChanged: (index) {

        if (index == widget.items.length - 1) {
          _swiperController.move(0, animation: false);
          return;
        }

        _swiperController.index = index;
        if (widget.items[index] is AdvertItem) {
          _bottomTextNotifier.value = widget.items[index].introduce;
        } else if (widget.items[index] is VideoItem) {
          _bottomTextNotifier.value = widget.items[index].title;
        }

        //_bottomTextNotifier.value =
      },
    );
  }*/

  Widget _buildCarouselView() {
    return CarouselView(
      itemBuilder: _swiperBuilder,
      itemCount: widget.items.length,
      onPageChanged: (index) {
        print("wuchaochaochaochao.........当前页面：$index");
      },
    );

  }

  bool _isVisible(ScrollMetrics metrics) {
    if (metrics == null || metrics.pixels < _height) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    print("head size: ${_height}");
    super.build(context);
    return GestureDetector(
      onTap: () {
        print("点击了第${_swiperController.index}个");
      },
      child: Container(
        width: Dimens.design_screen_width.w,
        color: Colors.grey[200],
        height: _height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 370.h,
              child: _buildCarouselView(), //_buildSwiper(),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ChangeNotifierProvider.value(
                    value: _bottomTextNotifier,
                    child: Selector<ValueNotifier<dynamic>, dynamic>(builder:
                        (BuildContext context, dynamic text, Widget child) {
                      print("---------text change");
                      /* return Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );*/
                      return Text.rich(
                        TextSpan(
                          text: text is String ? text : null,
                          children: text is VideoItemTitle
                              ? [
                                  if (text.preTitle != null)
                                    TextSpan(text: "【${text.preTitle}】"),
                                  if (text.lastTitle != null)
                                    TextSpan(text: "${text.lastTitle}！"),
                                  if (text.desc != null)
                                    TextSpan(text: "${text.desc}"),
                                ]
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }, selector: (BuildContext context,
                        ValueNotifier<dynamic> bottomTextNotifier) {
                      //这个地方返回具体的值，对应builder中的data
                      return bottomTextNotifier.value;
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
