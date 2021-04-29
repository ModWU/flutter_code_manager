import 'package:flutter/foundation.dart';
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

  List<double>? _initHeights;

  late ListModel _listModel;

  late StateController _stateController;
  int? _nearCenterIndex;

  late ScrollController _scrollController;
  double _listHeight = 450;

  bool _childFixHeight = false;

  void updateHeights() {
    final Random rd = Random();
    final int count = _initHeights?.length ?? rd.nextInt(20) + 15;
    _initHeights = List.generate(count, (index) => rd.nextDouble() * 100 + 40);
  }

  void resetListHeight() {
    final Random rd = Random();
    _listHeight = rd.nextDouble() * 350 + 100;
  }

  @override
  void initState() {
    super.initState();
    updateHeights();
    _listModel = ListModel(
      dataList: _initHeights!.map((e) => "$e").toList(),
    );
    _stateController = Get.put(StateController.fill(_listModel.length));
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _listModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildListView() {
    return Container(
      height: _listHeight,
      width: double.infinity,
      color: Colors.black12,
      child: _listModel.buildList(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            reverse: false,
            itemBuilder: (context, index) {
              return _listModel.buildChild(
                index: index,
                child: Obx(() {
                  final nearCenter = _stateController.testStates[index].value;
                  return Container(
                    height: !_childFixHeight || !nearCenter
                        ? _initHeights![index]
                        : 20,
                    width: _initHeights![index],
                    color: nearCenter
                        ? Colors.white
                        : Colors.primaries[index % Colors.primaries.length],
                    alignment: Alignment.center,
                    child: Text(
                      nearCenter
                          ? "$index => center"
                          : "$index => ${_listModel[index]}",
                      style: TextStyle(
                        fontSize: nearCenter ? 16 : 12,
                        color: nearCenter ? Colors.black : Colors.white,
                        fontStyle:
                            nearCenter ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  );
                }),
              );
            },
            itemCount: _initHeights!.length,
          ),
          onUpdate: (IScrollDataInterface scrollDataInterface) {
            print(
                "onUpdate =>maxScrollExtent: ${scrollDataInterface.scrollMetrics.maxScrollExtent}}, firstVisibleIndex: ${scrollDataInterface.firstVisibleIndex}, lastVisibleIndex: ${scrollDataInterface.lastVisibleIndex}");
            _updateNearCenterItem(scrollDataInterface);
          },
          onScrollStart: (IScrollDataInterface scrollDataInterface) {},
          onScrollEnd: (IScrollDataInterface scrollDataInterface) {
            print(
                "onScrollEnd => maxScrollExtent: ${scrollDataInterface.scrollMetrics.maxScrollExtent}}");
          },
          onScrollUpdate: (IScrollDataInterface scrollDataInterface) {
            print(
                "onScrollUpdate => maxScrollExtent: ${scrollDataInterface.scrollMetrics.maxScrollExtent}, firstVisibleIndex: ${scrollDataInterface.firstVisibleIndex}, lastVisibleIndex: ${scrollDataInterface.lastVisibleIndex}, viewportDimension: ${scrollDataInterface.scrollMetrics.viewportDimension}, pixels: ${scrollDataInterface.scrollMetrics.pixels}");
            _updateNearCenterItem(scrollDataInterface);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  children: [
                    _buildListView(),
                    Positioned(
                      child: Center(
                        child: Text(
                          "center",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                    ),
                    Positioned(
                      child: Divider(
                        height: 2.0,
                        color: Colors.black,
                      ),
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          resetListHeight();
                        });
                      },
                      child: Text("改变高度"),
                    ),
                    ChoiceChip(
                      label: Text('孩子定高'),
                      selected: _childFixHeight,
                      onSelected: (v) {
                        setState(() {
                          _childFixHeight = v;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          updateHeights();
                        });
                      },
                      child: Text("改变数据"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateNearCenterItem(IScrollDataInterface scrollDataInterface) {
    if (!scrollDataInterface.hasVisibleChild) return;

    if (scrollDataInterface.nearCenterVisibleIndex != _nearCenterIndex) {
      _stateController
          .testStates[scrollDataInterface.nearCenterVisibleIndex].value = true;
      if (_nearCenterIndex != null) {
        _stateController.testStates[_nearCenterIndex!].value = false;
      }
      _nearCenterIndex = scrollDataInterface.nearCenterVisibleIndex;
    }
  }
}
