import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_list/ui/views/video_indicator_impl.dart';
import 'package:video_list/utils/simple_utils.dart';
import 'package:video_player/video_player.dart';
//import 'package:flutter_xlider/flutter_xlider.dart';

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
    this.progressKey,
    this.minHeight = 1.8,
    this.bufferingSpeedMillisecond = _kBufferingSpeedMillisecond,
    this.bufferingMillisecond = _kBufferingMillisecond,
    this.positionPercent,
    this.smooth = false,
    this.stop = false,
    this.showSign = false,
    this.showSignHalo = false,
    this.showSignShade = false,
    this.signRadius,
    this.signOutRadius,
    this.signHaloRadius,
    this.signHaloAnimationDuration = const Duration(milliseconds: 200),
    this.allowScrubbing = false,
    this.padding = const EdgeInsets.only(top: 5.0),
  })  : assert(minHeight != null),
        assert(allowScrubbing != null),
        assert(controller != null),
        assert(smooth != null),
        assert(stop != null),
        assert(showSign != null),
        assert(showSignHalo != null),
        assert(showSignShade != null),
        assert(bufferingSpeedMillisecond != null),
        assert(bufferingMillisecond != null),
        assert(signHaloAnimationDuration != null),
        assert(signRadius == null || signRadius > 0),
        assert(signOutRadius == null || signOutRadius > 0),
        assert(signHaloRadius == null || signHaloRadius > 0),
        colors = colors ?? VideoProgressColors();

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  final GlobalKey progressKey;

  final int bufferingSpeedMillisecond;

  final int bufferingMillisecond;

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

  final double minHeight;

  final bool smooth;

  final bool stop;

  final double positionPercent;

  final bool showSign;

  final bool showSignHalo;

  final bool showSignShade;

  final Duration signHaloAnimationDuration;

  final double signRadius;

  final double signOutRadius;

  final double signHaloRadius;

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
    assert(value != null);
    if (bufferingValue == value) return;
    _bufferingValue = value;
    addBuildAfterCallback(() {
      notifyListeners();
    });
  }

  void changePositionValue(double value, {bool notify = true}) {
    assert(value != null);
    if (_positionValue == value) return;
    _positionValue = value;

    if (notify) {
      addBuildAfterCallback(() {
        notifyListeners();
      });
    }
  }
}

