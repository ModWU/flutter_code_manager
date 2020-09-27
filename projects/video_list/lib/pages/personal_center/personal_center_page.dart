import 'package:flutter/material.dart';

class PersonalCenterPage extends StatefulWidget {

  const PersonalCenterPage();

  @override
  State<StatefulWidget> createState() => _PersonalCenterPageState();
}

class _PersonalCenterPageState extends State<PersonalCenterPage> {

  @override
  void initState() {
    print("PersonalCenterPage -> initState()");
    super.initState();
  }

  @override
  void dispose() {
    print("PersonalCenterPage -> dispose()");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "personalCenter",
      theme: Theme.of(context).copyWith(),
      home: Scaffold(
          appBar: null,
          body: Center(
            child: Text("personalCenter"),
          )
      ),
    );
  }
}