import 'package:flutter/material.dart';
import '../../../utils/camera.dart';
import '../../../utils/my_painter.dart';
import '../models/frame_controller.dart';


class FramePainter extends CustomPainter {
  const FramePainter({required this.controller, required this.camera});

  final FrameController controller;
  final Camera camera;
  DataManager get data => controller.data; 

  @override
  void paint(Canvas canvas, Size size) {
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double worldWidth = data.rect.width;
    final double worldHeight = data.rect.height;

    double scale = 1.0;
    if (screenWidth / worldWidth < screenHeight / worldHeight) {
      // 横幅に合わせる
      scale = screenWidth / worldWidth / 2;
    } else {
      // 高さに合わせる
      scale = screenHeight / worldHeight / 2;
    }

    // カメラの初期化
    camera.init(
      scale,
      data.rect.center,
      Offset(screenWidth / 2, screenHeight * 0.4),
    );

    if (!controller.isCalculated) {
      _drawElem(canvas); // 要素
      _drawConst(canvas, isAfter: false); // 節点拘束拘束
      _drawPower(canvas, isAfter: false); // 節点荷重
      _drawNode(canvas, isAfter: false); // 節点
      _drawNodeNumber(canvas); // 節点番号
    }
    else {
      _drawResultElem(canvas);
      _drawConst(canvas, isAfter: true); // 節点拘束拘束
      _drawPower(canvas, isAfter: true); // 節点荷重
      _drawNode(canvas, isAfter: true); // 節点

      if (controller.resultIndex <= 2) {
        // 要素の結果
        for(int i = 0; i < data.elemCount; i++){
          Elem elem = data.getElem(i);
          Offset pos1 = elem.getNode(0)!.afterPos;
          Offset pos2 = elem.getNode(1)!.afterPos;
          MyPainter.text(canvas, 
            camera.worldToScreen(Offset((pos1.dx+pos2.dx)/2, (pos1.dy+pos2.dy)/2)),
            MyPainter.doubleToString(elem.getResult(controller.resultIndex), 3), 14, Colors.black, true, size.width, alignment: Alignment.center);
        }
      } else if (controller.resultIndex == 3) {
        // 変位
        for(int i = 0; i < data.nodeCount; i++){
          Node node = data.getNode(i);
          String text = "";
          if (node.becPos.dx != 0) {
            text = "x：${MyPainter.doubleToString(node.becPos.dx, 3)}";
          }
          if (node.becPos.dy != 0) {
            if (text.isNotEmpty) {
              text += "\n";
            }
            text += "y：${MyPainter.doubleToString(node.becPos.dy, 3)}";
          }
          MyPainter.text(canvas, camera.worldToScreen(node.afterPos), text, 16, Colors.black, true, size.width);
        }
      } else if (controller.resultIndex == 4) {
        // 反力
        for (int i = 0; i < data.nodeCount; i++) {
          Node node = data.getNode(i);
          if (node.getResult(0) != 0) {
            String text = MyPainter.doubleToString(node.getResult(0).abs(), 3);
            if (node.pos.dx <= data.rect.center.dx) {
              Offset left = camera.worldToScreen(Offset(node.afterPos.dx - data.nodeRadius * 8, node.afterPos.dy));
              Offset right = camera.worldToScreen(Offset(node.afterPos.dx - data.nodeRadius * 3, node.afterPos.dy));
              if (node.getResult(0) > 0) {
                MyPainter.arrow(left, right, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                MyPainter.arrow(right, left, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              MyPainter.text(canvas, left, text, 16, Colors.black, true, size.width, alignment: Alignment.centerRight);
            } else {
              Offset left = camera.worldToScreen(Offset(node.afterPos.dx + data.nodeRadius * 3, node.afterPos.dy));
              Offset right = camera.worldToScreen(Offset(node.afterPos.dx + data.nodeRadius * 8, node.afterPos.dy));
              if (node.getResult(0) > 0) {
                MyPainter.arrow(left, right, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                MyPainter.arrow(right, left, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              MyPainter.text(canvas, right, text, 16, Colors.black, true, size.width, alignment: Alignment.centerLeft);
            }
          }

          if (node.getResult(1) != 0) {
            String text = MyPainter.doubleToString(node.getResult(1).abs(), 3);
            if (node.pos.dy <= data.rect.center.dy) {
              Offset bottom = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy - data.nodeRadius * 8));
              Offset top = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy - data.nodeRadius * 3));
              if (node.getResult(1) > 0) {
                MyPainter.arrow(bottom, top, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                MyPainter.arrow(top, bottom, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              MyPainter.text(canvas, bottom, text, 16, Colors.black, true, size.width, alignment: Alignment.topCenter);
            } else {
              Offset bottom = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy + data.nodeRadius * 3));
              Offset top = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy + data.nodeRadius * 8));
              if (node.getResult(1) > 0) {
                MyPainter.arrow(bottom, top, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                MyPainter.arrow(top, bottom, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              MyPainter.text(canvas, top, text, 16, Colors.black, true, size.width, alignment: Alignment.bottomCenter);
            }
          }
        }
      }
    }
  }


  // 節点
  void _drawNode(Canvas canvas, {bool isAfter = false}) {
    // バグ対策
    if (data.nodeCount == 0) {
      return;
    }

    Paint paint = Paint()
      ..strokeWidth = 2;

    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos;
      if (!isAfter) {
        pos = node.pos;
      } else {
        pos = node.afterPos;
      }

      // 丸を描画
      paint.style = PaintingStyle.fill;
      paint.color = const Color.fromARGB(255, 255, 255, 255);
      canvas.drawCircle(camera.worldToScreen(pos), data.nodeRadius * camera.scale, paint);

      // 丸枠を描画
      paint.style = PaintingStyle.stroke;
      if (node.number == controller.selectedNumber && controller.typeIndex == 0) {
        paint.color = Colors.red;
      } else {
        paint.color = const Color.fromARGB(255, 0, 0, 0);
      }
      canvas.drawCircle(camera.worldToScreen(pos), data.nodeRadius * camera.scale, paint);
    }
  }

  // 節点番号
  void _drawNodeNumber(Canvas canvas) {
    // バグ対策
    if (data.nodeCount == 0) {
      return;
    }

    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos = camera.worldToScreen(node.pos);
      Color color = Colors.red;
      if (node.number == controller.selectedNumber && controller.typeIndex == 0) {
        color = Colors.red;
      } else {
        color = Colors.black;
      }
      MyPainter.text(canvas, Offset(pos.dx - 30, pos.dy - 30), (i+1).toString(), 20, color, true, 100);
    }
  }

  // 拘束
  void _drawConst(Canvas canvas, {bool isAfter = false}) {
    // バグ対策
    if(data.nodeCount == 0){
      return;
    }

    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos;
      if (!isAfter) {
        pos = node.pos;
      } else {
        pos = node.afterPos;
      }

      Direction direction = Direction.up;
      for (int i = 0; i < data.elemCount; i++) {
        Node? node1 = data.getElem(i).getNode(0);
        Node? node2 = data.getElem(i).getNode(1);
        if (node1 != null && node2 != null) {
          if (node1.number == node.number || node2.number == node.number) {
            if (node1.number != node.number) {
              if (node1.pos.dy > node.pos.dy) {
                direction = Direction.up;
              } else if (node1.pos.dy < node.pos.dy) {
                direction = Direction.down;
              } else if (node1.pos.dx > node.pos.dx) {
                direction = Direction.right;
              } else if (node1.pos.dx < node.pos.dx) {
                direction = Direction.left;
              }
            } else {
              if (node2.pos.dy > node.pos.dy) {
                direction = Direction.up;
              } else if (node2.pos.dy < node.pos.dy) {
                direction = Direction.down;
              } else if (node2.pos.dx > node.pos.dx) {
                direction = Direction.right;
              } else if (node2.pos.dx < node.pos.dx) {
                direction = Direction.left;
              }
            }
          }
        }
      }

      if (node.getConst(0) && node.getConst(1) && node.getConst(2)) {
        Offset newPos = camera.worldToScreen(pos);
        double newSize = data.nodeRadius * 8 * camera.scale;
        MyPainter.drawNodeWallConst(canvas, newPos, size: newSize, direction: direction);
      }
      else if (node.getConst(1)) {
        Offset newPos = Offset.zero;
        double newSize = data.nodeRadius * 2 * camera.scale;
        if (direction == Direction.up) {
          newPos = camera.worldToScreen(Offset(pos.dx, pos.dy - data.nodeRadius));
        } else if (direction == Direction.down) {
          newPos = camera.worldToScreen(Offset(pos.dx, pos.dy + data.nodeRadius));
        } else if (direction == Direction.left) {
          newPos = camera.worldToScreen(Offset(pos.dx - data.nodeRadius, pos.dy));
        } else if (direction == Direction.right) {
          newPos = camera.worldToScreen(Offset(pos.dx + data.nodeRadius, pos.dy));
        }

        if (node.getConst(0)) {
          MyPainter.drawNodeTriangleConst(canvas, newPos, size: newSize, direction: direction, isLine: true);
        } else {
          MyPainter.drawNodeTriangleConst(canvas, newPos, size: newSize, direction: direction, isLine: false);
        }
      }
    }
  }

  // 荷重
  void _drawPower(Canvas canvas, {bool isAfter = false}) {  
    // バグ対策
    if(data.nodeCount == 0){
      return;
    }
  
    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos;
      if (!isAfter) {
        pos = node.pos;
      } else {
        pos = node.afterPos;
      }

      if (node.getLoad(0) != 0) {
        if (node.getLoad(0) < 0) {
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius, pos.dy)), 
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius*6, pos.dy)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        } else {
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius, pos.dy)), 
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius*6, pos.dy)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }
      if (node.getLoad(1) != 0) {
        if (node.getLoad(1) > 0) {
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius)), 
            camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius*6)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        } else {
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius)), 
            camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius*6)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }
      if (node.getLoad(2) != 0) {
        
      }
    }
  }

  // 要素
  void _drawElem(Canvas canvas) {
    // バグ対策
    if (data.elemCount == 0) {
      return;
    }

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 99, 99, 99)
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.elemWidth * camera.scale;

    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);
      if (elem.getNode(0) != null && elem.getNode(1) != null) {
        Offset pos1 = elem.getNode(0)!.pos;
        Offset pos2 = elem.getNode(1)!.pos;
        if (elem.number == controller.selectedNumber && controller.typeIndex == 1) {
          paint.color = Colors.red;
        } else {
          paint.color = const Color.fromARGB(255, 86, 86, 86);
        }
        canvas.drawLine(camera.worldToScreen(pos1), camera.worldToScreen(pos2), paint);
      }
    }
  }

  // 結果の要素
  void _drawResultElem(Canvas canvas, {bool isNormalColor = false}) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 99, 99, 99)
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.elemWidth * camera.scale;

    for (int i = 0; i < data.resultElemCount; i++) {
      Elem elem = data.getResultElem(i);
      Offset pos1 = elem.getNode(0)!.afterPos;
      Offset pos2 = elem.getNode(1)!.afterPos;
      if (!isNormalColor) {
        // paint.color = MyPainter.getColor((elem.getResult(controller.resultIndex) - resultMin) / (resultMax - resultMin) * 100);
      }
      canvas.drawLine(camera.worldToScreen(pos1), camera.worldToScreen(pos2), paint);
    }
  }


  @override
  bool shouldRepaint(covariant FramePainter oldDelegate) {
    return false;
  }
}