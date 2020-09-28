import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_list/pages/page_controller.dart';

class TmpPage extends TabBasePage {

  const TmpPage(PageIndex pageIndex, int tabIndex, this.data) : super(pageIndex, tabIndex);

  final String data;

  @override
  State<StatefulWidget> createState() => _TmpPageState();
}

class _TmpPageState extends State<TmpPage> {

  @override
  void initState() {
    print("TmpPage ${widget.data} -> initState()");
    super.initState();
  }

  @override
  void dispose() {
    print("TmpPage ${widget.data} -> dispose()");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return  Center(
      child: Text(widget.data),
    );
  }
}