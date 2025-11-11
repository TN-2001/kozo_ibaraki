import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/models/setting.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_controller.dart';
import 'package:kozo_ibaraki/app/utils/app_canvas_utils.dart';
import 'package:kozo_ibaraki/core/utils/canvas_utils.dart';
import 'package:kozo_ibaraki/core/utils/camera.dart';
import 'package:kozo_ibaraki/core/utils/string_utils.dart';

class FemPainter extends CustomPainter {
  FemPainter({required this.controller, required this.camera});

  final FemController controller;
  FemData get data => controller.data;
  final Camera camera; // カメラ


  @override
  void paint(Canvas canvas, Size size) {
    _initCamera(size); // カメラの初期化

    if (!controller.isCalculated) {
      _drawElem(canvas); // 要素
      _drawPower(canvas); // 荷重
      _drawConst(canvas); // 節点拘束
      _drawNode(canvas); // 節点
      if (Setting.isNodeNumber) _drawNodeNumber(canvas); // 節点番号
      if (Setting.isElemNumber) _drawElemNumber(canvas); // 要素番号 
    }
    else{
      // _drawElem(canvas); // 要素
      _drawElemResult(canvas);
      _drawPower(canvas); // 荷重
      _drawConst(canvas); // 節点拘束
      _drawNode(canvas); // 節点
      if (Setting.isResultValue) _drawElemResultValue(canvas); // 要素の結果値
      if (Setting.isNodeNumber) _drawNodeNumber(canvas); // 節点番号
      if (Setting.isElemNumber) _drawElemNumber(canvas); // 要素番号 
    }
  }


  // カメラの初期化
  void _initCamera(Size size) {
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    Rect rect = data.getRect();
    final double worldWidth = rect.width;
    final double worldHeight = rect.height;

    double scale = 1.0;
    if (screenWidth / (worldWidth * 2.0) < screenHeight / (worldHeight * 2)) {
      // 横幅に合わせる
      scale = screenWidth / (worldWidth * 2.0);
    } else {
      // 高さに合わせる
      scale = screenHeight / (worldHeight * 2);
    }

    // カメラの初期化
    camera.init(
      scale,
      rect.center,
      Offset(screenWidth / 2, screenHeight * 0.4),
    );
  }


