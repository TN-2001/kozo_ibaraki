import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/components/my_painter.dart';

import '../../../utils/camera.dart';
import '../models/truss_data.dart';


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
      Offset(screenWidth / 2, screenHeight / 2),
    );

    List<Node> nodes = data.allNodeList();
    List<Elem> elems = data.allElemList();

    if (!data.isCalculation) {
      _drawElem(canvas, size, elems, false); // 要素
      _drawConst(canvas, size, nodes); // 節点拘束拘束
      _drawPower(canvas, size, nodes); // 接点荷重
      _drawNode(canvas, size, nodes, false); // 節点
      _drawNodeNumber(canvas, size, nodes); // 節点番号
    }
    else{
      _drawElem(canvas, size, elems, true); // 要素
      _drawNode(canvas, size, nodes, true); // 節点

      if(size.width > size.height){
        Rect cRect = Rect.fromLTRB(size.width - 85, 50, size.width - 60, size.height - 50);
        if(cRect.height > 500){
          cRect = Rect.fromLTRB(cRect.left, size.height/2-250, cRect.right, size.height/2+250);
        }
        // 虹色
        MyPainter.rainbowBand(canvas, cRect, 50);

        // 最大最小
        MyPainter.text(canvas, Offset(cRect.right+5, cRect.top-10), 
          MyPainter.doubleToString(data.resultMax, 3), 14, Colors.black, false, size.width);
        MyPainter.text(canvas, Offset(cRect.right+5, cRect.bottom-10), 
          MyPainter.doubleToString(data.resultMin, 3), 14, Colors.black, false, size.width);
      }else{
        Rect cRect = Rect.fromLTRB(50, size.height - 75, size.width - 50, size.height - 50);
        if(cRect.width > 500){
          cRect = Rect.fromLTRB(size.width/2-250, cRect.top, size.width/2+250, cRect .bottom);
        }
        // 虹色
        MyPainter.rainbowBand(canvas, cRect, 50);

        // 最大最小
        MyPainter.text(canvas, Offset(cRect.right-20, cRect.bottom), 
          MyPainter.doubleToString(data.resultMax, 3), 14, Colors.black, false, size.width);
        MyPainter.text(canvas, Offset(cRect.left-20, cRect.bottom), 
          MyPainter.doubleToString(data.resultMin, 3), 14, Colors.black, false, size.width);
      }

      // 値
      for(int i = 0; i < data.elemList.length; i++){
        if(data.elemNode == 2){
          Offset pos1 = data.elemList[i].nodeList[0]!.afterPos;
          Offset pos2 = data.elemList[i].nodeList[1]!.afterPos;
          MyPainter.text(canvas, 
            camera.worldToScreen(Offset((pos1.dx+pos2.dx)/2, (pos1.dy+pos2.dy)/2)),
            MyPainter.doubleToString(data.resultList[i], 3), 14, Colors.black, true, size.width);
        }
      }

      // 変位
      for(int i = 0; i < data.nodeList.length; i++){
        if(data.nodeList[i].loadXY[0] != 0 || data.nodeList[i].loadXY[1] != 0){
          String text = "変位\nx：${MyPainter.doubleToString(data.nodeList[i].becPos.dx, 3)}";
          text += "\ny：${MyPainter.doubleToString(data.nodeList[i].becPos.dy, 3)}";
          MyPainter.text(canvas, camera.worldToScreen(data.nodeList[i].afterPos), text, 16, Colors.black, true, size.width);
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
      paint.color = const Color.fromARGB(255, 234, 234, 234);
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
      MyPainter.text(canvas, Offset(pos.dx - 30, pos.dy - 30), (i+1).toString(), 20, color, true, 100);
    }
  }

  // 拘束
  void _drawConst(Canvas canvas, Size size, List<Node> nodes) {
    // バグ対策
    if(nodes.isEmpty){
      return;
    }

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for(int i = 0; i < nodes.length; i++){
      Offset pos = nodes[i].pos;
      if(nodes[i].constXY[0]){
        if(pos.dx > data.rect.center.dx){
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx+data.nodeRadius*1.7, pos.dy)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius * 2.5, pos.dy-data.nodeRadius * 1.5)), 
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius * 2.5, pos.dy+data.nodeRadius * 1.5)), 
            paint
          );
        }else{
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx-data.nodeRadius*1.75, pos.dy)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius * 2.5, pos.dy-data.nodeRadius * 1.5)), 
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius * 2.5, pos.dy+data.nodeRadius * 1.5)), 
            paint
          );
        }
      }
      if(nodes[i].constXY[1]){
        if(pos.dy >= data.rect.center.dy){
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius*1.75)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius * 1.5, pos.dy+data.nodeRadius * 2.5)), 
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius * 1.5, pos.dy+data.nodeRadius * 2.5)), 
            paint
          );
        }else{
          canvas.drawCircle(camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius*1.75)), data.nodeRadius * camera.scale * 0.75, paint);
          canvas.drawLine(
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius * 1.5, pos.dy-data.nodeRadius * 2.5)), 
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius * 1.5, pos.dy-data.nodeRadius * 2.5)), 
            paint
          );
        }
      }
    }
  }

  // 荷重
  void _drawPower(Canvas canvas, Size size, List<Node> nodes) {  
    // バグ対策
    if(nodes.isEmpty){
      return;
    }
  
    for(int i = 0; i < nodes.length; i++){
      Offset pos = nodes[i].pos;
      if(nodes[i].loadXY[0] != 0){
        if(nodes[i].loadXY[0] < 0){
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius, pos.dy)), 
            camera.worldToScreen(Offset(pos.dx-data.nodeRadius*4, pos.dy)), 
            data.nodeRadius * camera.scale / 3, const Color.fromARGB(255, 0, 63, 95), canvas);
        }else{
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius, pos.dy)), 
            camera.worldToScreen(Offset(pos.dx+data.nodeRadius*4, pos.dy)), 
            data.nodeRadius * camera.scale / 3, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }
      if(nodes[i].loadXY[1] != 0){
        if(nodes[i].loadXY[1] > 0){
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius)), 
            camera.worldToScreen(Offset(pos.dx, pos.dy-data.nodeRadius*4)), 
            data.nodeRadius * camera.scale / 3, const Color.fromARGB(255, 0, 63, 95), canvas);
        }else{
          MyPainter.arrow(
            camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius)), 
            camera.worldToScreen(Offset(pos.dx, pos.dy+data.nodeRadius*4)), 
            data.nodeRadius * camera.scale / 3, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }
    }
  }

  // 要素
  void _drawElem(Canvas canvas, Size size, List<Elem> elems, bool isAfter) {
    // バグ対策
    if (elems.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 99, 99, 99)
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.elemWidth * camera.scale;

    for(int i = 0; i < elems.length; i++){
      if(elems[i].nodeList[0] != null && elems[i].nodeList[1] != null){
        Offset pos1 = Offset.zero;
        Offset pos2 = Offset.zero;
        if(isAfter){
          pos1 = elems[i].nodeList[0]!.afterPos;
          pos2 = elems[i].nodeList[1]!.afterPos;
          paint.color = MyPainter.getColor((data.resultList[i] - data.resultMin) / (data.resultMax - data.resultMin) * 100);
        }else{
          pos1 = elems[i].nodeList[0]!.pos;
          pos2 = elems[i].nodeList[1]!.pos;
          if(elems[i].number == data.selectedNumber && data.typeIndex == 1){
            paint.color = Colors.red;
          }else{
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