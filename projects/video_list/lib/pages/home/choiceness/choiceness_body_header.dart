import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:video_list/models/choiceness_model.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../page_controller.dart';
import '../../page_utils.dart';

class ChoicenessHeader extends BaseTabPage {
  const ChoicenessHeader(PageIndex pageIndex, int tabIndex, this.headerImages)
      : super(pageIndex, tabIndex);

  @override
  State<StatefulWidget> createState() => _ChoicenessHeaderState();

  final List<ChoicenessHeaderItem> headerImages;
}

class _ChoicenessHeaderState extends State<ChoicenessHeader>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  _BottomTextNotifier _bottomTextNotifier;

  bool _autoPlay = true;
  int _index = 0;
  double _height = 440.h;

  Widget _swiperBuilder(BuildContext context, int index) {
    if (!widget.headerImages[index].isAdvert) {
      return Container(
        width: Dimens.design_screen_width.w,
        // margin: EdgeInsets.symmetric(horizontal: 50),
        child: Image.asset(
          widget.headerImages[index].imgUrl,
          fit: BoxFit.cover,
        ), /*Image.network(
        widget.headerImages[index]
            .imgUrl, //"http://via.placeholder.com/288x188",
        fit: BoxFit.fill,
      ),*/
      );
    } else {
      return Container(
        width: Dimens.design_screen_width.w,
        alignment: Alignment.center,
        // margin: EdgeInsets.symmetric(horizontal: 50),
        child: Text(
          "我是广告",
          style: TextStyle(fontSize: 24),
        ), /*Image.network(
        widget.headerImages[index]
            .imgUrl, //"http://via.placeholder.com/288x188",
        fit: BoxFit.fill,
      ),*/
      );
    }
  }

  /* Image.network(
  widget.headerImages[index]
      .imageUrl, //"http://via.placeholder.com/288x188",
  fit: BoxFit.fill,
  )*/

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("_ChoicenessHeaderState didChangeAppLifecycleState -> 进入后台");
    }
    if (state == AppLifecycleState.resumed) {
      print("_ChoicenessHeaderState didChangeAppLifecycleState -> 进入前台");
    }

    if (state == AppLifecycleState.inactive) {
      print("_ChoicenessHeaderState didChangeAppLifecycleState -> 可见，不能响应用户操作");
    }

    if (state == AppLifecycleState.detached) {
      print(
          "_ChoicenessHeaderState didChangeAppLifecycleState -> 虽然还在运行，但已经没有任何存在的界面");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bottomTextNotifier = _BottomTextNotifier();
    if (widget.headerImages.length > 0)
      _bottomTextNotifier._text = widget.headerImages[0].introduce;
    print("_ChoicenessHeaderState initState-->${widget.headerImages}");
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
    super.dispose();
  }

  Widget _buildSwiper(bool autoPlay) {
    return Swiper(
      itemBuilder: _swiperBuilder,
      itemCount: widget.headerImages.length,
      pagination: null,
      control: null, //new SwiperControl(),
      scrollDirection: Axis.horizontal,
      autoplay: autoPlay,
      duration: 500,
      index: _index,
      viewportFraction: 0.94,
      scale: 0.986,
      autoplayDelay: 5000,
      //onTap: (index) => print('点击了第$index个'),
      onIndexChanged: (index) {
        _index = index;
        _bottomTextNotifier.text = widget.headerImages[index].introduce;
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
    return GestureDetector(
      onTap: () {
        print("点击了第${_index}个");
      },
      child: ChangeNotifierProvider<_BottomTextNotifier>.value(
        value: _bottomTextNotifier,
        child: Container(
          width: Dimens.design_screen_width.w,
          color: Colors.grey[200],
          height: _height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 370.h,
                child: Selector<PageChangeAndScrollNotifier, bool>(builder:
                    (BuildContext context, bool autoPlay, Widget child) {
                  print("---------autoPlay change: $autoPlay");
                  return _buildSwiper(autoPlay);
                }, selector: (BuildContext context,
                    PageChangeAndScrollNotifier notifier) {
                  if (notifier.isPageChange == null) {
                    print("---------autoPlay before => 第一次进入：notifier.isPageChange = null");
                    return _autoPlay;
                  }

                  ScrollMetrics metrics =
                      notifier.getMetrics(Axis.vertical, widget.pageIndex, widget.tabIndex);

                  if (notifier.isPageChange) {

                    bool isVisible = _isVisible(metrics);
                    //print("---------autoPlay before => pageIndex:${notifier.currentPageIndex}, tabIndex:${notifier.currentTabIndex}, _autoPlay:${_autoPlay}, isVisible:$isVisible, piex:${metrics?.pixels}");
                    if (!isVisible) {
                      if (_autoPlay) _autoPlay = false;
                      return _autoPlay;
                    }

                    if (!_autoPlay &&
                        isCurrentPage(context, notifier, widget.pageIndex,
                            widget.tabIndex)) {
                      _autoPlay = true;
                    } else if (_autoPlay &&
                        !isCurrentPage(context, notifier, widget.pageIndex,
                            widget.tabIndex)) {
                      _autoPlay = false;
                    }
                  } else {
                    if (metrics?.axis == Axis.vertical) {
                      //print("---------autoPlay before => scroll: ${metrics.pixels}, height:$_height, _autoPlay:$_autoPlay");
                      bool isVisible = _isVisible(metrics);
                      if (!_autoPlay && isVisible) {
                        _autoPlay = true;
                      } else if (_autoPlay && !isVisible) {
                        _autoPlay = false;
                        _index = 0;
                      }
                    }
                  }
                  return _autoPlay;
                }),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Selector<_BottomTextNotifier, String>(builder:
                        (BuildContext context, String text, Widget child) {
                      print("---------text change");
                      return Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }, selector: (BuildContext context,
                        _BottomTextNotifier bottomTextNotifier) {
                      //这个地方返回具体的值，对应builder中的data
                      return bottomTextNotifier.text;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _BottomTextNotifier with ChangeNotifier {
  String _text;
  _BottomTextNotifier();

  set text(String text) {
    if (text == null || text == _text) return;
    _text = text;
    notifyListeners();
  }

  String get text => _text;
}
