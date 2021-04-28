import 'package:flutter/material.dart';
import 'dart:math';

import 'layout_callback_builder.dart';
import 'package:get/get.dart';

import 'list_viewport_manager.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class StateController extends GetxController {
  final List<RxBool> testStates;

  StateController.fill(int length)
      : testStates = List.filled(length, false).map((e) => e.obs).toList();
}

class MyAppState extends State<MyApp> {
  /*List<double> _heights;
  List<Key> _keys;*/

  late List<double> _initHeights;

  late ListModel _listModel;

  late StateController _stateController;
  int? _nearCenterIndex;

  @override
  void initState() {
    super.initState();
    final Random rd = Random();
    final int count = rd.nextInt(20) + 15;
    _initHeights = List.generate(count, (index) => rd.nextDouble() * 100 + 40);
    _listModel = ListModel(
      dataList: _initHeights.map((e) => "$e").toList(),
    );
    _stateController = Get.put(StateController.fill(_listModel.length));
  }

  @override
  void dispose() {
    _listModel.dispose();
    super.dispose();
  }

  void _initHeightsByScroll(ScrollMetrics metrics) {
    print("");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Container(
            height: 500,
            width: 400,
            color: Colors.black12,
            child: _listModel.buildList(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _listModel.buildChild(
                      index: index,
                      child: Obx(() {
                        final nearCenter =
                            _stateController.testStates[index].value;
                        print("index: $index => nearCenter: $nearCenter");
                        return Container(
                          height: _initHeights[index],
                          width: _initHeights[index],
                          color: nearCenter
                              ? Colors.white
                              : Colors
                                  .primaries[index % Colors.primaries.length],
                          alignment: Alignment.center,
                          child: Text(
                            nearCenter ? "$index => center" : "$index => ${_listModel[index]}",
                            style: TextStyle(
                              fontSize: nearCenter ? 16 : 12,
                              color: nearCenter ? Colors.black : Colors.white,
                              fontStyle: nearCenter ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                  itemCount: _initHeights.length,
                ),
                onScrollStart: (IScrollDataInterface scrollDataInterface,
                    ScrollMetrics metrics) {},
                onScrollEnd: (IScrollDataInterface scrollDataInterface,
                    ScrollMetrics metrics) {

                },
                onScrollUpdate: (IScrollDataInterface scrollDataInterface,
                    ScrollMetrics metrics) {
                  if (scrollDataInterface.nearCenterVisibleIndex !=
                      _nearCenterIndex) {
                    _stateController
                        .testStates[scrollDataInterface.nearCenterVisibleIndex]
                        .value = true;
                    if (_nearCenterIndex != null) {
                      _stateController.testStates[_nearCenterIndex!].value =
                      false;
                    }
                    _nearCenterIndex =
                        scrollDataInterface.nearCenterVisibleIndex;
                  }
                }),
          ),
        ),
      ),
    );
  }
}
