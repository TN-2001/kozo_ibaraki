import 'dart:math';

import 'package:flutter/material.dart';

import '../../../constants/constant.dart';
import '../../../utils/my_painter.dart';

class BeamCanvasUi extends StatefulWidget {
  const BeamCanvasUi({super.key});

  @override
  State<BeamCanvasUi> createState() => _BeamCanvasUiState();
}

class _BeamCanvasUiState extends State<BeamCanvasUi> {
  @override
  Widget build(BuildContext context) {
    // final orientation = MediaQuery.of(context).orientation;

    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(MyDimens.baseSpacing * 2),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(painter: BeamCanvasPainter()),
            ),

            // if (_controller.isCalculation && _controller.resultIndex <= 2)...{
            //   if (orientation == Orientation.landscape)...{
            //     landscapeColorContour(),
            //   }
            //   else...{
            //     portraitColorContour(),
            //   }
            // }
          ],
        )
      ),
    );
  }
}

class BeamCanvasPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
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

    MyPainter.drawCircleArrow(
      canvas, startPos, lineLength,
      headSize: headSize, lineWidth: lineWidth, 
      startAngle: - pi / 2 + pi * 0.1, 
      sweepAngle: pi / 2 - pi * 0.15, 
      isCounterclockwise: true,
    );

    MyPainter.text(canvas, topPos, "Y", 16, Colors.black, false, 1000, alignment: Alignment.bottomCenter);
    MyPainter.text(canvas, Offset(rightPos.dx + 5, rightPos.dy), "X", 16, Colors.black, false, 1000, alignment: Alignment.centerLeft);
  }

  @override
  bool shouldRepaint(covariant BeamCanvasPainter oldDelegate) {
    return false;
  }
}