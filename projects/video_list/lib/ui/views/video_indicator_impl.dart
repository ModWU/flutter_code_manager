import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const int _kIndeterminateLinearDuration = 1800;
const int _kIndeterminateSignHaloDuration = 200;

class LinearVideoProgressIndicator extends ProgressIndicator {
  /// Creates a linear progress indicator.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const LinearVideoProgressIndicator({
    Key key,
    double value,
    Color backgroundColor,
    Animation<Color> valueColor,
    this.showSign = false,
    this.showSignHalo = false,
    this.signRadius,
    this.signOutRadius,
    this.signHaloRadius,
    this.showSignShade = false,
    this.signHaloAnimationDuration =
        const Duration(milliseconds: _kIndeterminateSignHaloDuration),
    this.signColor,
    this.minHeight,
    this.radius,
    String semanticsLabel,
    String semanticsValue,
  })  : assert(minHeight == null || minHeight > 0),
        assert(showSign != null),
        assert(signHaloAnimationDuration != null),
        assert(signRadius == null || signRadius > 0),
        assert(signOutRadius == null || signOutRadius > 0),
        assert(signHaloRadius == null || signHaloRadius > 0),
        assert(showSignHalo != null),
        assert(showSignShade != null),
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

  final bool showSign;

  final bool showSignHalo;

  final Duration signHaloAnimationDuration;

  final Color signColor;

  final bool showSignShade;

  final double signRadius;

  final double signOutRadius;

  final double signHaloRadius;

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
    extends State<LinearVideoProgressIndicator> with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _signHaloController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();

    _tryCreateSignHaloController();
  }

  void _tryCreateSignHaloController() {
    if (_signHaloController != null) {
      _signHaloController.stop();
      _signHaloController.dispose();
      _signHaloController = null;
    }

    if (!widget.showSign || !widget.showSignHalo) {
      return;
    }

    _signHaloController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: widget.signHaloAnimationDuration,
      vsync: this,
    );
    if (widget.value != null) _signHaloController.forward();
  }

  bool _showSignHalo(LinearVideoProgressIndicator widget) {
    assert(widget != null);
    return widget.showSign && widget.showSignHalo;
  }

  @override
  void didUpdateWidget(LinearVideoProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();

    if (_showSignHalo(widget) != _showSignHalo(oldWidget)) {
      _tryCreateSignHaloController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_signHaloController != null) _signHaloController.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context, double animationValue,
      TextDirection textDirection) {
    final Widget widgetChild = CustomPaint(
      painter: _LinearVideoProgressIndicatorPainter(
        radius: widget.radius,
        backgroundColor: widget._getBackgroundColor(context),
        valueColor: widget._getValueColor(context),
        value: widget.value, // may be null
        showSign: widget.showSign,
        showSignHalo: widget.showSignHalo,
        showSignShade: widget.showSignShade,
        signRadius: widget.signRadius,
        signOutRadius: widget.signOutRadius,
        signHaloRadius: widget.signHaloRadius,
        signColor: widget.signColor,
        animationValue: animationValue, // ignored if widget.value is not null
        animationSignHaloValue: _signHaloController
            ?.value, // ignored if _signHaloController?.value is not null
        textDirection: textDirection,
      ),
    );
    return widget._buildSemanticsWrapper(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          minHeight: widget.minHeight ?? 4.0,
        ),
        child: _showSignHalo(widget)
            ? AnimatedBuilder(
                animation: _signHaloController.view,
                builder: (BuildContext context, Widget child) {
                  return widgetChild;
                },
              )
            : widgetChild,
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
    this.animationSignHaloValue,
    this.textDirection,
    this.showSign = false,
    this.showSignHalo = false,
    this.signColor,
    this.showSignShade = false,
    this.signRadius,
    this.signOutRadius,
    this.signHaloRadius,
  })  : assert(textDirection != null),
        assert(showSign != null),
        assert(showSignShade != null),
        assert(showSignHalo != null),
        assert(signRadius == null || signRadius > 0),
        assert(signOutRadius == null || signOutRadius > 0),
        assert(signHaloRadius == null || signHaloRadius > 0);

  final Radius radius;
  final Color backgroundColor;
  final Color valueColor;
  final double value;
  final double animationValue;
  final double animationSignHaloValue;
  final TextDirection textDirection;
  final bool showSign;
  final bool showSignHalo;
  final Color signColor;
  final bool showSignShade;
  final double signRadius;
  final double signOutRadius;
  final double signHaloRadius;

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

    final double signRadius =
        !showSign ? 0 : (this.signRadius ?? size.height * 1.8);
    final double signOutRadius =
        !showSign ? 0 : (this.signOutRadius ?? size.height * 3.2);
    final double signHaloRadius =
        !showSign ? 0 : (this.signHaloRadius ?? size.height * 14.0);
    final Offset startOffset = Offset(signRadius, 0);
    final Size startSize = size - Offset(signRadius * 2, 0);

    if (radius == null) {
      canvas.drawRect(startOffset & startSize, paint);
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(startOffset & startSize, radius), paint);
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
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Offset(left, 0.0) & Size(width, size.height), radius),
            paint);
      }
    }

    if (value != null) {
      final double progressSize = value.clamp(0.0, 1.0) * startSize.width;
      drawBar(signRadius, progressSize);
      final Color _signColor = signColor ?? valueColor;
      if (showSign && _signColor.alpha != 0) {
        final Paint signPaint = Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.fill;
        if (showSignHalo) {
          assert(animationSignHaloValue != null);
          canvas.drawCircle(
            Offset(signRadius + progressSize, size.height / 2),
            signHaloRadius * Curves.easeIn.transform(animationSignHaloValue),
            signPaint..color = _signColor.withOpacity(0.2),
          );
        }

        if (showSignShade) {
          canvas.drawCircle(
            Offset(signRadius + progressSize, size.height / 2),
            signOutRadius,
            signPaint..color = _signColor.withOpacity(0.3),
          );
        }
        canvas.drawCircle(Offset(signRadius + progressSize, size.height / 2),
            signRadius, signPaint..color = _signColor);
      }
    } else {
      final double x1 =
          startSize.width * line1Tail.transform(animationValue) + signRadius;
      final double width1 =
          startSize.width * line1Head.transform(animationValue) - x1;

      final double x2 =
          startSize.width * line2Tail.transform(animationValue) + signRadius;
      final double width2 =
          startSize.width * line2Head.transform(animationValue) - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
    }
  }

  @override
  bool shouldRepaint(_LinearVideoProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.radius != radius ||
        oldPainter.showSign != showSign ||
        oldPainter.showSignShade != showSignShade ||
        oldPainter.signRadius != signRadius ||
        oldPainter.signOutRadius != signOutRadius ||
        oldPainter.signHaloRadius != signHaloRadius ||
        oldPainter.animationSignHaloValue != animationSignHaloValue ||
        oldPainter.animationValue != animationValue ||
        oldPainter.textDirection != textDirection;
  }
}
