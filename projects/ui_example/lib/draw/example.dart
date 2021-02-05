import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:vector_math/vector_math_64.dart' as V;

class Sky extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {
  var rect = Offset.zero & size;
  var gradient = RadialGradient(
    center: const Alignment(0.7, -0.6),
    radius: 0.1,
    colors: [const Color(0xFFFFFF00), const Color(0xFF0099FF)],
    stops: [0.4, 1.0],
  );
  Path path = Path();
  path.addOval(Rect.fromCenter(center: Offset(50, 50), width: 100, height: 100));
  path.close();
 // Path nePath = path.transform(Matrix4.setOuter(V.Vector4(1,1,1,1), V.Vector4(1,1,1,1)).storage);
  canvas.drawPath(path,  Paint()..color = Colors.white..style = PaintingStyle.stroke);
 // canvas.drawPath(nePath,  Paint()..color = Colors.red..style = PaintingStyle.stroke);
  /*canvas.drawRect(
    rect,
    Paint()..shader = gradient.createShader(rect),
  );*/
}

@override
SemanticsBuilderCallback get semanticsBuilder {
  return (Size size) {
    // Annotate a rectangle containing the picture of the sun
    // with the label "Sun". When text to speech feature is enabled on the
    // device, a user will be able to locate the sun on this picture by
    // touch.
    var rect = Offset.zero & size;
    var width = size.shortestSide * 0.4;
    rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
    return [
      CustomPainterSemantics(
        rect: rect,
        properties: SemanticsProperties(
          label: 'Sun',
          textDirection: TextDirection.ltr,
        ),
      ),
    ];
  };
}

// Since this Sky painter has no fields, it always paints
// the same thing and semantics information is the same.
// Therefore we return false here. If we had fields (set
// from the constructor) then we would return true if any
// of them differed from the same fields on the oldDelegate.
@override
bool shouldRepaint(Sky oldDelegate) => false;
@override
bool shouldRebuildSemantics(Sky oldDelegate) => false;
}