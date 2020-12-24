import 'package:flutter/material.dart';

//适用于有限集合，可手动更换顺序的列表，缺陷：无法控制滑动边缘效果和大小
class ReorderableListDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReorderableListDemoState();
}

class _ReorderableListDemoState extends State<ReorderableListDemo> {
  List<String> _items = List.generate(20, (int i) => '$i');

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: <Widget>[
        for (String item in _items)
          Container(
            key: ValueKey(item),
            alignment: Alignment.center,
            height: 100,
            width: 250,
            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color:
                    Colors.primaries[int.parse(item) % Colors.primaries.length],
                borderRadius: BorderRadius.circular(10)),
            child: SelectableText.rich(
              TextSpan(
                  text: "致亲爱的读帅:\n",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  children: [
                    TextSpan(
                        text:
                            "    北京的天气变冷了，最近的你过得还好吗？"
                            "每次一想起跟你在一起的快乐时光，泪水就模糊了双眼。"
                            "我依稀记得你那高大而坚实的背影，是那么让人沉醉！"
                            "因为每次你的出现，你一定会稳稳的站着，不动声色地望着我们有些可笑的样子。"
                            "那是天真而真挚的笑容，在灿烂的阳光下熠熠生辉，虽不耀眼却稚嫩而朴实。",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                          fontSize: 14.5,
                          fontStyle: FontStyle.normal,
                        )),
                  ]),
            ),
          )
      ],
      onReorder: (int oldIndex, int newIndex) {
        /*if (oldIndex < newIndex) {
          newIndex -= 1;
        }*/
        var child = _items.removeAt(oldIndex);
        _items.insert(newIndex, child);
        setState(() {});
      },
    );
  }
}
