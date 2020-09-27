import 'package:flutter/material.dart';

class LiveStreamingPage extends StatefulWidget {

  const LiveStreamingPage();

  @override
  State<StatefulWidget> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> {

  @override
  void initState() {
    print("LiveStreamingPage -> initState()");
    super.initState();
  }

  @override
  void dispose() {
    print("LiveStreamingPage -> dispose()");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "live_streaming",
      theme: Theme.of(context).copyWith(),
      home: Scaffold(
          appBar: null,
          body: Center(
            child: Text("live_streaming"),
          )
      ),
    );
  }
}