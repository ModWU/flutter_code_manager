import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:video_list/models/choiceness_model.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../page_controller.dart';
import '../../page_utils.dart';

class ChoicenessHeader extends StatefulWidget {
  const ChoicenessHeader(
      this.headerImages, this.pageVisibleNotifier, this.pageScrollNotifier);

  @override
  State<StatefulWidget> createState() => _ChoicenessHeaderState();

  final PageVisibleNotifier pageVisibleNotifier;

  final PageScrollNotifier pageScrollNotifier;

  final List<ChoicenessHeaderItem> headerImages;
}

class _ChoicenessHeaderState extends State<ChoicenessHeader>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  _BottomTextNotifier _bottomTextNotifier;

  //bool _autoPlay = true;
  int _index = 0;
  double _height = 440.h;
  VisibleNotifier _autoPlayNotifier = VisibleNotifier(visible: true);//默认开启自动播放

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

  //保存最后一次垂直滚动的值
  ScrollMetrics _lastMetrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bottomTextNotifier = _BottomTextNotifier();
    if (widget.headerImages.length > 0)
      _bottomTextNotifier._text = widget.headerImages[0].introduce;
    print("_ChoicenessHeaderState initState-->${widget.headerImages}");

    //当前滚动对象只针对当前页的滚动，初始化页面滚动监听
    widget.pageScrollNotifier.addListener(() {
      ScrollMetrics scrollMetrics = widget.pageScrollNotifier.metrics;
      //当垂直滚动时判断头部可视范围
      if (scrollMetrics.axis == Axis.vertical) {
        //因为肯定是在当前页可视情况下发生滚动，所以直接切换可视状态
        print("首页精选页垂直滚动收到通知：${scrollMetrics.pixels}");
        bool visible = _isVisible(scrollMetrics);
        bool autoPlay = _autoPlayNotifier.visible;
        if (autoPlay) {
          //正在自动播放时，滚动到不可视范围时将自动播放停止，并且重置下标为第一张图片
          if (!visible) {
            _autoPlayNotifier.hide();
            _index = 0;
          }
        } else {
          //不在自动播放时，滚动到可视范围时开始自动播放
          if (visible)
            _autoPlayNotifier.show();
        }
        _lastMetrics = scrollMetrics;
      }
    });

    widget.pageVisibleNotifier.addListener(() {
      print("首页精选页的可视切换收到通知：${widget.pageVisibleNotifier.visible}");
      //此时需要判断最后一次滚动位置是否是可视范围内：
      //如果不是可视范围内说明肯定是停止播放的，此时无需处理；
      if (_isVisible(_lastMetrics))
        _autoPlayNotifier.toggle(widget.pageVisibleNotifier.visible);
    });
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _autoPlayNotifier),
        ChangeNotifierProvider.value(value: _bottomTextNotifier),
      ],
      child: GestureDetector(
        onTap: () {
          print("点击了第${_index}个");
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
                child: Selector<VisibleNotifier, bool>(builder:
                    (BuildContext context, bool autoPlay, Widget child) {
                  print("---------autoPlay change: $autoPlay");
                  return _buildSwiper(autoPlay);
                }, selector:
                    (BuildContext context, VisibleNotifier notifier) {
                  print("---------autoPlay before: ${notifier.visible}");
                  return notifier.visible;
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
