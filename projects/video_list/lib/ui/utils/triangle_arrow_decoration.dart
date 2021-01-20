import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as Math;

typedef PerpendicularEquation = Point Function({double x, double y});

bool listEquals<T>(List<T> a, List<T> b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

enum TriangleArrowDirection {
  leftTop,
  leftCenter,
  leftBottom,

  rightTop,
  rightCenter,
  rightBottom,

  topLeft,
  topCenter,
  topRight,

  bottomLeft,
  bottomCenter,
  bottomRight,
}

class TriangleArrowDecoration extends Decoration {
  TriangleArrowDecoration({
    this.arrowWidth = 8,
    this.arrowHeight = 8,
    this.arrowOffset = 0,
    this.arrowBreadth = 0,
    this.arrowSmoothness = 0,
    this.triangleArrowDirection = TriangleArrowDirection.topRight,
    this.color,
    this.image,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
  })  : assert(borderRadius != null),
        assert(arrowOffset != null),
        assert(triangleArrowDirection != null),
        assert(arrowWidth != null),
        assert(arrowWidth >= 0),
        assert(arrowHeight != null),
        assert(arrowHeight >= 0),
        assert(arrowSmoothness != null),
        assert(arrowSmoothness >= 0),
        assert(arrowBreadth != null),
        assert(arrowBreadth >= 0),
        assert(border == null, "the border of box with 'TriangleArrowDecoration' is not implemented."),
        assert(
            backgroundBlendMode == null || color != null || gradient != null,
            "backgroundBlendMode applies to TriangleArrowDecoration's background color or "
            'gradient, but no color or gradient was provided.');

  final Color color;

  final DecorationImage image;

  final BoxBorder border;

  final BorderRadius borderRadius;

  final List<BoxShadow> boxShadow;

  final Gradient gradient;

  final BlendMode backgroundBlendMode;

  final double arrowWidth;

  final double arrowHeight;

  final double arrowOffset;

  final double arrowSmoothness;

  final double arrowBreadth;

  final TriangleArrowDirection triangleArrowDirection;

  @override
  EdgeInsetsGeometry get padding => border?.dimensions;

  TriangleArrowDecoration copyWith({
    Color color,
    DecorationImage image,
    BoxBorder border,
    BorderRadiusGeometry borderRadius,
    List<BoxShadow> boxShadow,
    Gradient gradient,
    BlendMode backgroundBlendMode,
    double arrowWidth,
    double arrowHeight,
    double arrowOffset,
    double arrowBreadth,
    double arrowSmoothness,
    TriangleArrowDirection triangleArrowDirection,
  }) {
    return TriangleArrowDecoration(
      color: color ?? this.color,
      image: image ?? this.image,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      gradient: gradient ?? this.gradient,
      backgroundBlendMode: backgroundBlendMode ?? this.backgroundBlendMode,
      arrowWidth: arrowWidth ?? this.arrowWidth,
      arrowHeight: arrowHeight ?? this.arrowHeight,
      arrowOffset: arrowOffset ?? this.arrowOffset,
      arrowBreadth: arrowBreadth ?? this.arrowBreadth,
      arrowSmoothness: arrowSmoothness ?? this.arrowSmoothness,
      triangleArrowDirection:
          triangleArrowDirection ?? this.triangleArrowDirection,
    );
  }

  @override
  TriangleArrowDecoration lerpFrom(Decoration a, double t) {
    if (a == null) return scale(t);
    if (a is TriangleArrowDecoration)
      return TriangleArrowDecoration.lerp(a, this, t);
    return super.lerpFrom(a, t) as TriangleArrowDecoration;
  }

  @override
  TriangleArrowDecoration lerpTo(Decoration b, double t) {
    if (b == null) return scale(1.0 - t);
    if (b is TriangleArrowDecoration)
      return TriangleArrowDecoration.lerp(this, b, t);
    return super.lerpTo(b, t) as TriangleArrowDecoration;
  }

  static TriangleArrowDecoration lerp(
      TriangleArrowDecoration a, TriangleArrowDecoration b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null) return b.scale(t);
    if (b == null) return a.scale(1.0 - t);
    if (t == 0.0) return a;
    if (t == 1.0) return b;
    return TriangleArrowDecoration(
      color: Color.lerp(a.color, b.color, t),
      image: t < 0.5 ? a.image : b.image, // TODO(ianh): cross-fade the image
      border: BoxBorder.lerp(a.border, b.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
      boxShadow: BoxShadow.lerpList(a.boxShadow, b.boxShadow, t),
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
      backgroundBlendMode:
          t < 0.5 ? a.backgroundBlendMode : b.backgroundBlendMode,
      triangleArrowDirection:
          t < 0.5 ? a.triangleArrowDirection : b.triangleArrowDirection,
      arrowWidth: a.arrowWidth + (b.arrowWidth - a.arrowWidth) * t,
      arrowHeight: a.arrowHeight + (b.arrowHeight - a.arrowHeight) * t,
      arrowOffset: a.arrowOffset + (b.arrowOffset - a.arrowOffset) * t,
      arrowBreadth: a.arrowBreadth + (b.arrowBreadth - a.arrowBreadth) * t,
      arrowSmoothness:
          a.arrowSmoothness + (b.arrowSmoothness - a.arrowSmoothness) * t,
    );
  }

  void assertValidArrowWidth(Rect rect) {
    assert(rect != null);
    assert(rect.size != null);
    return _assertValidArrowWidth(
        rect, arrowWidth, triangleArrowDirection, borderRadius);
  }

  static void _assertValidArrowWidth(
      Rect rect,
      double width,
      TriangleArrowDirection triangleArrowDirection,
      BorderRadius borderRadius) {
    assert(rect != null);
    assert(rect.size != null);
    assert(width != null);
    assert(width >= 0);
    assert(triangleArrowDirection != null);
    switch (triangleArrowDirection) {
      case TriangleArrowDirection.topLeft:
      case TriangleArrowDirection.topCenter:
      case TriangleArrowDirection.topRight:
        double accessWidth = rect.size.width;
        if (borderRadius != null) {
          accessWidth -= borderRadius.topLeft.x - borderRadius.topRight.x;
        }
        assert(width <= accessWidth);
        break;
      case TriangleArrowDirection.bottomLeft:
      case TriangleArrowDirection.bottomCenter:
      case TriangleArrowDirection.bottomRight:
        double accessWidth = rect.size.width;
        if (borderRadius != null) {
          accessWidth -= borderRadius.bottomLeft.x - borderRadius.bottomRight.x;
        }

        assert(width <= accessWidth);
        break;

      case TriangleArrowDirection.leftTop:
      case TriangleArrowDirection.leftCenter:
      case TriangleArrowDirection.leftBottom:
        double accessWidth = rect.size.height;
        if (borderRadius != null) {
          accessWidth -= borderRadius.topLeft.y - borderRadius.bottomLeft.y;
        }

        assert(width <= accessWidth);
        break;

      case TriangleArrowDirection.rightTop:
      case TriangleArrowDirection.rightCenter:
      case TriangleArrowDirection.rightBottom:
        double accessWidth = rect.size.height;
        if (borderRadius != null) {
          accessWidth -= borderRadius.topRight.y - borderRadius.bottomRight.y;
        }

        assert(width <= accessWidth);
        break;
    }
  }

  void assertValidArrowHeight(Rect rect) {
    assert(rect != null);
    assert(rect.size != null);
    _assertValidArrowHeight(
        rect, arrowHeight, triangleArrowDirection, borderRadius);
  }

  static void _assertValidArrowHeight(
      Rect rect,
      double height,
      TriangleArrowDirection triangleArrowDirection,
      BorderRadius borderRadius) {
    assert(rect != null);
    assert(rect.size != null);
    assert(height != null);
    assert(height >= 0);
    assert(triangleArrowDirection != null);
    switch (triangleArrowDirection) {
      case TriangleArrowDirection.topLeft:
      case TriangleArrowDirection.topCenter:
      case TriangleArrowDirection.topRight:
      case TriangleArrowDirection.bottomLeft:
      case TriangleArrowDirection.bottomCenter:
      case TriangleArrowDirection.bottomRight:
        double accessHeight = rect.size.height;
        if (borderRadius != null) {
          final double maxInvalidLength = Math.max(
              borderRadius.topLeft.y + borderRadius.bottomLeft.y,
              borderRadius.topRight.y + borderRadius.bottomRight.y);
          accessHeight -= maxInvalidLength;
        }

        assert(height < accessHeight);
        break;

      case TriangleArrowDirection.leftTop:
      case TriangleArrowDirection.leftCenter:
      case TriangleArrowDirection.leftBottom:
      case TriangleArrowDirection.rightTop:
      case TriangleArrowDirection.rightCenter:
      case TriangleArrowDirection.rightBottom:
        double accessHeight = rect.size.width;
        if (borderRadius != null) {
          final double maxInvalidLength = Math.max(
              borderRadius.topLeft.x + borderRadius.topRight.x,
              borderRadius.bottomLeft.x + borderRadius.bottomRight.x);
          accessHeight -= maxInvalidLength;
        }

        assert(height < accessHeight);
        break;
    }
  }

  RRect _getValidRRect(Rect rect, TextDirection textDirection) {
    assert(arrowHeight >= 0);
    assertValidArrowWidth(rect);
    assertValidArrowHeight(rect);

    Rect tmpRect = rect;

    switch (triangleArrowDirection) {
      case TriangleArrowDirection.topLeft:
      case TriangleArrowDirection.topCenter:
      case TriangleArrowDirection.topRight:
        tmpRect = Rect.fromLTRB(
            rect.left, rect.top + arrowHeight, rect.right, rect.bottom);
        break;
      case TriangleArrowDirection.bottomLeft:
      case TriangleArrowDirection.bottomCenter:
      case TriangleArrowDirection.bottomRight:
        tmpRect = Rect.fromLTRB(
            rect.left, rect.top, rect.right, rect.bottom - arrowHeight);
        break;

      case TriangleArrowDirection.leftTop:
      case TriangleArrowDirection.leftCenter:
      case TriangleArrowDirection.leftBottom:
        tmpRect = Rect.fromLTRB(
            rect.left + arrowHeight, rect.top, rect.right, rect.bottom);
        break;

      case TriangleArrowDirection.rightTop:
      case TriangleArrowDirection.rightCenter:
      case TriangleArrowDirection.rightBottom:
        tmpRect = Rect.fromLTRB(
            rect.left, rect.top, rect.right - arrowHeight, rect.bottom);
        break;
    }

    if (borderRadius != null)
      return borderRadius.resolve(textDirection).toRRect(tmpRect);

    return RRect.fromRectAndRadius(tmpRect, Radius.zero);
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRRect(_getValidRRect(rect, textDirection));
  }

  ///缩放无法对齐偏移值,暂时不对"arrowOffset"做逻辑处理,涉及到borderRadius/arrowWidth/arrowOffset/方向
  TriangleArrowDecoration scale(double factor) {
    return TriangleArrowDecoration(
      color: Color.lerp(null, color, factor),
      image: image, // TODO(ianh): fade the image from transparent
      border: BoxBorder.lerp(null, border, factor),
      borderRadius: BorderRadiusGeometry.lerp(null, borderRadius, factor),
      boxShadow: BoxShadow.lerpList(null, boxShadow, factor),
      gradient: gradient?.scale(factor),
      backgroundBlendMode: backgroundBlendMode,
      triangleArrowDirection: triangleArrowDirection,
      arrowHeight: arrowHeight * factor,
      arrowWidth: arrowWidth * factor,
      arrowBreadth: arrowBreadth * factor,
      arrowSmoothness: arrowSmoothness * factor,
      arrowOffset: arrowOffset,
    );
  }

  @override
  bool get isComplex => boxShadow != null;

  @override
  // TODO: implement hashCode
  int get hashCode {
    return hashValues(
      color,
      image,
      border,
      borderRadius,
      hashList(boxShadow),
      gradient,
      backgroundBlendMode,
      triangleArrowDirection,
      arrowHeight,
      arrowWidth,
      arrowOffset,
      arrowBreadth,
      arrowSmoothness,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TriangleArrowDecoration &&
        other.color == color &&
        other.image == image &&
        other.border == border &&
        other.borderRadius == borderRadius &&
        listEquals<BoxShadow>(other.boxShadow, boxShadow) &&
        other.gradient == gradient &&
        other.backgroundBlendMode == backgroundBlendMode &&
        other.triangleArrowDirection == triangleArrowDirection &&
        other.arrowHeight == arrowHeight &&
        other.arrowWidth == arrowWidth &&
        other.arrowOffset == arrowOffset &&
        other.arrowBreadth == arrowBreadth &&
        other.arrowSmoothness == arrowSmoothness;
  }

  @override
  bool hitTest(Size size, Offset position, {TextDirection textDirection}) {
    assert((Offset.zero & size).contains(position));
    final RRect bounds = _getValidRRect(Offset.zero & size, textDirection);
    return bounds.contains(position);
  }

  @override
  BoxPainter createBoxPainter([onChanged]) {
    assert(onChanged != null || image == null);
    return TriangleArrowPainter(this, onChanged);
  }
}

class TriangleArrowPainter extends BoxPainter {
  TriangleArrowPainter(this._decoration, VoidCallback onChanged)
      : assert(_decoration != null),
        super(onChanged);

  final TriangleArrowDecoration _decoration;

  Paint _cachedBackgroundPaint;
  Rect _rectForCachedBackgroundPaint;
  Paint _getBackgroundPaint(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(
        _decoration.gradient != null || _rectForCachedBackgroundPaint == null);

    if (_cachedBackgroundPaint == null ||
        (_decoration.gradient != null &&
            _rectForCachedBackgroundPaint != rect)) {
      final Paint paint = Paint();
      if (_decoration.backgroundBlendMode != null)
        paint.blendMode = _decoration.backgroundBlendMode;
      if (_decoration.color != null) paint.color = _decoration.color;
      if (_decoration.gradient != null) {
        paint.shader = _decoration.gradient
            .createShader(rect, textDirection: textDirection);
        _rectForCachedBackgroundPaint = rect;
      }
      _cachedBackgroundPaint = paint;
    }

    return _cachedBackgroundPaint;
  }

  Point _getCenterPoint(Point p1, Point p2) {
    assert(p1 != null);
    assert(p2 != null);
    return Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
  }

  PerpendicularEquation perpendicular(Point p1, Point p2) {
    assert(p1 != null);
    assert(p2 != null);
    final double pSlope = (p2.y - p1.y) / (p2.x - p1.x);
    final Point pM = _getCenterPoint(p1, p2);
    if (pSlope == double.infinity) {
      //斜率为无穷大，p与y轴平行;即y的垂直平分线l与x轴平行，即 l.y = pM.y
      return null;
    } else if (pSlope == 0) {
      //斜率为0, p与x轴平行;即y的垂直平分线l与y轴平行，即 l.x = pM.x
      return null;
    }

    //负倒数
    double _pSlope = (p2.x - p1.x) / (p2.y - p1.y) * -1;

    // y = _pSlope * x + b;
    double b = pM.y - _pSlope * pM.x;

    // 公式：y = _pSlope * x + b
    return ({double x, double y}) {
      assert((x == null && y != null) || (y == null && x != null));
      return x != null
          ? Point(x, _pSlope * x + b)
          : Point((y - b) / _pSlope, y);
    };
  }

  Point _getCenterControlPoint(Point p1, Point p2, {double offsetX, offsetY}) {
    assert(p1 != null);
    assert(p2 != null);
    assert((offsetX == null && offsetY != null) ||
        (offsetX != null && offsetY == null));

    final Point center = _getCenterPoint(p1, p2);
    final PerpendicularEquation equation = perpendicular(p1, p2);
    assert(equation != null);

    return equation(
        x: offsetX != null ? center.x + offsetX : null,
        y: offsetY != null ? center.y + offsetY : null);
  }

  Path _computerTriangleArrowPathWithDirection(
      {Rect rect,
      Point arrowCenterTop,
      Point arrowLeft,
      Point arrowRight,
      TextDirection textDirection}) {
    assert(rect != null);
    assert(arrowCenterTop != null);
    assert(arrowLeft != null);
    assert(arrowRight != null);
    assert(textDirection != null);

    final BorderRadius borderRadius =
        (_decoration.borderRadius ?? BorderRadius.zero).resolve(textDirection);

    switch (_decoration.triangleArrowDirection) {
      case TriangleArrowDirection.topLeft:
      case TriangleArrowDirection.topCenter:
      case TriangleArrowDirection.topRight:
        Path path = Path();
        path.moveTo(arrowLeft.x, arrowLeft.y);

        path.lineTo(rect.left + borderRadius.topLeft.x, arrowLeft.y);

        //左上
        path.quadraticBezierTo(rect.left, arrowLeft.y, rect.left,
            arrowLeft.y + borderRadius.topLeft.y);

        path.lineTo(rect.left, rect.bottom - borderRadius.bottomLeft.y);

        //左下
        path.quadraticBezierTo(rect.left, rect.bottom,
            rect.left + borderRadius.bottomLeft.x, rect.bottom);

        path.lineTo(rect.right - borderRadius.bottomRight.x, rect.bottom);

        //右下
        path.quadraticBezierTo(rect.right, rect.bottom, rect.right,
            rect.bottom - borderRadius.bottomRight.y);

        path.lineTo(rect.right, arrowRight.y + borderRadius.topRight.y);

        //右上
        path.quadraticBezierTo(rect.right, arrowRight.y,
            rect.right - borderRadius.topRight.x, arrowRight.y);

        path.lineTo(arrowRight.x, arrowRight.y);

        Point arrowCenterLeftTop = arrowCenterTop;
        Point arrowCenterRightTop = arrowCenterTop;

        if (_decoration.arrowSmoothness > 0) {
          arrowCenterLeftTop = Point(
              arrowCenterTop.x - _decoration.arrowSmoothness,
              arrowCenterTop.y + _decoration.arrowSmoothness);
          arrowCenterRightTop = Point(
              arrowCenterTop.x + _decoration.arrowSmoothness,
              arrowCenterTop.y + _decoration.arrowSmoothness);
        }

        Point rightControlPoint = _getCenterControlPoint(
            arrowRight, arrowCenterRightTop,
            offsetX: _decoration.arrowBreadth);
        path.quadraticBezierTo(rightControlPoint.x, rightControlPoint.y,
            arrowCenterRightTop.x, arrowCenterRightTop.y);

        if (_decoration.arrowSmoothness > 0)
          path.quadraticBezierTo(arrowCenterTop.x, arrowCenterTop.y,
              arrowCenterLeftTop.x, arrowCenterLeftTop.y);

        Point leftControlPoint = _getCenterControlPoint(
            arrowLeft, arrowCenterLeftTop,
            offsetX: -_decoration.arrowBreadth);
        path.quadraticBezierTo(
            leftControlPoint.x, leftControlPoint.y, arrowLeft.x, arrowLeft.y);

        path.close();
        return path;

      case TriangleArrowDirection.bottomLeft:
      case TriangleArrowDirection.bottomCenter:
      case TriangleArrowDirection.bottomRight:
        Path path = Path();
        path.moveTo(arrowLeft.x, arrowLeft.y);

        path.lineTo(rect.right - borderRadius.topLeft.x, arrowLeft.y);

        //左上
        path.quadraticBezierTo(rect.right, arrowLeft.y, rect.right,
            arrowLeft.y - borderRadius.topLeft.y);

        path.lineTo(rect.right, rect.top + borderRadius.topRight.y);

        //左下
        path.quadraticBezierTo(rect.right, rect.top,
            rect.right - borderRadius.bottomLeft.x, rect.top);

        path.lineTo(rect.left + borderRadius.bottomRight.x, rect.top);

        //右下
        path.quadraticBezierTo(rect.left, rect.top, rect.left,
            rect.top + borderRadius.bottomRight.y);

        path.lineTo(rect.left, arrowRight.y - borderRadius.topRight.y);

        //右上
        path.quadraticBezierTo(rect.left, arrowRight.y,
            rect.left + borderRadius.topRight.x, arrowRight.y);

        path.lineTo(arrowRight.x, arrowRight.y);

        Point arrowCenterLeftTop = arrowCenterTop;
        Point arrowCenterRightTop = arrowCenterTop;

        if (_decoration.arrowSmoothness > 0) {
          arrowCenterLeftTop = Point(
              arrowCenterTop.x + _decoration.arrowSmoothness,
              arrowCenterTop.y - _decoration.arrowSmoothness);
          arrowCenterRightTop = Point(
              arrowCenterTop.x - _decoration.arrowSmoothness,
              arrowCenterTop.y - _decoration.arrowSmoothness);
        }

        Point rightControlPoint = _getCenterControlPoint(
            arrowRight, arrowCenterRightTop,
            offsetX: -_decoration.arrowBreadth);
        path.quadraticBezierTo(rightControlPoint.x, rightControlPoint.y,
            arrowCenterRightTop.x, arrowCenterRightTop.y);

        if (_decoration.arrowSmoothness > 0)
          path.quadraticBezierTo(arrowCenterTop.x, arrowCenterTop.y,
              arrowCenterLeftTop.x, arrowCenterLeftTop.y);

        Point leftControlPoint = _getCenterControlPoint(
            arrowLeft, arrowCenterLeftTop,
            offsetX: _decoration.arrowBreadth);
        path.quadraticBezierTo(
            leftControlPoint.x, leftControlPoint.y, arrowLeft.x, arrowLeft.y);

        path.close();
        return path;

      case TriangleArrowDirection.leftTop:
      case TriangleArrowDirection.leftCenter:
      case TriangleArrowDirection.leftBottom:
        Path path = Path();
        path.moveTo(arrowLeft.x, arrowLeft.y);

        path.lineTo(arrowLeft.x, rect.bottom - borderRadius.topLeft.x);

        //左上
        path.quadraticBezierTo(arrowLeft.x, rect.bottom,
            arrowLeft.x + borderRadius.topLeft.y, rect.bottom);

        path.lineTo(rect.right - borderRadius.bottomLeft.y, rect.bottom);

        //左下
        path.quadraticBezierTo(rect.right, rect.bottom, rect.right,
            rect.bottom - borderRadius.bottomLeft.x);

        path.lineTo(rect.right, rect.top + borderRadius.bottomRight.x);

        //右下
        path.quadraticBezierTo(rect.right, rect.top,
            rect.right - borderRadius.bottomRight.y, rect.top);

        path.lineTo(arrowRight.x + borderRadius.topRight.y, rect.top);

        //右上
        path.quadraticBezierTo(arrowRight.x, rect.top, arrowRight.x,
            rect.top + borderRadius.topRight.x);

        path.lineTo(arrowRight.x, arrowRight.y);

        Point arrowCenterLeftTop = arrowCenterTop;
        Point arrowCenterRightTop = arrowCenterTop;

        if (_decoration.arrowSmoothness > 0) {
          arrowCenterLeftTop = Point(
              arrowCenterTop.x + _decoration.arrowSmoothness,
              arrowCenterTop.y + _decoration.arrowSmoothness);
          arrowCenterRightTop = Point(
              arrowCenterTop.x + _decoration.arrowSmoothness,
              arrowCenterTop.y - _decoration.arrowSmoothness);
        }

        Point rightControlPoint = _getCenterControlPoint(
            arrowRight, arrowCenterRightTop,
            offsetY: -_decoration.arrowBreadth);
        path.quadraticBezierTo(rightControlPoint.x, rightControlPoint.y,
            arrowCenterRightTop.x, arrowCenterRightTop.y);

        if (_decoration.arrowSmoothness > 0)
          path.quadraticBezierTo(arrowCenterTop.x, arrowCenterTop.y,
              arrowCenterLeftTop.x, arrowCenterLeftTop.y);

        Point leftControlPoint = _getCenterControlPoint(
            arrowLeft, arrowCenterLeftTop,
            offsetY: _decoration.arrowBreadth);
        path.quadraticBezierTo(
            leftControlPoint.x, leftControlPoint.y, arrowLeft.x, arrowLeft.y);

        path.close();
        return path;
      case TriangleArrowDirection.rightTop:
      case TriangleArrowDirection.rightCenter:
      case TriangleArrowDirection.rightBottom:
        Path path = Path();
        path.moveTo(arrowLeft.x, arrowLeft.y);

        path.lineTo(arrowLeft.x, rect.top + borderRadius.topLeft.x);

        //左上
        path.quadraticBezierTo(arrowLeft.x, rect.top,
            arrowLeft.x - borderRadius.topLeft.y, rect.top);

        path.lineTo(rect.left + borderRadius.bottomLeft.y, rect.top);

        //左下
        path.quadraticBezierTo(rect.left, rect.top, rect.left,
            rect.top + borderRadius.bottomLeft.x);

        path.lineTo(rect.left, rect.bottom - borderRadius.bottomRight.x);

        //右下
        path.quadraticBezierTo(rect.left, rect.bottom,
            rect.left + borderRadius.bottomRight.y, rect.bottom);

        path.lineTo(arrowRight.x - borderRadius.topRight.y, rect.bottom);

        //右上
        path.quadraticBezierTo(arrowRight.x, rect.bottom, arrowRight.x,
            rect.bottom - borderRadius.topRight.x);

        path.lineTo(arrowRight.x, arrowRight.y);

        Point arrowCenterLeftTop = arrowCenterTop;
        Point arrowCenterRightTop = arrowCenterTop;

        if (_decoration.arrowSmoothness > 0) {
          arrowCenterLeftTop = Point(
              arrowCenterTop.x - _decoration.arrowSmoothness,
              arrowCenterTop.y - _decoration.arrowSmoothness);
          arrowCenterRightTop = Point(
              arrowCenterTop.x - _decoration.arrowSmoothness,
              arrowCenterTop.y + _decoration.arrowSmoothness);
        }

        Point rightControlPoint = _getCenterControlPoint(
            arrowRight, arrowCenterRightTop,
            offsetY: _decoration.arrowBreadth);
        path.quadraticBezierTo(rightControlPoint.x, rightControlPoint.y,
            arrowCenterRightTop.x, arrowCenterRightTop.y);

        if (_decoration.arrowSmoothness > 0)
          path.quadraticBezierTo(arrowCenterTop.x, arrowCenterTop.y,
              arrowCenterLeftTop.x, arrowCenterLeftTop.y);

        Point leftControlPoint = _getCenterControlPoint(
            arrowLeft, arrowCenterLeftTop,
            offsetY: -_decoration.arrowBreadth);
        path.quadraticBezierTo(
            leftControlPoint.x, leftControlPoint.y, arrowLeft.x, arrowLeft.y);

        path.close();
        return path;
    }

    return null;
  }

  Path _computerTriangleArrowPath(Rect rect, TextDirection textDirection) {
    return _computerTriangleArrowPathWithDeflate(rect, 0, textDirection);
  }

  //暂不实现delta逻辑
  Path _computerTriangleArrowPathWithDeflate(Rect rect, double delta, TextDirection textDirection) {
    _decoration.assertValidArrowWidth(rect);
    _decoration.assertValidArrowHeight(rect);
    assert(textDirection != null);
    assert(_decoration.arrowSmoothness != null);
    assert(_decoration.arrowSmoothness >= 0);
    assert(_decoration.arrowBreadth != null);
    assert(_decoration.arrowBreadth >= 0);

    if (_decoration.arrowWidth <= 0 || _decoration.arrowHeight <= 0)
      return null;

    final BorderRadius borderRadius =
        (_decoration.borderRadius ?? BorderRadius.zero).resolve(textDirection);

    switch (_decoration.triangleArrowDirection) {
      case TriangleArrowDirection.topLeft:
        final Point arrowCenterTop = Point(
            rect.left +
                _decoration.arrowWidth / 2 +
                borderRadius.topLeft.x +
                _decoration.arrowOffset,
            rect.top);

        final Point arrowLeft = Point(
            arrowCenterTop.x - _decoration.arrowWidth / 2,
            rect.top + _decoration.arrowHeight);
        final Point arrowRight = Point(
            arrowCenterTop.x + _decoration.arrowWidth / 2,
            rect.top + _decoration.arrowHeight);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.topCenter:
        final double topLeftX =
            borderRadius.topLeft.y > 0 ? borderRadius.topLeft.x : 0;
        final double topRightX =
            borderRadius.topRight.y > 0 ? borderRadius.topRight.x : 0;
        final double centerX = rect.left +
            borderRadius.topLeft.x +
            (rect.width - topLeftX - topRightX) * 0.5 +
            _decoration.arrowOffset;

        final Point arrowCenterTop = Point(centerX, rect.top);

        final Point arrowLeft = Point(
            arrowCenterTop.x - _decoration.arrowWidth / 2,
            rect.top + _decoration.arrowHeight);
        final Point arrowRight = Point(
            arrowCenterTop.x + _decoration.arrowWidth / 2,
            rect.top + _decoration.arrowHeight);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.topRight:
        final Point arrowCenterTop = Point(
            rect.right -
                borderRadius.topRight.x -
                _decoration.arrowWidth / 2 -
                _decoration.arrowOffset,
            rect.top);

        final Point arrowLeft = Point(
            arrowCenterTop.x - _decoration.arrowWidth / 2,
            rect.top + _decoration.arrowHeight);
        final Point arrowRight = Point(
            arrowCenterTop.x + _decoration.arrowWidth / 2,
            rect.top + _decoration.arrowHeight);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.bottomLeft:
        final Point arrowCenterTop = Point(
            rect.left +
                borderRadius.bottomLeft.x +
                _decoration.arrowWidth / 2 +
                _decoration.arrowOffset,
            rect.bottom);

        final Point arrowLeft = Point(
            arrowCenterTop.x + _decoration.arrowWidth / 2,
            rect.bottom - _decoration.arrowHeight);
        final Point arrowRight = Point(
            arrowCenterTop.x - _decoration.arrowWidth / 2,
            rect.bottom - _decoration.arrowHeight);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);
      case TriangleArrowDirection.bottomCenter:
        final double topLeftX =
            borderRadius.topLeft.y > 0 ? borderRadius.topLeft.x : 0;
        final double topRightX =
            borderRadius.topRight.y > 0 ? borderRadius.topRight.x : 0;
        final double centerX = rect.right -
            borderRadius.topLeft.x -
            (rect.width - topLeftX - topRightX) * 0.5 -
            _decoration.arrowOffset;

        final Point arrowCenterTop = Point(centerX, rect.bottom);

        final Point arrowLeft = Point(
            arrowCenterTop.x + _decoration.arrowWidth / 2,
            rect.bottom - _decoration.arrowHeight);
        final Point arrowRight = Point(
            arrowCenterTop.x - _decoration.arrowWidth / 2,
            rect.bottom - _decoration.arrowHeight);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.bottomRight:
        final Point arrowCenterTop = Point(
            rect.right -
                borderRadius.bottomLeft.x -
                _decoration.arrowWidth / 2 -
                _decoration.arrowOffset,
            rect.bottom);

        final Point arrowLeft = Point(
            arrowCenterTop.x + _decoration.arrowWidth / 2,
            rect.bottom - _decoration.arrowHeight);
        final Point arrowRight = Point(
            arrowCenterTop.x - _decoration.arrowWidth / 2,
            rect.bottom - _decoration.arrowHeight);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.leftTop:
        final Point arrowCenterTop = Point(
            rect.left,
            rect.top +
                _decoration.arrowWidth / 2 +
                borderRadius.topRight.x +
                _decoration.arrowOffset);

        final Point arrowLeft = Point(rect.left + _decoration.arrowHeight,
            arrowCenterTop.y + _decoration.arrowWidth / 2);
        final Point arrowRight = Point(rect.left + _decoration.arrowHeight,
            arrowCenterTop.y - _decoration.arrowWidth / 2);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);
      case TriangleArrowDirection.leftCenter:
        final double topLeftX =
            borderRadius.topLeft.y > 0 ? borderRadius.topLeft.x : 0;
        final double topRightX =
            borderRadius.topRight.y > 0 ? borderRadius.topRight.x : 0;
        final double centerX = rect.bottom -
            borderRadius.topLeft.x -
            (rect.height - topLeftX - topRightX) * 0.5 -
            _decoration.arrowOffset;

        final Point arrowCenterTop = Point(rect.left, centerX);

        final Point arrowLeft = Point(
            arrowCenterTop.x + _decoration.arrowHeight,
            arrowCenterTop.y + _decoration.arrowWidth / 2);
        final Point arrowRight = Point(
            arrowCenterTop.x + _decoration.arrowHeight,
            arrowCenterTop.y - _decoration.arrowWidth / 2);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);
      case TriangleArrowDirection.leftBottom:
        final Point arrowCenterTop = Point(
            rect.left,
            rect.bottom -
                _decoration.arrowWidth / 2 -
                borderRadius.topLeft.x -
                _decoration.arrowOffset);

        final Point arrowLeft = Point(rect.left + _decoration.arrowHeight,
            arrowCenterTop.y + _decoration.arrowWidth / 2);
        final Point arrowRight = Point(rect.left + _decoration.arrowHeight,
            arrowCenterTop.y - _decoration.arrowWidth / 2);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.rightTop:
        final Point arrowCenterTop = Point(
            rect.right,
            rect.top +
                _decoration.arrowWidth / 2 +
                borderRadius.topLeft.x +
                _decoration.arrowOffset);

        final Point arrowLeft = Point(rect.right - _decoration.arrowHeight,
            arrowCenterTop.y - _decoration.arrowWidth / 2);
        final Point arrowRight = Point(rect.right - _decoration.arrowHeight,
            arrowCenterTop.y + _decoration.arrowWidth / 2);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.rightCenter:
        final double topLeftX =
            borderRadius.topLeft.y > 0 ? borderRadius.topLeft.x : 0;
        final double topRightX =
            borderRadius.topRight.y > 0 ? borderRadius.topRight.x : 0;
        final double centerX = rect.top +
            borderRadius.topLeft.x +
            (rect.height - topLeftX - topRightX) * 0.5 +
            _decoration.arrowOffset;

        final Point arrowCenterTop = Point(rect.right, centerX);

        final Point arrowLeft = Point(
            arrowCenterTop.x - _decoration.arrowHeight,
            arrowCenterTop.y - _decoration.arrowWidth / 2);
        final Point arrowRight = Point(
            arrowCenterTop.x - _decoration.arrowHeight,
            arrowCenterTop.y + _decoration.arrowWidth / 2);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);

      case TriangleArrowDirection.rightBottom:
        final Point arrowCenterTop = Point(
            rect.right,
            rect.bottom -
                _decoration.arrowWidth / 2 -
                borderRadius.topLeft.x -
                _decoration.arrowOffset);

        final Point arrowLeft = Point(rect.right - _decoration.arrowHeight,
            arrowCenterTop.y - _decoration.arrowWidth / 2);
        final Point arrowRight = Point(rect.right - _decoration.arrowHeight,
            arrowCenterTop.y + _decoration.arrowWidth / 2);

        return _computerTriangleArrowPathWithDirection(
            rect: rect,
            arrowCenterTop: arrowCenterTop,
            arrowLeft: arrowLeft,
            arrowRight: arrowRight,
            textDirection: textDirection);
    }

    return null;
  }

  void _paintBox(
      Canvas canvas, Rect rect, Paint paint, TextDirection textDirection) {
    final Path triangleArrowPath =
        _computerTriangleArrowPath(rect, textDirection);
    final RRect validRect = _decoration._getValidRRect(rect, textDirection);
    if (triangleArrowPath != null) {
      canvas.drawPath(triangleArrowPath, paint);
    } else {
      canvas.drawRRect(validRect, paint);
    }
  }

  void _paintShadows(Canvas canvas, Rect rect, TextDirection textDirection) {
    if (_decoration.boxShadow == null) return;
    for (final BoxShadow boxShadow in _decoration.boxShadow) {
      final Paint paint = boxShadow.toPaint();
      final Rect bounds =
          rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      _paintBox(canvas, bounds, paint, textDirection);
    }
  }

  void _paintBackgroundColor(
      Canvas canvas, Rect rect, TextDirection textDirection) {
    if (_decoration.color != null || _decoration.gradient != null)
      _paintBox(canvas, rect, _getBackgroundPaint(rect, textDirection),
          textDirection);
  }

  DecorationImagePainter _imagePainter;
  void _paintBackgroundImage(
      Canvas canvas, Rect rect, ImageConfiguration configuration) {
    if (_decoration.image == null) return;
    _imagePainter ??= _decoration.image.createPainter(onChanged);
    final Path clipPath =
        _computerTriangleArrowPath(rect, configuration.textDirection);
    assert(clipPath != null);
    _imagePainter.paint(canvas, rect, clipPath, configuration);
  }

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }

  //边框暂时不实现,比较复杂,等有需求再弄
  void _paintBorder(Canvas canvas, Rect rect, textDirection) {
    assert(canvas != null);
    assert(rect != null);
    assert(textDirection != null);
    assert(_decoration.border != null);
    final Border border = _decoration.border;
    if (border.isUniform) {
      switch (border.top.style) {
        case BorderStyle.none:
          return;
        case BorderStyle.solid:
          final Paint paint = Paint()
            ..color = border.top.color;
          final Path outer = _computerTriangleArrowPath(rect, textDirection);
          final double width = border.top.width;
          if (width == 0.0) {
            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.0;
            canvas.drawPath(outer, paint);
          } else {
            final Path inner = _computerTriangleArrowPathWithDeflate(rect, width, textDirection);
            assert(inner != null);
            canvas.drawPath(outer, paint);
            canvas.drawPath(inner, paint);
          }
          return;
      }
    }
  }

  /// Paint the box decoration into the given location on the given canvas.
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;
    _paintShadows(canvas, rect, textDirection);
    _paintBackgroundColor(canvas, rect, textDirection);
    _paintBackgroundImage(canvas, rect, configuration);

    //if (_decoration.border != null)
      //_paintBorder(canvas, rect, configuration.textDirection);
  }

  @override
  String toString() {
    return 'TriangleArrowPainter for $_decoration';
  }
}

