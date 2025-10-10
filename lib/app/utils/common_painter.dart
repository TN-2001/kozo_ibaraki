import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/utils/my_painter.dart';

class CommonPainter {
  // 座標系
  static void coordinate(Canvas canvas, {bool isEnableRotation = true}) {
    const double lineLength = 40;
    const double lineWidth = 3;
    const double headSize = 8;
    const Color arrowColor = Colors.black; 

    const Offset startPos = Offset(30, 60);
    final Offset topPos = Offset(startPos.dx, startPos.dy - lineLength);
    final Offset rightPos = Offset(startPos.dx + lineLength, startPos.dy);

    MyPainter.drawArrow2(
      canvas, startPos, topPos, 
      headSize: headSize, lineWidth: lineWidth, color: arrowColor
    );
    MyPainter.drawArrow2(
      canvas, startPos, rightPos, 
      headSize: headSize, lineWidth: lineWidth, color: arrowColor
    );

    if (isEnableRotation) {
      MyPainter.drawCircleArrow(
        canvas, startPos, lineLength / 3,
        headSize: headSize, lineWidth: lineWidth, 
        startAngle: - pi, 
        sweepAngle: pi * 1.5, 
        isCounterclockwise: true,
      );
    }

    MyPainter.text(canvas, topPos, "Y", 16, Colors.black, false, 1000, alignment: Alignment.bottomCenter);
    MyPainter.text(canvas, Offset(rightPos.dx + 5, rightPos.dy), "X", 16, Colors.black, false, 1000, alignment: Alignment.centerLeft);
    
    if (isEnableRotation) {
      MyPainter.text(canvas, (topPos + rightPos) / 2, "θ", 16, Colors.black, false, 1000, alignment: Alignment.center);
    }
  }
}