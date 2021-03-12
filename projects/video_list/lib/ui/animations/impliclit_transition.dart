import 'package:flutter/material.dart';
import 'dart:ui' as ui show TextHeightBehavior;

class AnimatedTranslation extends ImplicitlyAnimatedWidget {
  const AnimatedTranslation({
    Key key,
    this.child,
    this.position = Offset.zero,
    this.opacity = 1.0,
    this.hideOpacityAnimation = false,
    this.transformHitTests = true,
    this.textDirection,
    Curve curve = Curves.linear,
    Duration duration,
    VoidCallback onEnd,
  })  : assert(child != null),
        assert(position != null),
        assert(opacity != null),
        assert(hideOpacityAnimation != null),
        super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final Widget child;

  final Offset position;

  final double opacity;

  final TextDirection textDirection;

  final bool transformHitTests;

  final bool hideOpacityAnimation;

  @override
  _AnimatedTranslationState createState() => _AnimatedTranslationState();
}

class _AnimatedTranslationState
    extends AnimatedWidgetBaseState<AnimatedTranslation> {
  Tween<Offset> _positionTween;

  Tween<double> _opacityTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    if (widget.position != null) {
      _positionTween = visitor(_positionTween, widget.position,
              (dynamic value) => Tween<Offset>(begin: value as Offset))
          as Tween<Offset>;
    }

    if (widget.opacity != null) {
      _opacityTween = visitor(_opacityTween, widget.opacity,
              (dynamic value) => Tween<double>(begin: value as double))
      as Tween<double>;
    }
  }

  @override
  Widget build(BuildContext context) {
    Offset position = _positionTween.evaluate(animation);
    if (widget.textDirection == TextDirection.rtl)
      position = Offset(-position.dx, position.dy);
    return Opacity(
      opacity: widget.hideOpacityAnimation ? _opacityTween.end : _opacityTween.evaluate(animation),
      child: FractionalTranslation(
        translation: position,
        transformHitTests: widget.transformHitTests,
        child: widget.child,
      ),
    );
  }
}
