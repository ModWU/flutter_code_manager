import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {

  const VideoPage();

  @override
  State<StatefulWidget> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {

  @override
  void initState() {
    print("VideoPage -> initState()");
    super.initState();
  }

  @override
  void dispose() {
    print("VideoPage -> dispose()");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "video",
      theme: Theme.of(context).copyWith(),
      home: Scaffold(
          appBar: null,
          body: Center(
            child: Text("video"),
          )
      ),
    );
  }
}