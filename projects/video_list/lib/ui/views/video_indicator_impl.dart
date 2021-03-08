import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const int _kIndeterminateLinearDuration = 1800;

class LinearVideoProgressIndicator extends ProgressIndicator {
  /// Creates a linear progress indicator.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const LinearVideoProgressIndicator({
    Key key,
    double value,
    Color backgroundColor,
    Animation<Color> valueColor,
    bool isShowMark = false,
    bool isShowHalo = false,
    this.minHeight,
    this.radius,
    String semanticsLabel,
    String semanticsValue,
  })  : assert(minHeight == null || minHeight > 0),
        assert(isShowMark != null),
        assert(isShowHalo != null),
        super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  /// The minimum height of the line used to draw the indicator.
  ///
  /// This defaults to 4dp.
  final double minHeight;

  final Radius radius;

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ?? Theme.of(context).backgroundColor;
  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).accentColor;

  Widget _buildSemanticsWrapper({
    BuildContext context,
    Widget child,
  }) {
    String expandedSemanticsValue = semanticsValue;
    if (value != null) {
      expandedSemanticsValue ??= '${(value * 100).round()}%';
    }
    return Semantics(
      label: semanticsLabel,
      value: expandedSemanticsValue,
      child: child,
    );
  }

  @override
  _LinearVideoProgressIndicatorState createState() =>
      _LinearVideoProgressIndicatorState();
}

class _LinearVideoProgressIndicatorState
    extends State<LinearVideoProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(LinearVideoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context, double animationValue,
      TextDirection textDirection) {

    return widget._buildSemanticsWrapper(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          minHeight: widget.minHeight ?? 4.0,
        ),
        child: CustomPaint(
          painter: _LinearVideoProgressIndicatorPainter(
            radius: widget.radius,
            backgroundColor: widget._getBackgroundColor(context),
            valueColor: widget._getValueColor(context),
            value: widget.value, // may be null
            animationValue:
            animationValue, // ignored if widget.value is not null
            textDirection: textDirection,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (widget.value != null)
      return _buildIndicator(context, _controller.value, textDirection);

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget child) {
        return _buildIndicator(context, _controller.value, textDirection);
      },
    );
  }
}

class _LinearVideoProgressIndicatorPainter extends CustomPainter {
  const _LinearVideoProgressIndicatorPainter({
    this.radius,
    this.backgroundColor,
    this.valueColor,
    this.value,
    this.animationValue,
    this.textDirection,
  }) : assert(textDirection != null);

  final Radius radius;
  final Color backgroundColor;
  final Color valueColor;
  final double value;
  final double animationValue;
  final TextDirection textDirection;

  // The indeterminate progress animation displays two lines whose leading (head)
  // and trailing (tail) endpoints are defined by the following four curves.
  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    if (radius == null) {
      canvas.drawRect(Offset.zero & size, paint);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, radius), paint);
    }

    paint.color = valueColor;

    void drawBar(double x, double width) {
      if (width <= 0.0) return;

      double left;
      switch (textDirection) {
        case TextDirection.rtl:
          left = size.width - width - x;
          break;
        case TextDirection.ltr:
          left = x;
          break;
      }

      if (radius == null) {
        canvas.drawRect(Offset(left, 0.0) & Size(width, size.height), paint);
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(Offset(left, 0.0) & Size(width, size.height), radius), paint);
      }
    }

    if (value != null) {
      drawBar(0.0, value.clamp(0.0, 1.0) * size.width);
    } else {
      final double x1 = size.width * line1Tail.transform(animationValue);
      final double width1 =
          size.width * line1Head.transform(animationValue) - x1;

      final double x2 = size.width * line2Tail.transform(animationValue);
      final double width2 =
          size.width * line2Head.transform(animationValue) - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
    }
  }

  @override
  bool shouldRepaint(_LinearVideoProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.animationValue != animationValue ||
        oldPainter.textDirection != textDirection;
  }
}
