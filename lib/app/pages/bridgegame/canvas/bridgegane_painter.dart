import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/models/bridgegame_controller.dart';
import 'package:kozo_ibaraki/core/utils/camera.dart';
import 'package:kozo_ibaraki/core/utils/canvas_utils.dart';
import 'package:kozo_ibaraki/core/utils/string_utils.dart';

class BridgegamePainter extends CustomPainter {
  BridgegamePainter({
    required this.data,
    required this.camera,
  });

  final BridgegameController data;
  Camera camera; // カメラ

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    if (!data.isCalculation) {
      // 要素
      // _drawElem(false, canvas); // 要素
      _drawElemPaint(canvas, size);
      _drawElemEdge(false, canvas); // 要素の辺

      // 中心線
      paint = Paint()
        ..color = const Color.fromARGB(255, 0, 0, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(
          camera.worldToScreen(data.getNode((data.gridWidth / 2).toInt()).pos),
          camera.worldToScreen(data
              .getNode((data.gridWidth + 1) * data.gridHeight +
                  (data.gridWidth / 2).toInt())
              .pos),
          paint);

      // 矢印
      double arrowSize = 0.2;

      if (data.powerIndex == 0) {
        // 3点曲げ
        int centerNumber = (data.gridWidth / 2).toInt();
        for (int i = centerNumber - 1; i <= centerNumber + 1; i++) {
          Offset pos = data.getNode(i).pos;
          CanvasUtils.arrow(
              camera.worldToScreen(pos),
              camera.worldToScreen(Offset(pos.dx, pos.dy - 1.5)),
              arrowSize * camera.scale,
              const Color.fromARGB(255, 0, 63, 95),
              canvas);
        }
      } else if (data.powerIndex == 1) {
        // 4点曲げ
        for (int i = 22; i <= 24; i++) {
          Offset pos = data.getNode(i).pos;
          CanvasUtils.arrow(
              camera.worldToScreen(pos),
              camera.worldToScreen(Offset(pos.dx, pos.dy - 1.5)),
              arrowSize * camera.scale,
              const Color.fromARGB(255, 0, 63, 95),
              canvas);
        }
        for (int i = 46; i <= 48; i++) {
          Offset pos = data.getNode(i).pos;
          CanvasUtils.arrow(
              camera.worldToScreen(pos),
              camera.worldToScreen(Offset(pos.dx, pos.dy - 1.5)),
              arrowSize * camera.scale,
              const Color.fromARGB(255, 0, 63, 95),
              canvas);
        }
      }
    } else {
      if (data.powerIndex == 0) {
        data.dispScale = 90.0; // 3点曲げの変位倍率
        // data.dispScale = 3;
      } else if (data.powerIndex == 1) {
        data.dispScale = 100.0; // 4点曲げの変位倍率
      } else {
        data.dispScale = 100.0; // その他の変位倍率
      }
      data.dispScale /= (data.vvar * data.onElemListLength);

      // 要素
      _drawElem(true, canvas); // 要素
      _drawElemEdge(true, canvas); // 要素の辺

      // 選択
      paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      if (data.selectedElemIndex >= 0) {
        if (data.getElem(data.selectedElemIndex).isPainted) {
          final path = Path();
          for (int j = 0; j < 4; j++) {
            Offset pos = camera.worldToScreen(
                data.getElem(data.selectedElemIndex).nodeList[j].pos +
                    data.getElem(data.selectedElemIndex).nodeList[j].becPos *
                        data.dispScale);
            if (j == 0) {
              path.moveTo(pos.dx, pos.dy);
            } else {
              path.lineTo(pos.dx, pos.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      }
      if (data.selectedElemIndex >= 0) {
        if (data.getElem(data.selectedElemIndex).isPainted) {
          CanvasUtils.text(
              canvas,
              camera.worldToScreen(
                  data.getElem(data.selectedElemIndex).nodeList[0].pos +
                      data.getElem(data.selectedElemIndex).nodeList[0].becPos *
                          data.dispScale),
              StringUtils.doubleToString(
                  data.getSelectedResult(data.selectedElemIndex), 3),
              14,
              Colors.black,
              true,
              size.width);
        }
      }
    }
  }

  // 要素の辺
  void _drawElemEdge(bool isAfter, Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 150, 150, 150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    if (data.elemListLength > 0) {
      for (int i = 0; i < data.elemListLength; i++) {
        if ((data.getElem(i).isPainted && isAfter) || !isAfter) {
          final path = Path();
          for (int j = 0; j < 4; j++) {
            Offset pos;
            if (!isAfter) {
              pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos);
            } else {
              pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos +
                  data.getElem(i).nodeList[j].becPos * data.dispScale);
            }

            if (j == 0) {
              path.moveTo(pos.dx, pos.dy);
            } else {
              path.lineTo(pos.dx, pos.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  // 要素
  void _drawElem(bool isAfter, Canvas canvas) {
    Paint paint = Paint()..color = const Color.fromARGB(255, 49, 49, 49);

    for (int i = 0; i < data.elemListLength; i++) {
      if (data.getElem(i).isPainted ||
          data.pcController.getPixelColor(i).a != 0) {
        if (isAfter &&
            (data.selectedResultMax != 0 || data.selectedResultMin != 0)) {
          paint.color = CanvasUtils.getColor(
              (data.getSelectedResult(i) - data.selectedResultMin) /
                  (data.selectedResultMax - data.selectedResultMin) *
                  100);
        } else if (!isAfter) {
          if (data.getElem(i).isCanPaint) {
            // paint.color = const Color.fromARGB(255, 184, 25, 63);
            paint.color = data.pcController.getPixelColor(i);
          } else {
            // paint.color = const Color.fromARGB(255, 106, 23, 43);
            paint.color = data.pcController.getPixelColor(i);
          }
        }

        final path = Path();
        for (int j = 0; j < 4; j++) {
          Offset pos;
          if (!isAfter) {
            pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos);
          } else {
            pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos +
                data.getElem(i).nodeList[j].becPos * data.dispScale);
          }
          if (j == 0) {
            path.moveTo(pos.dx, pos.dy);
          } else {
            path.lineTo(pos.dx, pos.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawElemPaint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color.fromARGB(255, 49, 49, 49);

    for (int i = 0; i < data.elemListLength; i++) {
      if (data.getElem(i).isCanPaint) {
        paint.color = data.pcController.getPixelColor(i);
      } else {
        paint.color = data.pcController.getPixelColor(i);
      }

      final path = Path();
      for (int j = 0; j < 4; j++) {
        Offset pos;
        pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos);
        if (j == 0) {
          path.moveTo(pos.dx, pos.dy);
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BridgegamePainter oldDelegate) {
    return false;
  }
}
