import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_list/utils/simple_utils.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:math' as Math;

const int _kBufferingMillisecond = 1200;
const int _kBufferingSpeedMillisecond = 200;

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
    addBuildAfterCallback(() {
      notifyListeners();
    });
  }

  void changePositionValue(double value) {
    if (_positionValue == value) return;
    _positionValue = value;
    addBuildAfterCallback(() {
      notifyListeners();
    });
  }
}

class _VideoProgressOwnerIndicatorState
    extends State<VideoProgressOwnerIndicator> with TickerProviderStateMixin {
  int _lastPosition;
  Duration _oldPosition;
  Tween<double> _progressTween;

  _VideoProgressOwnerIndicatorState() {
    _listener = () {
      if (!mounted || controller.value.duration == null) {
        return;
      }

      //使用AnimationController不使用Timer的目的是和屏幕刷新保持一致
      if (_progressDelayController == null) {
        _progressDelayController = AnimationController(
          duration: const Duration(milliseconds: _kBufferingMillisecond),
          vsync: this,
        )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _onProgressDelayAnimation();
            }
          })
          ..forward();
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
    };
  }

  VoidCallback _listener;

  _ProgressNotify _progressNotify = _ProgressNotify();

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  AnimationController _progressController;
  Animation _progressAnimation;

  AnimationController _progressDelayController;

  Tween<double> _constructTween(double beginValue, double endValue) {
    assert(beginValue != null);
    assert(endValue != null);
    return Tween<double>(begin: beginValue, end: endValue);
  }

  void _onProgressChange() {
    if (_progressTween == null) return;
    final double progressValue = _progressTween.evaluate(_progressAnimation);
    _progressNotify.changePositionValue(progressValue);
  }

  void _onProgressDelayAnimation() {
    print("_lastPosition - _lastPosition333: $_lastPosition");
    //final double overflowValue = _kBufferingMillisecond * 0.5;
    if (controller.value.duration == null)
      return;

    final int duration = controller.value.duration.inMilliseconds;
    final int position = controller.value.position.inMilliseconds;
    int _endPosition =
        _lastPosition + _kBufferingMillisecond + _kBufferingSpeedMillisecond;
    if (controller.value.duration == null ||
        controller.value.position <= Duration.zero ||
        position == _lastPosition) {
      _progressDelayController.forward(from: 0);
      return;
    }

    if (_endPosition > position) {
      _endPosition -= (_endPosition - position);
    }

    double beginValue, endValue;

    if (position == duration) {
      _progressDelayController.stop(canceled: true);

      beginValue = _lastPosition / duration;
      endValue = position / duration;
      _lastPosition = duration;
    } else {
      _progressDelayController.forward(from: 0);

      beginValue = _lastPosition / duration;
      endValue = _endPosition / duration;
      _lastPosition = _endPosition;
    }

    if (beginValue != null && endValue != null && beginValue != endValue) {
      _progressTween = _constructTween(beginValue, endValue);
      _progressController
        ..value = 0.0
        ..forward();
    }

    _oldPosition = controller.value.position;

    /*if ((_lastPosition - _oldPosition.inMilliseconds).abs() > overflowValue) {
      _lastPosition = _oldPosition.inMilliseconds;
    }*/
  }

  @override
  void initState() {
    super.initState();

    _lastPosition = controller.value?.position?.inMilliseconds ?? 0;
    _oldPosition = controller.value?.position ?? Duration.zero;

    if (_lastPosition > 0 && controller.value?.duration != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        assert(controller.value.duration != null);
        _progressNotify.changePositionValue(
            _lastPosition / controller.value.duration.inMilliseconds);
      });
    }

    _progressController = AnimationController(
      duration: const Duration(milliseconds: _kBufferingSpeedMillisecond),
      vsync: this,
    );

    _progressAnimation =
        CurvedAnimation(parent: _progressController, curve: Curves.easeIn);
    _progressController.addListener(_onProgressChange);
    controller.addListener(_listener);
  }

  @override
  void dispose() {
    _progressDelayController.dispose();
    _progressController.dispose();

    super.dispose();
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
        minHeight: 1.8,
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