  // 節点
  void _drawNode(Canvas canvas) {
    // バグ対策
    if (data.nodeCount == 0) return;

    double nodeRadius = data.getNodeRadius() / 2.5;

    Paint paint = Paint()
      ..strokeWidth = 2;

    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos;
      if (!controller.isCalculated) {
        pos = node.pos;
      } else {
        pos = node.afterPos;
      }

      // 丸を描画
      paint.style = PaintingStyle.fill;
      paint.color = const Color.fromARGB(255, 79, 79, 79);
      canvas.drawCircle(camera.worldToScreen(pos), nodeRadius * camera.scale, paint);

      // 丸枠を描画
      paint.style = PaintingStyle.stroke;
      if (node.number == controller.selectedNumber && controller.typeIndex == 0) {
        paint.color = Colors.red;
      } else {
        paint.color = const Color.fromARGB(255, 0, 0, 0);
      }
      canvas.drawCircle(camera.worldToScreen(pos), nodeRadius * camera.scale, paint);
    }
  }

  // 節点番号
  void _drawNodeNumber(Canvas canvas) {
    if (data.nodeCount == 0) return;

    for(int i = 0; i < data.nodeCount; i++){
      Node node = data.getNode(i);
      Offset pos;
      if (!controller.isCalculated) {
        pos = camera.worldToScreen(node.pos);
      } else {
        pos = camera.worldToScreen(node.afterPos);
      }
      Color color;
      if (node.number == controller.selectedNumber && controller.typeIndex == 0) {
        color = Colors.red;
      } else {
        color = Colors.black;
      }
      CanvasUtils.text(canvas, Offset(pos.dx - 30, pos.dy - 30), (i+1).toString(), 20, color, true, 100);
    }
  }

  // 要素
  void _drawElem(Canvas canvas) {
    // バグ対策
    if (data.elemCount == 0) return;

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 194, 194, 194)
      ..style = PaintingStyle.fill;

    // 面
    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);
      if ((elem.nodeCount == 3 && (elem.getNode(0) != null && elem.getNode(1) != null && elem.getNode(2) != null))
        || (elem.nodeCount == 4 && (elem.getNode(0) != null && elem.getNode(1) != null && elem.getNode(2) != null && elem.getNode(3) != null))) {
        Path path = Path();
        for (int j = 0; j < elem.nodeCount; j++) {
          Offset pos;
          if (!controller.isCalculated) {
            pos = camera.worldToScreen(elem.getNode(j)!.pos);
          } else {
            pos = camera.worldToScreen(elem.getNode(j)!.afterPos);
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

    // 枠
    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);
      if (elem.number == controller.selectedNumber && controller.typeIndex == 1) {
        paint.color = Colors.red;
      } else {
        paint.color = const Color.fromARGB(255, 55, 55, 55);
      }
      for(int j = 0; j < elem.nodeCount; j++){
        int num1 = j;
        int num2 = j < elem.nodeCount-1 ? j + 1 : 0;
        if(elem.getNode(num1) != null && elem.getNode(num2) != null){
          if (!controller.isCalculated) {
            canvas.drawLine(camera.worldToScreen(elem.getNode(num1)!.pos), camera.worldToScreen(elem.getNode(num2)!.pos), paint);
          } else {
            canvas.drawLine(camera.worldToScreen(elem.getNode(num1)!.afterPos), camera.worldToScreen(elem.getNode(num2)!.afterPos), paint);
          }
        }
      }
    }
  }

  // 要素番号
  void _drawElemNumber(Canvas canvas) {
    // バグ対策
    if (data.elemCount == 0) return;

    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);

      if ((elem.nodeCount == 3 && (elem.getNode(0) == null || elem.getNode(1) == null || elem.getNode(2) == null))
        || (elem.nodeCount == 4 && (elem.getNode(0) == null || elem.getNode(1) == null || elem.getNode(2) == null || elem.getNode(3) == null))) {
          continue;
      }

      Offset pos = Offset.zero;
      for (int j = 0; j < elem.nodeCount; j++) {
        Offset npos;
        if (!controller.isCalculated) {
          npos = elem.getNode(j)!.pos;
        } else {
          npos = elem.getNode(j)!.afterPos;
        }
        pos += Offset(npos.dx, npos.dy);
      }
      pos = pos / elem.nodeCount.toDouble();
      pos = camera.worldToScreen(pos);

      String text = "(${i+1})";
      Color color;
      if (elem.number == controller.selectedNumber && controller.typeIndex == 1) {
        color = Colors.red;
      } else {
        color = Colors.black;
      }
      CanvasUtils.drawText(canvas, pos, text, alignment: Alignment.bottomCenter, color: color);
    }
  }

  // 拘束
  void _drawConst(Canvas canvas) {
    // バグ対策
    if (data.nodeCount == 0) return;

    Offset center = data.getRect().center;
    double nodeRadius = data.getNodeRadius();
    double padding = nodeRadius * camera.scale / 2;

    for(int i = 0; i < data.nodeCount; i++){
      Node node = data.getNode(i);
      Offset pos;
      if (!controller.isCalculated) {
        pos = node.pos;
      } else {
        pos = node.afterPos;
      }

      if (node.getConst(0)) {
        if (pos.dx <= center.dx) {
          AppCanvasUtils.drawCircleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: nodeRadius * 1.5 * camera.scale, 
            padding: padding, 
            angle: pi / 2, 
          );
        } else {
          AppCanvasUtils.drawCircleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: nodeRadius * 1.5 * camera.scale, 
            padding: padding, 
            angle: - pi / 2, 
          );
        }
      }
      if (node.getConst(1)) {
        if (pos.dy <= center.dy) {
          AppCanvasUtils.drawCircleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: nodeRadius * 1.5 * camera.scale, 
            padding: padding, 
            angle: 0, 
          );
        } else {
          AppCanvasUtils.drawCircleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: nodeRadius * 1.5 * camera.scale, 
            padding: padding, 
            angle: pi, 
          );
        }
      }
    }
  }

  // 荷重
  void _drawPower(Canvas canvas) {   
    // バグ対策
    if (data.nodeCount == 0) return;

    final Offset center = data.getRect().center;
    final double nodeRadius = data.getNodeRadius();
    const Color arrowColor = Color.fromARGB(255, 0, 63, 95);
    final double padding = nodeRadius / 2;
    final double headSize = nodeRadius * 2.5 * camera.scale;
    final double lineWidth = nodeRadius * 1 * camera.scale;
    final double lineLength = nodeRadius * 8 * camera.scale;

    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos;
      if (!controller.isCalculated) {
        pos = node.pos;
      } else {
        pos = node.afterPos;
      }

      double loadX = 0.0;
      double loadY = 0.0;
      if (node.getConst(0)) {
        loadX = node.getLoad(0);
      } else {
        loadX = node.getLoad(2);
      }
      if (node.getConst(1)) {
        loadY = node.getLoad(1);
      } else {
        loadY = node.getLoad(3);
      }

      if (loadX != 0) {
        Offset left;
        Offset right; 
        double newPadding = padding;
        double newLineLength = lineLength;
        if (node.getConst(0)) {
          newPadding += nodeRadius;
          newLineLength -= nodeRadius * camera.scale;
        }
        if (pos.dx <= center.dx) {
          right = camera.worldToScreen(Offset(pos.dx - newPadding, pos.dy));
          left = Offset(right.dx - newLineLength, right.dy);
        } else {
          left = camera.worldToScreen(Offset(pos.dx + newPadding, pos.dy));
          right = Offset(left.dx + newLineLength, left.dy);
        }

        if (loadX > 0) {
          CanvasUtils.drawArrow(canvas, left, right, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        } else {
          CanvasUtils.drawArrow(canvas, right, left, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        }
      }
      if (loadY != 0) {
        final Offset bottom;
        final Offset top;
        double newPadding = padding;
        double newLineLength = lineLength;
        if (node.getConst(1)) {
          newPadding += nodeRadius;
          newLineLength -= nodeRadius * camera.scale;
        }
        if (pos.dy <= center.dy) {
          top = camera.worldToScreen(Offset(pos.dx, pos.dy - newPadding));
          bottom = Offset(top.dx, top.dy + newLineLength);
        } else {
          bottom = camera.worldToScreen(Offset(pos.dx, pos.dy + newPadding));
          top = Offset(bottom.dx, bottom.dy - newLineLength);
        }

        if (loadY > 0) {
          CanvasUtils.drawArrow(canvas, bottom, top, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        } else {
          CanvasUtils.drawArrow(canvas, top, bottom, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        }
      }
    }
  }

  // 要素の結果
  void _drawElemResult(Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 225, 135, 135)
      ..style = PaintingStyle.fill;
    // 面
    paint = Paint()
      ..color = const Color.fromARGB(255, 194, 194, 194);

    int resultIndex = controller.resultIndex;
    double resultMax = controller.resultMax;
    double resultMin = controller.resultMin;

    bool isCanGetColor = false;
    if (controller.resultMax != 0 || controller.resultMin != 0) {
      if (StringUtils.doubleToString(controller.resultMax, 3) == StringUtils.doubleToString(controller.resultMin, 3)) {
        paint.color = CanvasUtils.getColor(50);
      } else {
        isCanGetColor = true;
      }
    }

    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);
      if (isCanGetColor) {
        paint.color = CanvasUtils.getColor(
          (elem.getResult(resultIndex) - resultMin) / (resultMax - resultMin) * 100);
      }

      final path = Path();
      for (int j = 0; j < elem.nodeCount; j++) {
        Offset pos = camera.worldToScreen(elem.getNode(j)!.afterPos);
        if (j == 0) {
          path.moveTo(pos.dx, pos.dy);
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // 辺
    paint = Paint()
      ..color = const Color.fromARGB(255, 49, 49, 49)
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);

      final path = Path();
      for (int j = 0; j < elem.nodeCount; j++) {
        Offset pos = camera.worldToScreen(elem.getNode(j)!.afterPos);
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

  // 要素の結果値
  void _drawElemResultValue(Canvas canvas) {
    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);

      Offset pos = Offset.zero;
      for (int j = 0; j < elem.nodeCount; j++) {
        Offset npos = elem.getNode(j)!.afterPos;
        pos += Offset(npos.dx, npos.dy);
      }
      pos = pos / elem.nodeCount.toDouble();
      pos = camera.worldToScreen(pos);

      CanvasUtils.drawText(canvas, pos, StringUtils.doubleToString(elem.getResult(controller.resultIndex), 3, minAbs: Setting.minAbs), alignment: Alignment.topCenter);
    }
  }


  @override
  bool shouldRepaint(covariant FemPainter oldDelegate) {
    return false;
  }
}