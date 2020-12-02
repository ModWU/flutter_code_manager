import 'package:carousel_example/base_model.dart';
import 'package:flutter/material.dart';
import 'package:carousel/carousel.dart';
import 'package:provider/provider.dart';
import 'advert_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum CarouselProperty {
  reverse,
  autoPlay,
  padEnds,
  padEndsViewportFraction,
  autoPlayDelay,
  viewportFraction,
  scale,
  scrollDirection,
  leftPadding,
  rightPadding,
  topPadding,
  bottomPadding,
  currentIndex,
}

class _MyHomePageState extends State<MyHomePage> {
  CarouselController _controller;

  List _resources = [
    'images/h1.jpg',
    'images/h2.jpg',
    'images/h3.jpg',
    'images/h4.jpeg',
    AdvertItem(
      name: "crazy-story",
      introduce: "introduce",
      isApplication: true,
      detailUrl: "https://www.baidu.com/",
      iconUrl: "https://i.loli.net/2020/10/09/GvLS47z2DXTRkcq.png",
      videoUrl:
          "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
      showImgUrl: null,
    ),
  ];

  static int _initialIndex = 0;

  static double _basePaddingValue = 4.0;

  ValueNotifier<int> _indexNotifier = new ValueNotifier<int>(_initialIndex);

  Map<CarouselProperty, Object> _properties = {
    CarouselProperty.reverse: false,
    CarouselProperty.autoPlayDelay: false,
    CarouselProperty.autoPlay: false,
    CarouselProperty.viewportFraction: false,
    CarouselProperty.padEndsViewportFraction: false,
    CarouselProperty.padEnds: false,
    CarouselProperty.scale: false,
    CarouselProperty.scrollDirection: false,
    CarouselProperty.leftPadding: false,
    CarouselProperty.rightPadding: false,
    CarouselProperty.topPadding: false,
    CarouselProperty.bottomPadding: false,
  };

  @override
  void initState() {
    super.initState();
    // _controller = CarouselController();
  }

  @override
  void dispose() {
    //  _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, int index) {
    dynamic data = _resources[index];
    if (data is AdvertItem) {
      return AdvertView(data, onPlay: (isStartPlay, isPlayEnd) {});
    } else {
      return Image.asset(
        data,
        fit: BoxFit.cover,
      );
    }
  }

  //compare the 'PageView'
  Widget _buildPageView() {
    return PageView.custom(
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _buildItem(context, index);
        },
        childCount: _resources.length,
      ),
      controller: PageController(viewportFraction: 0.95),
      onPageChanged: (index) {
        setState(() {});
      },
    );
  }

  //Find a bug with 'viewportFraction', There may be little gaps that are useless.
  Widget _buildCarouselView() {
    return CarouselView.custom(
      //'carouselController' must be destroyed, This is just a demo
      controller: _controller = CarouselController(
        viewportFraction:
            _properties[CarouselProperty.viewportFraction] ? 0.95 : 1.0,
        initialPage: 0,
        autoPlayDelay:
            _properties[CarouselProperty.autoPlayDelay] ? 1000 : 5000,
        autoPlay: _properties[CarouselProperty.autoPlay],
        //curve: Curves.ease,
        //duration: Duration(milliseconds: 500),
      ), //_controller,
      childrenDelegate: CustomSliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(
              left: _properties[CarouselProperty.leftPadding]
                  ? _basePaddingValue
                  : 0,
              right: _properties[CarouselProperty.rightPadding]
                  ? _basePaddingValue
                  : 0,
              top: _properties[CarouselProperty.topPadding]
                  ? _basePaddingValue
                  : 0,
              bottom: _properties[CarouselProperty.bottomPadding]
                  ? _basePaddingValue
                  : 0,
            ),
            child: _buildItem(context, index),
          );
        },
        childCount: _resources.length,
      ),
      reverse: _properties[CarouselProperty.reverse],
      //'loop' keep initial value
      loop: true,
      //'padEndsViewportFraction' can take 'padEnds' place
      padEndsViewportFraction:
          _properties[CarouselProperty.padEndsViewportFraction] ? 0.5 : null,
      padEnds: _properties[CarouselProperty.padEnds],
      scale: _properties[CarouselProperty.scale] ? 0.85 : 1.0,
      scrollDirection: _properties[CarouselProperty.scrollDirection]
          ? Axis.vertical
          : Axis.horizontal,
      //"transformBuilder" can transform the positions of children
      /*transformBuilder: (BuildContext context, int index, double page,
          double viewportMainAxisExtent, Widget child) {
        //You can transform the position of child according to the 'index' and 'page'
        return child;
      },*/
      onHandUpChanged: (index) {
        //It's not smooth with set the state directly. The same to 'PageView'.
        /*setState(() {
          _properties[CarouselProperty.currentIndex] = index;
        });*/
        //It is recommended to use 'provider' for updating
        _indexNotifier.value = index;
      },
      //"onPageChanged" provide the original callback way that listening 'index' change
      /*onPageChanged: (index) {
        print("currentIndex: $index");
      },*/
    );
  }

  Widget _selectItem(String tag, CarouselProperty property,
      {Function(bool selected) onSelected}) {
    return RawChip(
      label: Text(tag),
      selected: _properties[property],
      onSelected: onSelected ??
          (v) {
            setState(() {
              _properties[property] = v;
            });
          },
      showCheckmark: false,
      selectedColor: Colors.blue,
      selectedShadowColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _indexNotifier,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<ValueNotifier<int>>(
            builder: (BuildContext context, ValueNotifier<int> indexNotifier,
                Widget child) {
              return Text("${indexNotifier.value}");
            },
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            SizedBox(
              height: 240,
              child: _buildCarouselView(),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children: <Widget>[
                _selectItem(
                    "verticalDirection", CarouselProperty.scrollDirection),
                _selectItem("reverse", CarouselProperty.reverse),
                _selectItem("autoPlay", CarouselProperty.autoPlay,
                    onSelected: (autoPlay) {
                  setState(() {
                    _properties[CarouselProperty.autoPlay] = autoPlay;
                  });
                  //You can also call the 'handleAutoPlay'/'startAutoPlay'/'stopAutoPlay' method of CarouselController
                  //if (_controller != null) _controller.handleAutoPlay(autoPlay);
                }),
                _selectItem("autoPlayDelay", CarouselProperty.autoPlayDelay),
                _selectItem("scale", CarouselProperty.scale),
                _selectItem(
                    "viewportFraction", CarouselProperty.viewportFraction),
                _selectItem("padEnds", CarouselProperty.padEnds),
                _selectItem("padEndsViewportFraction",
                    CarouselProperty.padEndsViewportFraction),
                _selectItem("leftPadding", CarouselProperty.leftPadding),
                _selectItem("rightPadding", CarouselProperty.rightPadding),
                _selectItem("topPadding", CarouselProperty.topPadding),
                _selectItem("bottomPadding", CarouselProperty.bottomPadding),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
