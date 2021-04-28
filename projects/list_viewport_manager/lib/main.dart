import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'list_demo.dart';

void main() => runApp(MyApp());

class StateData extends GetxController {
  StateData.def(int length)
      : assert(length > 0),
        _itemSelectedStates =
            List.filled(length, false).map((e) => RxBool(e)).toList();

  List<RxBool> _itemSelectedStates;
  final selectedAll = false.obs;

  int _selectedCount = 0;

  int get length => _itemSelectedStates.length;

  int get selectedCount => _selectedCount;

  RxBool getSelectedState(int index) {
    assert(index >= 0);
    assert(index < _itemSelectedStates.length);
    return _itemSelectedStates[index];
  }

  void selectAll(bool selected) {
    if (selectedAll.value == selected) return;

    if (selected) {
      _selectedCount = length;
    } else {
      _selectedCount = 0;
    }

    for (var rb in _itemSelectedStates) {
      if (rb.value == selected) continue;
      rb.toggle();
    }

    selectedAll.toggle();
  }

  void select(int index, bool selected) {
    assert(index >= 0);
    assert(index < _itemSelectedStates.length);

    if (_itemSelectedStates[index].value == selected) return;

    _itemSelectedStates[index].value = selected;

    bool tmpSelectedAll = false;

    if (selected) {
      if (_selectedCount < length) _selectedCount++;

      if (_selectedCount >= length) tmpSelectedAll = true;
    } else if (_selectedCount > 0) {
      _selectedCount--;
    }

    if (selectedAll.value != tmpSelectedAll) {
      selectedAll.value = tmpSelectedAll;
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(selectedAll, (value) {});
  }
}

class Home extends StatelessWidget {
  final StateData dataController = Get.put(StateData.def(6));

  @override
  Widget build(context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildListView()),
          _buildBottomController(),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    return Obx(() {
      return CheckboxListTile(
        subtitle: Text('一枚有态度的程序员$index'),
        title: Text("人物$index"),
        secondary: Icon(Icons.person),
        value: dataController.getSelectedState(index).value,
        onChanged: (bool? selected) {
          dataController.select(index, selected!);
        },
      );
    },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemBuilder: (_, int index) {
        //if (index >= dataController.length) return null;
        return _buildItem(index);
      },
      itemCount: dataController.length,
    );
  }

  Widget _buildBottomController() {
    return Row(
      children: [
        Obx(() {
          return Checkbox(
            value: dataController.selectedAll.value,
            onChanged: (bool? allSelected) {
              dataController.selectAll(allSelected!);
            },
          );
        }),
        Text("全选"),
        ValueBuilder<bool>(
          initialValue: false,
          builder: (value, updateFn) => Switch(
            value: value,
            onChanged: updateFn, // 你可以用( newValue )=> updateFn( newValue )。
          ),
          // 如果你需要调用 builder 方法之外的东西。
          onUpdate: (value) => print("Value updated: $value"),
          onDispose: () => print("Widget unmounted"),
        ),
        ObxValue(
          (RxBool data) {
            return Switch(
              value: data.value,
              onChanged:
                  data, // Rx 有一个 _callable_函数! 你可以使用 (flag) => data.value = flag,
            );
          },
          false.obs,
        ),
      ],
    );
  }
}

