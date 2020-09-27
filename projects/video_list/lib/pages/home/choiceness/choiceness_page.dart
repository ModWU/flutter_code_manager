import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_list/resources/res/dimens.dart';

class ChoicenessPage extends StatefulWidget {
  const ChoicenessPage();

  @override
  State<StatefulWidget> createState() => _ChoicenessPageState();
}

class _ChoicenessPageState extends State<ChoicenessPage> with AutomaticKeepAliveClientMixin {
  static const _barLeadingLeft = 12.0;
  static const _appBarHeight = Dimens.action_bar_height + 8.0;

  @override
  void initState() {
    print("ChoicenessPage -> initState()");
    super.initState();
  }

  @override
  void dispose() {
    print("ChoicenessPage -> dispose()");
    super.dispose();
  }

  Widget _buildAction(int index, IconData iconData,
      {double leftPadding = 8.0, double rightPadding = 8.0}) {
    return GestureDetector(
      onTap: () {
        print("action index: $index");
      },
      child: Container(
        margin: EdgeInsets.only(left: leftPadding, right: rightPadding),
        //color: Colors.red,
        child: Icon(
          iconData,
          //size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          //preferredSize: Size(20, 20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _barLeadingLeft),
            child: AppBar(
              titleSpacing: 0.0,
              elevation: 0.0,
              //leadingWidth: 0,
              actions: [
                _buildAction(0, Icons.videogame_asset),
                _buildAction(1, Icons.file_download),
                _buildAction(2, Icons.history),
                _buildAction(3, Icons.delete_forever, rightPadding: 0.0),
              ],
              bottom: null,

              title: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,

                    ),
                    child: Container(
                      //color: Colors.grey,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.search,
                              //size: 26,
                              //color: Colors.black45,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(
                              "成都双流车祸frwrewre得到",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,

                            ),
                          ),
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                "[热门]",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
                onTap: () {
                  print("搜索");
                },
              ),
            ),
          ),
          preferredSize: Size.fromHeight(_appBarHeight - 18.0),
        ),
        floatingActionButton: null,
        body: Center(
          child: Text("精选"),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
