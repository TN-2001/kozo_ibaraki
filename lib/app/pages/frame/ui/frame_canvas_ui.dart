import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/frame/models/frame_controller.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'package:kozo_ibaraki/core/utils/my_painter.dart';

class FrameCanvasUi extends StatefulWidget {
  const FrameCanvasUi({super.key, required this.controller});

  final FrameController controller;

  @override
  State<FrameCanvasUi> createState() => _FrameCanvasUiState();
}

class _FrameCanvasUiState extends State<FrameCanvasUi> {
  late FrameController _controller;


  Widget landscapeColorContour() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                BaseText(
                  MyPainter.doubleToString(_controller.resultMax, 3),
                  isStroke: true,
                ),

                const SizedBox(height: MyDimens.baseSpacing,),

                Expanded(
                  child: Container(
                    height: double.infinity,
                    width: 30,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 255, 0, 0),
                          Color.fromARGB(255, 255, 255, 0),
                          Color.fromARGB(255, 0, 255, 0),
                          Color.fromARGB(255, 0, 255, 255),
                          Color.fromARGB(255, 0, 0, 255),
                        ]
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: MyDimens.baseSpacing,),

                BaseText(
                  MyPainter.doubleToString(_controller.resultMin, 3),
                  isStroke: true,
                ),
              ],
            ),

            const SizedBox(width: MyDimens.baseSpacing * 2,),
          ]
        ),
      ),
    );
  }

  Widget portraitColorContour() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                BaseText(
                  MyPainter.doubleToString(_controller.resultMax, 3),
                  isStroke: true,
                ),

                const SizedBox(width: MyDimens.baseSpacing,),

                Expanded(
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Color.fromARGB(255, 255, 0, 0),
                          Color.fromARGB(255, 255, 255, 0),
                          Color.fromARGB(255, 0, 255, 0),
                          Color.fromARGB(255, 0, 255, 255),
                          Color.fromARGB(255, 0, 0, 255),
                        ]
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: MyDimens.baseSpacing,),

                BaseText(
                  MyPainter.doubleToString(_controller.resultMin, 3),
                  isStroke: true,
                ),
              ],
            ),

            const SizedBox(height: MyDimens.baseSpacing * 2,),
          ]
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

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
              child: CustomPaint(painter: FrameCanvasPainter()),
            ),

            if (_controller.isCalculated && _controller.resultIndex <= 2)...{
              if (orientation == Orientation.landscape)...{
                landscapeColorContour(),
              }
              else...{
                portraitColorContour(),
              }
            }
          ],
        )
      ),
    );
  }
}

class FrameCanvasPainter extends CustomPainter {

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
      canvas, startPos, lineLength / 3,
      headSize: headSize, lineWidth: lineWidth, 
      startAngle: - pi, 
      sweepAngle: pi * 1.5, 
      isCounterclockwise: true,
    );

    MyPainter.text(canvas, topPos, "Y", 16, Colors.black, false, 1000, alignment: Alignment.bottomCenter);
    MyPainter.text(canvas, Offset(rightPos.dx + 5, rightPos.dy), "X", 16, Colors.black, false, 1000, alignment: Alignment.centerLeft);
    MyPainter.text(canvas, (topPos + rightPos) / 2, "θ", 16, Colors.black, false, 1000, alignment: Alignment.center);
  }

  @override
  bool shouldRepaint(covariant FrameCanvasPainter oldDelegate) {
    return false;
  }
}