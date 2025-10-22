import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/truss/models/truss_data.dart';
import 'package:kozo_ibaraki/core/utils/camera.dart';
import 'package:kozo_ibaraki/core/utils/canvas_utils.dart';
import 'package:kozo_ibaraki/core/utils/string_utils.dart';

class TrussPainter extends CustomPainter {
  const TrussPainter({required this.data, required this.camera});

  final TrussData data;
  final Camera camera;

  @override
  void paint(Canvas canvas, Size size) {
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double worldWidth = data.rect.width;
    final double worldHeight = data.rect.height;

    double scale = 1.0;
    if (screenWidth / (worldWidth * 1.5) < screenHeight / (worldHeight * 2)) {
      // 横幅に合わせる
      scale = screenWidth / (worldWidth * 1.5);
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

    List<Node> nodes = data.allNodeList();
    List<Elem> elems = data.allElemList();

    if (!data.isCalculation) {
      _drawElem(canvas, size, elems, false); // 要素
      _drawConst(canvas, size, nodes, false); // 節点拘束拘束
      _drawPower(canvas, size, nodes, false); // 節点荷重
      _drawNode(canvas, size, nodes, false); // 節点
      _drawNodeNumber(canvas, size, nodes); // 節点番号
    }
    else {
      if (data.resultIndex <= 2) {
        _drawElem(canvas, size, elems, true); // 要素
      } else {
        _drawElem(canvas, size, elems, true, isNormalColor: true); // 要素（節点結果表示時）
      }
      _drawConst(canvas, size, nodes, true); // 節点拘束拘束
      _drawPower(canvas, size, nodes, true); // 節点荷重
      _drawNode(canvas, size, nodes, true); // 節点

      if (data.resultIndex <= 2) {
        // 要素の結果
        for(int i = 0; i < data.elemList.length; i++){
          if(data.elemNode == 2){
            Offset pos1 = data.elemList[i].nodeList[0]!.afterPos;
            Offset pos2 = data.elemList[i].nodeList[1]!.afterPos;
            CanvasUtils.text(canvas, 
              camera.worldToScreen(Offset((pos1.dx+pos2.dx)/2, (pos1.dy+pos2.dy)/2)),
              StringUtils.doubleToString(data.resultList[i], 3), 14, Colors.black, true, size.width, alignment: Alignment.center);
          }
        }
      } else if (data.resultIndex == 3) {
        // 変位
        for(int i = 0; i < data.nodeCount; i++){
          Node node = data.getNode(i);
          String text = "";
          if (node.becPos.dx != 0) {
            text = "x：${StringUtils.doubleToString(node.becPos.dx, 3)}";
          }
          if (node.becPos.dy != 0) {
            if (text.isNotEmpty) {
              text += "\n";
            }
            text += "y：${StringUtils.doubleToString(node.becPos.dy, 3)}";
          }
          CanvasUtils.text(canvas, camera.worldToScreen(node.afterPos), text, 16, Colors.black, true, size.width);
        }
      } else if (data.resultIndex == 4) {
        // 反力
        for (int i = 0; i < data.nodeCount; i++) {
          Node node = data.getNode(i);
          if (node.result[0] != 0) {
            String text = StringUtils.doubleToString(node.result[0].abs(), 3);
            if (node.pos.dx <= data.rect.center.dx) {
              Offset left = camera.worldToScreen(Offset(node.afterPos.dx - data.nodeRadius * 8, node.afterPos.dy));
              Offset right = camera.worldToScreen(Offset(node.afterPos.dx - data.nodeRadius * 3, node.afterPos.dy));
              if (node.result[0] > 0) {
                CanvasUtils.arrow(left, right, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                CanvasUtils.arrow(right, left, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              CanvasUtils.text(canvas, left, text, 16, Colors.black, true, size.width, alignment: Alignment.centerRight);
            } else {
              Offset left = camera.worldToScreen(Offset(node.afterPos.dx + data.nodeRadius * 3, node.afterPos.dy));
              Offset right = camera.worldToScreen(Offset(node.afterPos.dx + data.nodeRadius * 8, node.afterPos.dy));
              if (node.result[0] > 0) {
                CanvasUtils.arrow(left, right, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                CanvasUtils.arrow(right, left, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              CanvasUtils.text(canvas, right, text, 16, Colors.black, true, size.width, alignment: Alignment.centerLeft);
            }
          }

          if (node.result[1] != 0) {
            String text = StringUtils.doubleToString(node.result[1].abs(), 3);
            if (node.pos.dy <= data.rect.center.dy) {
              Offset bottom = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy - data.nodeRadius * 8));
              Offset top = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy - data.nodeRadius * 3));
              if (node.result[1] > 0) {
                CanvasUtils.arrow(bottom, top, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                CanvasUtils.arrow(top, bottom, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              CanvasUtils.text(canvas, bottom, text, 16, Colors.black, true, size.width, alignment: Alignment.topCenter);
            } else {
              Offset bottom = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy + data.nodeRadius * 3));
              Offset top = camera.worldToScreen(Offset(node.afterPos.dx, node.afterPos.dy + data.nodeRadius * 8));
              if (node.result[1] > 0) {
                CanvasUtils.arrow(bottom, top, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              } else {
                CanvasUtils.arrow(top, bottom, data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 189, 53, 43), canvas);
              }
              CanvasUtils.text(canvas, top, text, 16, Colors.black, true, size.width, alignment: Alignment.bottomCenter);
            }
          }
        }
      }
    }
  }


  // 節点
  void _drawNode(Canvas canvas, Size size, List<Node> nodes, bool isAfter) {
    // バグ対策
    if (nodes.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..strokeWidth = 2;

    for (int i = 0; i < nodes.length; i++) {
      Offset pos = nodes[i].pos;
      if (isAfter) {
        pos = nodes[i].afterPos;
      }

      // 丸を描画
      paint.style = PaintingStyle.fill;
      paint.color = const Color.fromARGB(255, 255, 255, 255);
      canvas.drawCircle(camera.worldToScreen(pos), data.nodeRadius * camera.scale, paint);

      // 丸枠を描画
      paint.style = PaintingStyle.stroke;
      if (nodes[i].number == data.selectedNumber && data.typeIndex == 0) {
        paint.color = Colors.red;
      } else {
        paint.color = const Color.fromARGB(255, 0, 0, 0);
      }
      canvas.drawCircle(camera.worldToScreen(pos), data.nodeRadius * camera.scale, paint);
    }
  }

  // 節点番号
  void _drawNodeNumber(Canvas canvas, Size size, List<Node> nodes) {
    // バグ対策
    if (nodes.isEmpty) {
      return;
    }

    for (int i = 0; i < nodes.length; i++) {
      Offset pos = camera.worldToScreen(nodes[i].pos);
      Color color = Colors.red;
      if (nodes[i].number == data.selectedNumber && data.typeIndex == 0) {
        color = Colors.red;
      } else {
        color = Colors.black;
      }
      CanvasUtils.text(canvas, Offset(pos.dx - 30, pos.dy - 30), (i+1).toString(), 20, color, true, 100);
    }
  }

  // 拘束
  void _drawConst(Canvas canvas, Size size, List<Node> nodes, bool isAfter) {
    // バグ対策
    if(nodes.isEmpty){
      return;
    }

    final double lineLength = data.nodeRadius * 4;

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for(int i = 0; i < nodes.length; i++){
      Offset pos = nodes[i].pos;
      if(isAfter){
        pos = nodes[i].afterPos;
      }
      if(nodes[i].constXY[0]){
        if(pos.dx > data.rect.center.dx){
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx+data.nodeRadius*1.7, pos.dy)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius * 2.5, pos.dy-lineLength/2)), 
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius * 2.5, pos.dy+lineLength/2)), 
            paint
          );
        }else{
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx-data.nodeRadius*1.75, pos.dy)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius * 2.5, pos.dy-lineLength/2)), 
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius * 2.5, pos.dy+lineLength/2)), 
            paint
          );
        }
      }
      if(nodes[i].constXY[1]){
        if(pos.dy > data.rect.center.dy){
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius*1.75)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx-lineLength/2, pos.dy+data.nodeRadius * 2.5)), 
            camera.worldToScreen(Offset(pos.dx+lineLength/2, pos.dy+data.nodeRadius * 2.5)), 
            paint
          );
        }else{
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius*1.75)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx-lineLength/2, pos.dy-data.nodeRadius * 2.5)), 
            camera.worldToScreen(Offset(pos.dx+lineLength/2, pos.dy-data.nodeRadius * 2.5)), 
            paint
          );
        }
      }
    }
  }

  // 荷重
  void _drawPower(Canvas canvas, Size size, List<Node> nodes, bool isAfter) {  
    // バグ対策
    if(nodes.isEmpty){
      return;
    }
  
    for(int i = 0; i < nodes.length; i++){
      Offset pos = nodes[i].pos;
      if(isAfter){
        pos = nodes[i].afterPos;
      }
      if(nodes[i].loadXY[0] != 0){
        if(nodes[i].loadXY[0] < 0){
          CanvasUtils.arrow(
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius, pos.dy)), 
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius*6, pos.dy)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        }else{
          CanvasUtils.arrow(
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius, pos.dy)), 
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius*6, pos.dy)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }
      if (nodes[i].loadXY[1] != 0) {
        if (nodes[i].loadXY[1] > 0) {
          CanvasUtils.arrow(
            camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius)), 
            camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius*6)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        } else {
          CanvasUtils.arrow(
            camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius)), 
            camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius*6)), 
            data.nodeRadius * camera.scale * 0.5, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }
    }
  }

  // 要素
  void _drawElem(Canvas canvas, Size size, List<Elem> elems, bool isAfter, {bool isNormalColor = false}) {
    // バグ対策
    if (elems.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 99, 99, 99)
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.elemWidth * camera.scale;

    for (int i = 0; i < elems.length; i++) {
      if (elems[i].nodeList[0] != null && elems[i].nodeList[1] != null) {
        Offset pos1 = Offset.zero;
        Offset pos2 = Offset.zero;
        if (isAfter) {
          pos1 = elems[i].nodeList[0]!.afterPos;
          pos2 = elems[i].nodeList[1]!.afterPos;
          if (!isNormalColor) {
            paint.color = CanvasUtils.getColor((data.resultList[i] - data.resultMin) / (data.resultMax - data.resultMin) * 100);
          }
        } else {
          pos1 = elems[i].nodeList[0]!.pos;
          pos2 = elems[i].nodeList[1]!.pos;
          if (elems[i].number == data.selectedNumber && data.typeIndex == 1) {
            paint.color = Colors.red;
          } else {
            paint.color = const Color.fromARGB(255, 86, 86, 86);
          }
        }
        canvas.drawLine(camera.worldToScreen(pos1), camera.worldToScreen(pos2), paint);
      }
    }
  }



  @override
  bool shouldRepaint(covariant TrussPainter oldDelegate) {
    return false;
  }
}