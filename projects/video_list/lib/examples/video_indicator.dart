import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoProgressOwnerIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  VideoProgressOwnerIndicator(
    this.controller, {
    VideoProgressColors colors,
    this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  }) : colors = colors ?? VideoProgressColors();

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  _VideoProgressOwnerIndicatorState createState() =>
      _VideoProgressOwnerIndicatorState();
}

class _ProgressNotify extends ChangeNotifier {
  double _bufferingValue;
  double _positionValue;

  double get bufferingValue => _bufferingValue;
  double get positionValue => _positionValue;

  _ProgressNotify({double bufferingValue = 0, double positionValue = 0})
      : assert(bufferingValue != null),
        assert(positionValue != null),
        _bufferingValue = bufferingValue,
        _positionValue = positionValue;

  void changeBufferingValue(double value) {
    if (bufferingValue == value) return;
    _bufferingValue = value;
    notifyListeners();
  }

  void changePositionValue(double value) {
    if (_positionValue == value) return;
    _positionValue = value;
    notifyListeners();
  }
}

class _VideoProgressOwnerIndicatorState
    extends State<VideoProgressOwnerIndicator> {
  _VideoProgressOwnerIndicatorState() {
    _listener = () {
      if (!mounted) {
        return;
      }

      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      _progressNotify.changeBufferingValue(maxBuffering / duration);
      _progressNotify.changePositionValue(position / duration);
    };
  }

  VoidCallback _listener;

  _ProgressNotify _progressNotify = _ProgressNotify();

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(_listener);
  }

  @override
  void deactivate() {
    controller.removeListener(_listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.initialized) {
      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Selector(
            builder:
                (BuildContext context, double bufferingValue, Widget child) {
              return LinearProgressIndicator(
                value: bufferingValue,
                valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
                minHeight: 1.8,
                backgroundColor: colors.backgroundColor,
                //backgroundColor: Colors.blue,
              );
            },
            selector: (BuildContext context, _ProgressNotify progressNotify) {
              //这个地方返回具体的值，对应builder中的data
              return progressNotify.bufferingValue;
            },
          ),
          Selector(
            builder:
                (BuildContext context, double positionValue, Widget child) {
              return LinearProgressIndicator(
                value: positionValue,
                valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
                minHeight: 1.8,
                backgroundColor: Colors.transparent,
              );
            },
            selector: (BuildContext context, _ProgressNotify progressNotify) {
              //这个地方返回具体的值，对应builder中的data
              return progressNotify.positionValue;
            },
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );

    Widget child;

    if (widget.allowScrubbing) {
      child = _VideoScrubber(
        child: paddedProgressIndicator,
        controller: controller,
      );
    } else {
      child = paddedProgressIndicator;
    }

    return ChangeNotifierProvider<_ProgressNotify>.value(
      value: _progressNotify,
      child: child,
    );
  }
}

class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    @required this.child,
    @required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}
