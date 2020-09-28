import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_list/pages/page_controller.dart';
import 'package:video_list/resources/res/dimens.dart';
import 'choiceness_body_header.dart';
import 'choiceness_page_bar.dart';

class ChoicenessPage extends TabBasePage {

  const ChoicenessPage(PageIndex pageIndex, int tabIndex) : super(pageIndex, tabIndex);

  //const ChoicenessPage(this.tabIndex);

  @override
  State<StatefulWidget> createState() => _ChoicenessPageState();
}

class _ChoicenessPageState extends State<ChoicenessPage>
    with AutomaticKeepAliveClientMixin {
  static const _barLeadingLeft = 12.0;
  static const _appBarHeight = Dimens.action_bar_height - 10.0;

  List<HeaderImage> _headerImages;

  @override
  void initState() {
    print("ChoicenessPage -> initState()");
    super.initState();
    _loadResources();
  }

  @override
  void dispose() {
    print("ChoicenessPage -> dispose()");
    super.dispose();
  }

  void _loadResources() {

    _headerImages ??= [];
    _headerImages.clear();

    HeaderImage headerImage1 = HeaderImage('http://via.placeholder.com/288x188', imageDesc: '真策略，够烧脑1');
    HeaderImage headerImage2 = HeaderImage('http://via.placeholder.com/288x188', imageDesc: '真三国无双，只需一元即可拿下2');
    HeaderImage headerImage3 = HeaderImage('http://via.placeholder.com/288x188', imageDesc: '京东方苦咖啡到了' * 6);
    HeaderImage headerImage4 = HeaderImage('http://via.placeholder.com/288x188', imageDesc: '【甜蜜暴击】林可然爱上霸道总裁！');
    _headerImages.add(headerImage1);
    _headerImages.add(headerImage2);
    _headerImages.add(headerImage3);
    _headerImages.add(headerImage4);

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ChoicenessHeader(widget.pageIndex, widget.tabIndex, _headerImages),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
