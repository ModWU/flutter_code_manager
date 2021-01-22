import 'package:flutter/material.dart';
import 'dart:ui' as ui show TextHeightBehavior;

class AnimatedDefaultIconTextStyle extends ImplicitlyAnimatedWidget {
  const AnimatedDefaultIconTextStyle({
    Key key,
    this.child,
    this.style,
    this.iconTheme,
    this.textAlign,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    Curve curve = Curves.linear,
    Duration duration,
    VoidCallback onEnd,
  })  : assert(style != null || iconTheme != null),
        assert(child != null),
        assert(softWrap != null),
        assert(overflow != null),
        assert(maxLines == null || maxLines > 0),
        assert(textWidthBasis != null),
        super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final Widget child;

  final TextStyle style;

  final IconThemeData iconTheme;

  final TextAlign textAlign;

  final bool softWrap;

  final TextOverflow overflow;

  final int maxLines;

  final TextWidthBasis textWidthBasis;

  final ui.TextHeightBehavior textHeightBehavior;

  @override
  _AnimatedDefaultIconTextStyleState createState() =>
      _AnimatedDefaultIconTextStyleState();
}

class IconThemeTween extends Tween<IconThemeData> {
  /// Creates a text style tween.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  IconThemeTween({IconThemeData begin, IconThemeData end})
      : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  IconThemeData lerp(double t) => IconThemeData.lerp(begin, end, t);
}

class _AnimatedDefaultIconTextStyleState
    extends AnimatedWidgetBaseState<AnimatedDefaultIconTextStyle> {
  TextStyleTween _style;
  IconThemeTween _iconTheme;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    if (widget.style != null) {
      _style = visitor(_style, widget.style,
              (dynamic value) => TextStyleTween(begin: value as TextStyle))
          as TextStyleTween;
    }

    if (widget.iconTheme != null) {
      _iconTheme = visitor(_iconTheme, widget.iconTheme,
              (dynamic value) => IconThemeTween(begin: value as IconThemeData))
          as IconThemeTween;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context) ?? ThemeData();

    Widget child = widget.child;

    if (_style != null) {
      child = DefaultTextStyle(
        style: _style.evaluate(animation),
        textAlign: widget.textAlign,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        child: child,
      );
    }

    if (_iconTheme != null) {
      child = Theme(
        data: themeData.copyWith(
          iconTheme: _iconTheme.evaluate(animation),
        ),
        child: child,
      );
    }

    return child;
  }
}
