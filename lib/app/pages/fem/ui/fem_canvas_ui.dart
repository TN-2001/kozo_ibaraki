import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/components/color_contour.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_controller.dart';
import 'package:kozo_ibaraki/app/utils/common_painter.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'package:kozo_ibaraki/core/utils/string_utils.dart';

class FemCanvasUi extends StatefulWidget {
  const FemCanvasUi({super.key, required this.controller});

  final FemController controller;

  @override
  State<FemCanvasUi> createState() => _FemCanvasUiState();
}

class _FemCanvasUiState extends State<FemCanvasUi> {
  late FemController _controller;


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
              child: CustomPaint(painter: FemCanvasPainter()),
            ),

            if (_controller.isCalculated && _controller.resultIndex <= 10)...{
              if (orientation == Orientation.landscape)...{
                ColorContour.landscape(
                  maxText: StringUtils.doubleToString(_controller.resultMax, 3),
                  minText: StringUtils.doubleToString(_controller.resultMin, 3),),
              }
              else...{
                ColorContour.portrait(
                  maxText: StringUtils.doubleToString(_controller.resultMax, 3),
                  minText: StringUtils.doubleToString(_controller.resultMin, 3),),
              }
            }
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