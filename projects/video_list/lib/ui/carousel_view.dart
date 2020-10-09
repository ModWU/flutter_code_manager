import 'package:flutter/material.dart';

import 'custom_pageview.dart';

class CarouselView extends StatefulWidget {

  CarouselView({this.itemBuilder, this.itemCount});

  @override
  State<StatefulWidget> createState() => _CarouselViewState();

  final IndexedWidgetBuilder itemBuilder;

  final int itemCount;

}


class _CarouselViewState extends State<CarouselView> {

  @override
  Widget build(BuildContext context) {
    return CustomPageView.custom(
      physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          print("CarouselView => index: $index");
        },
        childrenDelegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
                return widget.itemBuilder(context, index);
            },
          childCount: widget.itemCount,
        ),

    );
  }

}