class _VideoProgressOwnerIndicatorState
    extends State<VideoProgressOwnerIndicator> with TickerProviderStateMixin {
  int _lastPosition;
  Duration _oldPosition;
  Tween<double> _progressTween;

  double _oldPositionPercent;

  _VideoProgressOwnerIndicatorState() {
    _listener = () {
      if (!mounted || controller.value.duration == null) {
        return;
      }

      //使用AnimationController不使用Timer的目的是和屏幕刷新保持一致
      if (widget.smooth && _progressDelayController == null) {
        _progressDelayController = AnimationController(
          duration: Duration(milliseconds: widget.bufferingMillisecond),
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

      if (!widget.smooth) {
        final int lastSecond = _oldPosition.inSeconds;
        final int currentSecond = controller.value.position.inSeconds;
        if (lastSecond != currentSecond) {
          _progressNotify.changePositionValue(
              currentSecond / controller.value.duration.inSeconds);
        }

        _oldPosition = controller.value.position;
        _lastPosition = position;
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
    //final double overflowValue = _kBufferingMillisecond * 0.5;
    if (controller.value.duration == null) return;

    final int duration = controller.value.duration.inMilliseconds;
    final int position = controller.value.position.inMilliseconds;
    int _endPosition = _lastPosition +
        widget.bufferingMillisecond +
        widget.bufferingSpeedMillisecond;
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
  }

  @override
  void didUpdateWidget(covariant VideoProgressOwnerIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stop) {
      _oldPositionPercent = widget.positionPercent;
    }

    if (oldWidget.stop != widget.stop) {
      if (widget.stop) {
        controller.removeListener(_listener);
      } else {
        final double oldPositionPercent = _oldPositionPercent;
        _oldPositionPercent = null;
        if (oldPositionPercent != null) {
          _progressNotify.changePositionValue(
            oldPositionPercent,
            notify: false,
          );
        }

        controller.removeListener(_listener);
        controller.addListener(_listener);
      }
    }
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
      duration: Duration(milliseconds: widget.bufferingSpeedMillisecond),
      vsync: this,
    );

    _progressAnimation =
        CurvedAnimation(parent: _progressController, curve: Curves.easeIn);
    _progressController.addListener(_onProgressChange);
    controller.addListener(_listener);
  }

  @override
  void dispose() {
    if (_progressDelayController != null) _progressDelayController.dispose();

    if (_progressController != null) _progressController.dispose();

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
              return LinearVideoProgressIndicator(
                value: bufferingValue,
                valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
                minHeight: widget.minHeight,
                showSign: widget.showSign,
                signColor: Colors.transparent,
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
              return LinearVideoProgressIndicator(
                key: widget.progressKey,
                value: widget.stop && widget.positionPercent != null
                    ? widget.positionPercent
                    : _progressNotify.positionValue,
                valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
                showSign: widget.showSign,
                showSignHalo: widget.showSignHalo,
                showSignShade: widget.showSignShade,
                signRadius: widget.signRadius,
                signOutRadius: widget.signOutRadius,
                signHaloRadius: widget.signHaloRadius,
                signHaloAnimationDuration: widget.signHaloAnimationDuration,
                minHeight: widget.minHeight,
                backgroundColor: Colors.transparent,
              );
            },
            selector: (BuildContext context, _ProgressNotify progressNotify) {
              //这个地方返回具体的值，对应builder中的data
              return progressNotify.positionValue;
            },
          ),
          /*Selector(
            builder:
                (BuildContext context, double positionValue, Widget child) {
              */ /*return LinearProgressIndicator(
                value: positionValue,
                valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
                minHeight: widget.minHeight,
                backgroundColor: Colors.transparent,
              );*/ /*
              return FlutterSlider(
                values: [positionValue],
                max: 1.0,
                min: 0,
                //maximumDistance: 300,
                //rangeSlider: true,
                //rtl: true,
                // handlerWidth: 10,
                handlerHeight: 12,
                trackBar: FlutterSliderTrackBar(
                  inactiveTrackBar: BoxDecoration(
                    //borderRadius: BorderRadius.circular(20),
                    color: Colors.black,
                    //border: Border.all(width: 3, color: Colors.blue),
                  ),
                  activeTrackBar: BoxDecoration(
                    //borderRadius: BorderRadius.circular(4),
                    color: colors.playedColor,
                  ),
                ),
                hatchMark: FlutterSliderHatchMark(
                  labelBox: FlutterSliderSizedBox(
                    width: double.maxFinite,
                    height: 10,
                  ),
                  labels: [
                    FlutterSliderHatchMarkLabel(
                      percent: 0,
                      label: Selector(
                        builder:
                            (BuildContext context, double bufferingValue, Widget child) {
                          return Container(
                            width: 200,
                            height: 5,
                            child: LinearProgressIndicator(
                              value: bufferingValue,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
                              minHeight: widget.minHeight,
                              backgroundColor: colors.backgroundColor,
                              //backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        selector: (BuildContext context, _ProgressNotify progressNotify) {
                          //这个地方返回具体的值，对应builder中的data
                          return progressNotify.bufferingValue;
                        },
                      ),
                    ),
                  ],
                ),
                handler: FlutterSliderHandler(
                  decoration: BoxDecoration(),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.playedColor.withAlpha(120),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 6.8,
                          height: 6.8,
                          decoration: BoxDecoration(
                            color: colors.playedColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                handlerAnimation: FlutterSliderHandlerAnimation(
                  curve: Curves.elasticOut,
                  reverseCurve: null,
                  duration: Duration(milliseconds: 700),
                  scale: 1.2,
                ),
                onDragging: (handlerIndex, lowerValue, upperValue) {},
              );
            },
            selector: (BuildContext context, _ProgressNotify progressNotify) {
              //这个地方返回具体的值，对应builder中的data
              return progressNotify.positionValue;
            },
          ),*/
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        minHeight: widget.minHeight,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );

    Widget child = paddedProgressIndicator;

    return ChangeNotifierProvider<_ProgressNotify>.value(
      value: _progressNotify,
      child: child,
    );
  }
}
