import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/frame/models/frame_controller.dart';
import 'package:kozo_ibaraki/core/utils/camera.dart';
import 'package:kozo_ibaraki/core/utils/my_painter.dart';


class FramePainter extends CustomPainter {
  FramePainter({required this.controller, required this.camera});

  final FrameController controller;
  final Camera camera;
  DataManager get data => controller.data; 
  List<Direction> nodeDirectionList = []; // 要素による節点の向き
  List<double> nodeAngleList = [];

  @override
  void paint(Canvas canvas, Size size) {
    _initCamera(size); // カメラの初期化
    _initNodeDirection(); // 節点の向きの初期化

    if (!controller.isCalculated) {
      _drawElem(canvas); // 要素
      _drawConst(canvas, isAfter: false); // 節点拘束拘束
      _drawElemPower(canvas);
      _drawPower(canvas, isAfter: false); // 節点荷重
      _drawNode(canvas, isAfter: false); // 節点
      _drawNodeNumber(canvas); // 節点番号
    }
    else {
      if (controller.resultIndex <= 2) {
        if (controller.resultIndex == 2) {
          _drawMoment(canvas);
          _drawResultElem(canvas, isNormalColor: true, isAfterPos: false);
        } else {
          _drawResultElem(canvas, isNormalColor: false, isAfterPos: false);
        }
        _drawConst(canvas, isAfter: false); // 節点拘束拘束
        _drawPower(canvas, isAfter: false); // 節点荷重
        _drawNode(canvas, isAfter: false); // 節点

        if (controller.resultIndex == 2) {
          _drawMomentText(canvas);
        }
      } else {
        _drawResultElem(canvas, isNormalColor: true, isAfterPos: true);
        _drawConst(canvas, isAfter: true); // 節点拘束拘束
        _drawPower(canvas, isAfter: true); // 節点荷重
        _drawNode(canvas, isAfter: true); // 節点
      }

      if (controller.resultIndex <= 2) {
        // 要素の結果
        // for(int i = 0; i < data.elemCount; i++){
        //   Elem elem = data.getElem(i);
        //   Offset pos1 = elem.getNode(0)!.afterPos;
        //   Offset pos2 = elem.getNode(1)!.afterPos;
        //   MyPainter.text(canvas, 
        //     camera.worldToScreen(Offset((pos1.dx+pos2.dx)/2, (pos1.dy+pos2.dy)/2)),
        //     MyPainter.doubleToString(elem.getResult(controller.resultIndex), 3), 14, Colors.black, true, size.width, alignment: Alignment.center);
        // }
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
          // たわみ角
          Node resultNode = data.getResultNode(i);
          if (resultNode.getResult(3) != 0) {
            if (text.isNotEmpty) {
              text += "\n";
            }
            text += "θ：${MyPainter.doubleToString(resultNode.getResult(3), 3)}";
          }
          MyPainter.text(canvas, camera.worldToScreen(node.afterPos), text, 16, Colors.black, true, size.width);
        }
      } else if (controller.resultIndex == 4) {
        _drawReactionForce(canvas); // 反力
      }
    }
  }

  // カメラの初期化
  void _initCamera(Size size) {
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double worldWidth = data.rect.width;
    final double worldHeight = data.rect.height;

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
      data.rect.center,
      Offset(screenWidth / 2, screenHeight * 0.4),
    );
  }

  // 節点方向の初期化
  void _initNodeDirection() {
    nodeAngleList = List.generate(data.nodeCount, (_) => 0.0);
    nodeDirectionList = List.generate(data.nodeCount, (_) => Direction.up);


    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      for (int j = 0; j < data.elemCount; j++) {
        Node? node1 = data.getElem(j).getNode(0);
        Node? node2 = data.getElem(j).getNode(1);
        if (node1 != null && node2 != null) {
          if (node1.number == node.number || node2.number == node.number) {
            if (node1.number != node.number) {
              if (node1.pos.dy > node.pos.dy) {
                nodeDirectionList[i] = Direction.up;
              } else if (node1.pos.dy < node.pos.dy) {
                nodeDirectionList[i] = Direction.down;
              } else if (node1.pos.dx > node.pos.dx) {
                nodeDirectionList[i] = Direction.right;
              } else if (node1.pos.dx < node.pos.dx) {
                nodeDirectionList[i] = Direction.left;
              }
            } else {
              if (node2.pos.dy > node.pos.dy) {
                nodeDirectionList[i] = Direction.up;
              } else if (node2.pos.dy < node.pos.dy) {
                nodeDirectionList[i] = Direction.down;
              } else if (node2.pos.dx > node.pos.dx) {
                nodeDirectionList[i] = Direction.right;
              } else if (node2.pos.dx < node.pos.dx) {
                nodeDirectionList[i] = Direction.left;
              }
            }
            break;
          }
        }
      }
    }

    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos = node.pos;
      List<Offset> targetPosList = [];
      for (int j = 0; j < data.elemCount; j++) {
        Node? node1 = data.getElem(j).getNode(0);
        Node? node2 = data.getElem(j).getNode(1);
        if (node1 != null && node2 != null) {
          if (node1.number == node.number || node2.number == node.number) {
            if (node1.number != node.number) {
              targetPosList.add(node1.pos);
            } else {
              targetPosList.add(node2.pos);
            }
          }
        }
      }

      // ベクトルの合計
      double vx = 0.0;
      double vy = 0.0;
      for (Offset targetPos in targetPosList) {
        vx += (targetPos.dx - pos.dx);
        vy += (targetPos.dy - pos.dy);
      }

      if (vx != 0.0 || vy != 0.0) {
        // 平均ベクトル
        vx /= targetPosList.length;
        vy /= targetPosList.length;
        // 反対方向
        vx = -vx;
        vy = -vy;
      } else {
        vx =  0.0;
        vy = -1.0;
      }
      // atan2で角度（ラジアン）
      nodeAngleList[i] = atan2(vx, vy);
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
      if (node.getConst(3)) {
        paint.color = Colors.white;
      } else {
        paint.color = const Color.fromARGB(255, 79, 79, 79);
      }
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

  // 節点拘束
  void _drawConst(Canvas canvas, {bool isAfter = false}) {
    // バグ対策
    if(data.nodeCount == 0){
      return;
    }

    Offset center = data.rect.center;

    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getNode(i);
      Offset pos;
      if (!isAfter) {
        pos = node.pos;
      } else {
        pos = node.afterPos;
      }

      if (node.getConst(0) && node.getConst(1) && node.getConst(2)) {
        MyPainter.drawWallConst(
          canvas, 
          camera.worldToScreen(pos),
          size: data.nodeRadius * 15 * camera.scale,
          angle: nodeAngleList[i] - pi,
        );
      }
      else if (node.getConst(0) && node.getConst(1)) {
        MyPainter.drawTriangleConst(
          canvas, 
          camera.worldToScreen(pos), 
          size: data.nodeRadius * 3 * camera.scale, 
          padding: data.nodeRadius * camera.scale, 
          angle: nodeAngleList[i] - pi, 
          isLine: false
        );
      }
      else if (node.getConst(0)) {
        if (node.pos.dx < center.dx) {
          MyPainter.drawTriangleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: data.nodeRadius * 3 * camera.scale, 
            padding: data.nodeRadius * camera.scale, 
            angle: pi * 0.5, 
            isLine: true
          );
        } else {
          MyPainter.drawTriangleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: data.nodeRadius * 3 * camera.scale, 
            padding: data.nodeRadius * camera.scale, 
            angle: pi * 1.5, 
            isLine: true
          );
        }
      } else if (node.getConst(1)) {
        if (node.pos.dy <= center.dy) {
          MyPainter.drawTriangleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: data.nodeRadius * 3 * camera.scale, 
            padding: data.nodeRadius * camera.scale, 
            angle: 0, 
            isLine: true
          );
        } else {
          MyPainter.drawTriangleConst(
            canvas, 
            camera.worldToScreen(pos), 
            size: data.nodeRadius * 3 * camera.scale, 
            padding: data.nodeRadius * camera.scale, 
            angle: pi, 
            isLine: true
          );
        }
      }
    }
  }

  // 節点荷重
  void _drawPower(Canvas canvas, {bool isAfter = false}) {  
    // バグ対策
    if(data.nodeCount == 0){
      return;
    }

    const Color arrowColor = Color.fromARGB(255, 0, 63, 95);
    final double headSize = data.nodeRadius * 2.5 * camera.scale;
    final double lineWidth = data.nodeRadius * 1 * camera.scale;
    final double lineLength = data.nodeRadius * 8 * camera.scale;
  
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
          final Offset left = camera.worldToScreen(Offset(pos.dx + data.nodeRadius, pos.dy));
          final Offset right = Offset(left.dx + lineLength, left.dy);

          MyPainter.drawArrow2(canvas, right, left, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        } else {
          final Offset right = camera.worldToScreen(Offset(pos.dx - data.nodeRadius, pos.dy));
          final Offset left = Offset(right.dx - lineLength, right.dy);

          MyPainter.drawArrow2(canvas, left, right, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        }
      }

      if (node.getLoad(1) != 0) {
        if (node.getLoad(1) > 0) {
          final Offset end = camera.worldToScreen(Offset(pos.dx, pos.dy - data.nodeRadius));
          final Offset start = Offset(end.dx, end.dy + lineLength);

          MyPainter.drawArrow2(canvas, start, end, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        } else {
          final Offset end = camera.worldToScreen(Offset(pos.dx, pos.dy + data.nodeRadius));
          final Offset start = Offset(end.dx, end.dy - lineLength);

          MyPainter.drawArrow2(canvas, start, end, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
        }
      }

      if (node.getLoad(2) != 0) {
        pos = camera.worldToScreen(pos);
        double radius = data.nodeRadius * 5 * camera.scale;
        bool isCounterclockwise = false;
        if (node.getLoad(2) > 0) {
          isCounterclockwise = true;
        }
        MyPainter.drawCircleArrow2(
          canvas, 
          pos, 
          radius, 
          headSize: headSize,
          lineWidth: lineWidth,
          color: arrowColor,
          startAngle: nodeAngleList[i] - pi + pi * 0.25,
          isCounterclockwise: isCounterclockwise,
        );
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

  // 要素荷重
  void _drawElemPower(Canvas canvas) {
    if (data.elemCount == 0) {
      return;
    }

    const Color arrowColor = Color.fromARGB(255, 0, 63, 95);
    final double headSize = data.nodeRadius * 2.5 * camera.scale;
    final double lineWidth = data.nodeRadius * 1 * camera.scale;
    final double lineLength = data.nodeRadius * 8 * camera.scale;

    for (int i = 0; i < data.elemCount; i++) {
      final Elem elem = data.getElem(i);
      if (elem.load != 0.0 && elem.getNode(0) != null && elem.getNode(1) != null) {
        final Offset pos1 = camera.worldToScreen(elem.getNode(0)!.pos);
        final Offset pos2 = camera.worldToScreen(elem.getNode(1)!.pos);

        Offset start = pos1;
        Offset end = pos2;

        // if (pos1.dx < pos2.dx || pos1.dy < pos2.dy) {
        //   start = pos1;
        //   end = pos2;
        // } else {
        //   start = pos2;
        //   end = pos1;
        // }

        if (elem.load > 0) {
          MyPainter.drawDistributionArrows(canvas, start, end, headSize: headSize, lineWidth: lineWidth, lineLength: lineLength, color: arrowColor);
        } else {
          MyPainter.drawDistributionArrows(canvas, end, start, headSize: headSize, lineWidth: lineWidth, lineLength: lineLength, color: arrowColor);
        }
      }
    }
  }

  // 結果の要素
  void _drawResultElem(Canvas canvas, {bool isNormalColor = false, bool isAfterPos = true}) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 99, 99, 99)
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.elemWidth * camera.scale;

    for (int i = 0; i < data.resultElemCount; i++) {
      Elem elem = data.getResultElem(i);
      Offset pos1;
      Offset pos2;
      if (isAfterPos) {
        pos1 = elem.getNode(0)!.afterPos;
        pos2 = elem.getNode(1)!.afterPos;
      } else {
        pos1 = elem.getNode(0)!.pos;
        pos2 = elem.getNode(1)!.pos;
        
      }
    
      if (!isNormalColor) {
        paint.color = MyPainter.getColor((elem.getResult(controller.resultIndex) - controller.resultMin) / (controller.resultMax - controller.resultMin) * 100);
      }
      canvas.drawLine(camera.worldToScreen(pos1), camera.worldToScreen(pos2), paint);
      // if (!isNormalColor && (i == 0 || i == 56)) {
      //   MyPainter.drawText(canvas, camera.worldToScreen(pos1), elem.getResult(controller.resultIndex).toString(), alignment: Alignment.bottomLeft);
      // }
    }
  }

  // 曲げモーメント
  void _drawMoment(Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 222, 171, 167)
      ..style = PaintingStyle.fill;

    double resultMax = max(controller.resultMax.abs(), controller.resultMin.abs());

    for (int i = 0; i < data.resultElemCount; i++) {
      Elem elem = data.getResultElem(i);
      Offset pos1 = elem.getNode(0)!.pos;
      Offset pos2 = elem.getNode(1)!.pos;
      double he = sqrt(pow(pos1.dx - pos2.dx, 2) + pow(pos1.dy - pos2.dy, 2));
      double ox = -(pos2.dy - pos1.dy) / he;
      double oy = (pos2.dx - pos1.dx) / he;

      Offset wpos1 = camera.worldToScreen(pos1);
      Offset wpos2 = camera.worldToScreen(pos2);
      double bx1 = - elem.getResult(3) * ox / resultMax * camera.scale * 0.2;
      double by1 = elem.getResult(3) * oy / resultMax * camera.scale * 0.2;
      double bx2 = - elem.getResult(4) * ox / resultMax * camera.scale * 0.2;
      double by2 = elem.getResult(4) * oy / resultMax * camera.scale * 0.2;

      final Path path = Path();
      path.moveTo(wpos1.dx, wpos1.dy);
      path.lineTo(wpos2.dx, wpos2.dy);
      path.lineTo(wpos2.dx + bx2, wpos2.dy + by2);
      path.lineTo(wpos1.dx + bx1, wpos1.dy + by1);
      path.close();
      canvas.drawPath(path, paint);
      
    }

    for (int i = 0; i < data.resultElemCount; i++) {
      Elem elem = data.getResultElem(i);
      Offset pos1 = elem.getNode(0)!.pos;
      Offset pos2 = elem.getNode(1)!.pos;
      double he = sqrt(pow(pos1.dx - pos2.dx, 2) + pow(pos1.dy - pos2.dy, 2));
      double ox = -(pos2.dy - pos1.dy) / he;
      double oy = (pos2.dx - pos1.dx) / he;

      Offset wpos1 = camera.worldToScreen(pos1);
      Offset wpos2 = camera.worldToScreen(pos2);
      double bx1 = - elem.getResult(3) * ox / resultMax * camera.scale * 0.2;
      double by1 = elem.getResult(3) * oy / resultMax * camera.scale * 0.2;
      double bx2 = - elem.getResult(4) * ox / resultMax * camera.scale * 0.2;
      double by2 = elem.getResult(4) * oy / resultMax * camera.scale * 0.2;
      
      canvas.drawLine(Offset(wpos2.dx + bx2, wpos2.dy + by2), Offset(wpos1.dx + bx1, wpos1.dy + by1), Paint());
    }
  }

  // 曲げモーメントのテキスト
  void _drawMomentText(Canvas canvas) {
    for (int i = 0; i < data.nodeCount; i++) {
      Node node = data.getResultNode(i);
      double value = 0;
      for (int j = 0; j < data.resultElemCount; j++) {
        Elem elem = data.getResultElem(j);
        if (elem.getNode(0)!.number == node.number || elem.getNode(1)!.number == node.number) {
          value = max(elem.getResult(3).abs(), elem.getResult(4).abs());
          break;
        }
      }
      MyPainter.text(
        canvas, camera.worldToScreen(node.pos),
        MyPainter.doubleToString(value, 3), 
        14, Colors.black, true, 1000, alignment: Alignment.center);
    }
  }

  // 反力
  void _drawReactionForce(Canvas canvas) {
    const Color arrowColor = Color.fromARGB(255, 189, 53, 43);
    final double headSize = data.nodeRadius * 2.5 * camera.scale;
    final double lineWidth = data.nodeRadius * 1 * camera.scale;
    final double lineLength = data.nodeRadius * 8 * camera.scale;

    for (int i = 0; i < data.nodeCount; i++) {
      final Node node = data.getNode(i);
      final Direction direction = nodeDirectionList[i];

      // 水平方向の反力
      if (node.getResult(0) != 0) {
        String text = MyPainter.doubleToString(node.getResult(0).abs(), 3);
        if (direction == Direction.left || node.pos.dx > data.rect.center.dx) {
          Offset left = camera.worldToScreen(Offset(node.afterPos.dx + data.nodeRadius * 3, node.afterPos.dy));
          Offset right = Offset(left.dx + lineLength, left.dy);

          if (node.getResult(0) > 0) {
            MyPainter.drawArrow2(canvas, left, right, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          } else {
            MyPainter.drawArrow2(canvas, right, left, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          }

          MyPainter.text(canvas, right, text, 16, Colors.black, true, 1000, alignment: Alignment.centerLeft);
        } else {
          Offset right = camera.worldToScreen(Offset(node.afterPos.dx - data.nodeRadius * 3, node.afterPos.dy));
          Offset left = Offset(right.dx - lineLength, right.dy);

          if (node.getResult(0) > 0) {
            MyPainter.drawArrow2(canvas, left, right, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          } else {
            MyPainter.drawArrow2(canvas, right, left, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          }

          MyPainter.text(canvas, left, text, 16, Colors.black, true, 1000, alignment: Alignment.centerRight);
        }
      }

      // 鉛直方向の反力
      if (node.getResult(1) != 0) {
        String text = MyPainter.doubleToString(node.getResult(1).abs(), 3);
        if(direction == Direction.down || node.pos.dy > data.rect.center.dy) {
          Offset bottom = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy + data.nodeRadius * 3));
          Offset top = Offset(bottom.dx, bottom.dy - lineLength);

          if (node.getResult(1) > 0) {
            MyPainter.drawArrow2(canvas, bottom, top, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          } else {
            MyPainter.drawArrow2(canvas, top, bottom, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          }

          MyPainter.text(canvas, top, text, 16, Colors.black, true, 1000, alignment: Alignment.bottomCenter);
        } else {
          Offset top = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy - data.nodeRadius * 3));
          Offset bottom = Offset(top.dx, top.dy + lineLength);
          
          if (node.getResult(1) > 0) {
            MyPainter.drawArrow2(canvas, bottom, top, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          } else {
            MyPainter.drawArrow2(canvas, top, bottom, headSize: headSize, lineWidth: lineWidth, color: arrowColor);
          }

          MyPainter.text(canvas, bottom, text, 16, Colors.black, true, 1000, alignment: Alignment.topCenter);
        }
      }

      // モーメント反力
      if (node.getResult(2) != 0) {
        String text = MyPainter.doubleToString(node.getResult(2).abs(), 3);

        Offset vector = Offset(sin(nodeAngleList[i]), cos(nodeAngleList[i]));
        Offset pos = camera.worldToScreen(node.afterPos);
        double posDistance = data.nodeRadius * 2 * camera.scale;
        if (vector.dy.abs() + 0.001 >= vector.dx.abs() && vector.dy <= 0) {
          pos = Offset(pos.dx, pos.dy + posDistance);
        } else if (vector.dy.abs() + 0.001 >= vector.dx.abs() && vector.dy > 0) {
          pos = Offset(pos.dx, pos.dy - posDistance);
        } else if (vector.dx >= 0) {
          pos = Offset(pos.dx + posDistance, pos.dy);
        } else if (vector.dx < 0) {
          pos = Offset(pos.dx - posDistance, pos.dy);
        }
        
        double radius = data.nodeRadius * 5 * camera.scale;
        bool isCounterclockwise = false;
        if (node.getResult(2) > 0) {
          isCounterclockwise = true;
        }
        MyPainter.drawCircleArrow(
          canvas, pos, radius, 
          headSize: headSize,
          lineWidth: lineWidth,
          color: arrowColor,
          direction: direction,
          isCounterclockwise: isCounterclockwise,
        );

        if (vector.dy.abs() >= vector.dx.abs() + 0.001 && vector.dy <= 0) {
          MyPainter.text(canvas, Offset(pos.dx + radius, pos.dy + radius), text, 16, Colors.black, true, 1000, alignment: Alignment.topCenter);
        } else if (vector.dy.abs() + 0.001 >= vector.dx.abs() && vector.dy > 0) {
          MyPainter.text(canvas, Offset(pos.dx - radius, pos.dy + radius), text, 16, Colors.black, true, 1000, alignment: Alignment.topCenter);
        } else if (vector.dx >= 0) {
          MyPainter.text(canvas, Offset(pos.dx - radius, pos.dy + radius), text, 16, Colors.black, true, 1000, alignment: Alignment.centerRight);
        } else if (vector.dx < 0) {
          MyPainter.text(canvas, Offset(pos.dx - radius, pos.dy - radius), text, 16, Colors.black, true, 1000, alignment: Alignment.centerRight);
        }
      }
    }
  }


  @override
  bool shouldRepaint(covariant FramePainter oldDelegate) {
    return false;
  }
}