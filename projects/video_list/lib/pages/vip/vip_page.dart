import 'package:flutter/material.dart';

class VipPage extends StatefulWidget {

  const VipPage();

  @override
  State<StatefulWidget> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {

  @override
  void initState() {
    print("VipPage -> initState()");
    super.initState();
  }

  @override
  void dispose() {
    print("VipPage -> dispose()");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "vip",
      theme: Theme.of(context).copyWith(),
      home: Scaffold(
          appBar: null,
          body: Center(
            child: Text("VIP"),
          )
      ),
    );
  }
}