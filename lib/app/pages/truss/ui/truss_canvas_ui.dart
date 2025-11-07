import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/components/color_contour.dart';
import 'package:kozo_ibaraki/app/models/setting.dart';
import 'package:kozo_ibaraki/app/pages/truss/models/truss_data.dart';
import 'package:kozo_ibaraki/app/utils/app_canvas_utils.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'package:kozo_ibaraki/core/utils/string_utils.dart';

class TrussCanvasUi extends StatefulWidget {
  const TrussCanvasUi({super.key, required this.controller});

  final TrussData controller;

  @override
  State<TrussCanvasUi> createState() => _TrussCanvasUiState();
}

class _TrussCanvasUiState extends State<TrussCanvasUi> {
  late TrussData _controller;

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
              child: CustomPaint(painter: TrussCanvasPainter()),
            ),

            if (_controller.isCalculation && _controller.resultIndex <= 2)...{
              if (orientation == Orientation.landscape)...{
                ColorContour.landscape(
                  maxText: StringUtils.doubleToString(_controller.resultMax, 3, minAbs: Setting.minAbs),
                  minText: StringUtils.doubleToString(_controller.resultMin, 3, minAbs: Setting.minAbs),
                ),
              }
              else...{
                ColorContour.portrait(
                  maxText: StringUtils.doubleToString(_controller.resultMax, 3, minAbs: Setting.minAbs),
                  minText: StringUtils.doubleToString(_controller.resultMin, 3, minAbs: Setting.minAbs),
                ),
              }
            }
          ],
        )
      ),
    );
  }
}

class TrussCanvasPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    // 座標系
    AppCanvasUtils.drawCoordinate(canvas, isEnableRotation: false);
  }

  @override
  bool shouldRepaint(covariant TrussCanvasPainter oldDelegate) {
    return false;
  }
}