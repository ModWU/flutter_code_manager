import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ClickState {
  search, game, download, history, delete,
}

typedef OnClickListener = void Function(ClickState state);

class ChoicenessBar extends StatelessWidget {

  const ChoicenessBar(this.onClickListener, {this.searchDesc = '', this.searchCategor = ''});

  final OnClickListener onClickListener;

  final String searchDesc;

  final String searchCategor;


  Widget _buildAction(ClickState state, IconData iconData,
      {double leftPadding = 8.0, double rightPadding = 8.0}) {
    return GestureDetector(
      onTap: () {
        onClickListener?.call(state);
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


  Widget _buildAppBar() {

    return AppBar(
      titleSpacing: 0.0,
      elevation: 0.0,
      //leadingWidth: 0,
      actions: [
        _buildAction(ClickState.game, Icons.videogame_asset),
        _buildAction(ClickState.download, Icons.file_download),
        _buildAction(ClickState.history, Icons.history),
        _buildAction(ClickState.delete, Icons.delete_forever, rightPadding: 0.0),
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
                    color: Colors.red,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    searchDesc,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,

                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      searchCategor,
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
          onClickListener?.call(ClickState.search);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAppBar();
  }
}
