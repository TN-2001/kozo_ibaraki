import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/utils/common_painter.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class FemCanvasUi extends StatefulWidget {
  const FemCanvasUi({super.key});

  @override
  State<FemCanvasUi> createState() => _FemCanvasUiState();
}

class _FemCanvasUiState extends State<FemCanvasUi> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

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
              child: CustomPaint(painter: FemCanvasPainter()),
            ),
          ],
        )
      ),
    );
  }
}

class FemCanvasPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    // 座標系
    CommonPainter.drawCoordinate(canvas, isEnableRotation: false);
  }

  @override
  bool shouldRepaint(covariant FemCanvasPainter oldDelegate) {
    return false;
  }
}