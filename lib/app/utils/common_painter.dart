import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/utils/canvas_utils.dart';

class CommonPainter {
  // 座標系
  static void drawCoordinate(Canvas canvas, {bool isEnableRotation = true}) {
    const double lineLength = 40;
    const double lineWidth = 3;
    const double headSize = 8;
    const Color arrowColor = Colors.black; 

    const Offset startPos = Offset(30, 60);
    final Offset topPos = Offset(startPos.dx, startPos.dy - lineLength);
    final Offset rightPos = Offset(startPos.dx + lineLength, startPos.dy);

    CanvasUtils.drawArrow2(
      canvas, startPos, topPos, 
      headSize: headSize, lineWidth: lineWidth, color: arrowColor
    );
    CanvasUtils.drawArrow2(
      canvas, startPos, rightPos, 
      headSize: headSize, lineWidth: lineWidth, color: arrowColor
    );

    if (isEnableRotation) {
      CanvasUtils.drawCircleArrow(
        canvas, startPos, lineLength / 3,
        headSize: headSize, lineWidth: lineWidth, 
        startAngle: - pi, 
        sweepAngle: pi * 1.5, 
        isCounterclockwise: true,
      );
    }

    CanvasUtils.text(canvas, topPos, "Y", 16, Colors.black, false, 1000, alignment: Alignment.bottomCenter);
    CanvasUtils.text(canvas, Offset(rightPos.dx + 5, rightPos.dy), "X", 16, Colors.black, false, 1000, alignment: Alignment.centerLeft);
    
    if (isEnableRotation) {
      CanvasUtils.text(canvas, (topPos + rightPos) / 2, "θ", 16, Colors.black, false, 1000, alignment: Alignment.center);
    }
  }

  // 丸支点
  static void drawCircleConst(Canvas canvas, Offset pos, 
    {double size = 10, double padding = 0, double angle = 0.0, bool isLine = true}) {

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    canvas.translate(0, padding);

    final double radius = size / 2;
    final double lineSize = size * 2;
    Color color = Colors.black;

    Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(0, radius), radius, circlePaint);

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(0, radius), radius, paint);

    if (isLine) {
      canvas.drawLine(
        Offset(- lineSize / 2, radius * 2),
        Offset(  lineSize / 2, radius * 2),
        paint,
      );
    }
    
    canvas.restore();
  }
}