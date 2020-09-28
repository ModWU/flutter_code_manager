import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../page_controller.dart';

class ChoicenessHeader extends TabBasePage {
  const ChoicenessHeader(PageIndex pageIndex, int tabIndex, this.headerImages)
      : super(pageIndex, tabIndex);

  @override
  State<StatefulWidget> createState() => _ChoicenessHeaderState();

  final List<HeaderImage> headerImages;
}

class _ChoicenessHeaderState extends State<ChoicenessHeader> {
  _BottomTextNotifier _bottomTextNotifier;

  bool _autoPlay = true;

  Widget _swiperBuilder(BuildContext context, int index) {
    return Container(
      width: Dimens.design_screen_width.w,
      // margin: EdgeInsets.symmetric(horizontal: 50),
      child: (Image.network(
        widget.headerImages[index]
            .imageUrl, //"http://via.placeholder.com/288x188",
        fit: BoxFit.fill,
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    _bottomTextNotifier = _BottomTextNotifier();
    if (widget.headerImages.length > 0)
      _bottomTextNotifier._text = widget.headerImages[0].imageDesc;
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
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<_BottomTextNotifier>.value(
      value: _bottomTextNotifier,
      child: Container(
        width: Dimens.design_screen_width.w,
        color: Colors.grey[200],
        height: 440.h,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 370.h,
              child: Selector<PageChangeNotifier, bool>(
                  builder: (BuildContext context, bool autoPlay, Widget child) {
                print("---------autoPlay change: $autoPlay");
                return Swiper(
                  itemBuilder: _swiperBuilder,
                  itemCount: widget.headerImages.length,
                  pagination: null,
                  control: null, //new SwiperControl(),
                  scrollDirection: Axis.horizontal,
                  autoplay: autoPlay,
                  duration: 500,
                  viewportFraction: 0.94,
                  scale: 0.986,
                  autoplayDelay: 5000,
                  onTap: (index) => print('点击了第$index个'),
                  onIndexChanged: (index) {
                    _bottomTextNotifier.text =
                        widget.headerImages[index].imageDesc;
                  },
                );
              }, selector: (BuildContext context,
                      PageChangeNotifier pageChangeNotifier) {
                if (_autoPlay &&
                    (pageChangeNotifier.pageIndex != PageIndex.main_page ||
                        pageChangeNotifier.tabIndex != widget.tabIndex)) {
                  _autoPlay = false;
                } else if (!_autoPlay &&
                    (pageChangeNotifier.pageIndex == PageIndex.main_page &&
                        pageChangeNotifier.tabIndex == widget.tabIndex)) {
                  _autoPlay = true;
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
    );
  }
}

class HeaderImage {
  final String imageUrl;
  final String imageDesc;

  const HeaderImage(this.imageUrl, {this.imageDesc = ''});

  @override
  String toString() {
    return "HeaderImage {imageUrl: imageUrl, imageDesc: imageDesc}";
  }
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
