import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/utils/common_painter.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

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
    // 座標系
    CommonPainter.drawCoordinate(canvas);
  }

  @override
  bool shouldRepaint(covariant BeamCanvasPainter oldDelegate) {
    return false;
  }
}