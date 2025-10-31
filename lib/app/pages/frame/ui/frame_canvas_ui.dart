import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/components/color_contour.dart';
import 'package:kozo_ibaraki/app/models/setting.dart';
import 'package:kozo_ibaraki/app/pages/frame/models/frame_controller.dart';
import 'package:kozo_ibaraki/app/utils/common_painter.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'package:kozo_ibaraki/core/utils/string_utils.dart';

class FrameCanvasUi extends StatefulWidget {
  const FrameCanvasUi({super.key, required this.controller});

  final FrameController controller;

  @override
  State<FrameCanvasUi> createState() => _FrameCanvasUiState();
}

class _FrameCanvasUiState extends State<FrameCanvasUi> {
  late FrameController _controller;

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

            if (_controller.isCalculated && _controller.resultIndex <= 1)...{
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

class FrameCanvasPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    // 座標系
    CommonPainter.drawCoordinate(canvas);
  }

  @override
  bool shouldRepaint(covariant FrameCanvasPainter oldDelegate) {
    return false;
  }
}