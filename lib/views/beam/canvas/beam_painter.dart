import 'dart:math';

import 'package:flutter/material.dart';

import '../../../utils/my_painter.dart';
import '../../../utils/canvas_data.dart';
import '../models/beam_data.dart';

class BeamPainter extends CustomPainter {
  const BeamPainter({required this.data, required this.devTypeNum, required this.isSumaho});

  final BeamData data;
  final int devTypeNum;
  final bool isSumaho;

  @override
  void paint(Canvas canvas, Size size) {

    // サイズに関する変数
    double width = 0;
    double heigh = 0;
    Rect rect = Rect.zero; // はりの表示範囲
    double nodeWidth = 0; // 節点の直径
    double elemWidth = 0; // 要素の太さ

    // サイズ設定
    void setSize() {
      // 要素の太さ
      elemWidth = rect.width/50;
      if(elemWidth > 15) {
        elemWidth = 15;
      } else if(elemWidth < 6.5) {
        elemWidth = 6.5;
      }
      // 節点の大きさ
      nodeWidth = elemWidth*0.6;
    }
    
    Rect dataRect = data.rect();
    List<Node> nodes = data.allNodeList();
    List<Elem> elems = data.allElemList();

    if (!data.isCalculation) {
      // キャンバスの広さ
      if((size.height-size.height/6)*2 > size.width-150){
        width = size.width-150;
        heigh = width/2;
      }else{
        heigh = size.height-size.height/6;
        width = heigh*2;
      }
      rect = Rect.fromLTRB((size.width-width)/2, (size.height-heigh)/2, size.width-(size.width-width)/2, size.height - (size.height-heigh)/2);
      setSize();
      data.updateCanvasPos(rect, nodeWidth, elemWidth);
      _drawElem(elems, true, elemWidth, canvas); // 辺
      _drawConst(nodes, dataRect, rect, canvas); // 節点拘束
      _drawPower(nodes, elems, dataRect, data.canvasData, canvas); // 荷重
      _drawNode(nodes, true, nodeWidth, canvas); // 節点
      _drawNodeNumber(nodes, true, canvas); // 節点番号
    }
    else if(!isSumaho) {
      // キャンバスの広さ
      if((size.height-size.height/6)*2 > size.width-300){
        width = size.width-300;
        heigh = width/2;
      }else{
        heigh = size.height-size.height/6;
        width = heigh*2;
      }
      rect = Rect.fromLTRB((size.width-width)/2, (size.height-heigh)/2, size.width-(size.width-width)/2, size.height - (size.height-heigh)/2);
      setSize();
      data.updateCanvasPos(rect, nodeWidth, elemWidth);
      (Rect, double, double, double, bool) memory = (Rect.zero,0,0,0,false);
      if(devTypeNum == 2) {
        memory = _drawShear(Rect.fromLTRB(rect.left-125, rect.top, rect.right, rect.bottom), canvas); // せん断力
      } else if(devTypeNum == 3) {
        memory = _drawMoment(Rect.fromLTRB(rect.left-125, rect.top, rect.right, rect.bottom), canvas);  // 曲げモーメント
      }
      _drawElem(data.elemList, false, elemWidth, canvas); // 辺
      if(devTypeNum == 0) {
        _drawResultElem(Rect.fromLTRB(rect.left, rect.top+rect.height/6, rect.right, rect.bottom-rect.height/6), elemWidth, canvas); // 変形図
      }
      _drawConst(data.nodeList, dataRect, rect, canvas); // 節点拘束
      // 荷重
      if (devTypeNum == 0) {
        _drawPower(data.nodeList, data.elemList, dataRect, data.canvasData, canvas, isValueText: false); 
      }else{
        _drawPower(data.nodeList, data.elemList, dataRect, data.canvasData, canvas);
      }
      _drawNode(data.nodeList, false, nodeWidth, canvas); // 節点
      if(devTypeNum == 0) {
        _drawResultNode(nodeWidth, canvas);
      } else if (devTypeNum == 1) {
        _drawFrea(nodes, dataRect, rect, canvas);
      }
      
      double a = rect.height < 300 ? rect.height/5+7.5 : 300/5+7.5;
      MyPainter.memory(canvas, Rect.fromLTRB(rect.right+a, rect.top, rect.right+a, rect.bottom), memory.$2, memory.$3, memory.$4, memory.$5);
    }
    else {
      // キャンバスの広さ
      if((size.height/3-50)*2 > size.width-150){
        width = size.width-150;
        heigh = width/2;
      }else{
        heigh = (size.height/3-50);
        width = heigh*2;
      }
      rect = Rect.fromLTRB((size.width-width)/2, size.height/6-heigh/2+25, size.width-(size.width-width)/2, size.height/6+heigh/2+25);
      setSize();
      data.updateCanvasPos(rect, nodeWidth, elemWidth);
      _drawElem(data.elemList, false, elemWidth, canvas); // 辺
      if(devTypeNum == 0) {
        _drawResultElem(Rect.fromLTRB(rect.left, rect.top+rect.height/6, rect.right, rect.bottom-rect.height/6), elemWidth, canvas); // 変形図
      }
      _drawConst(data.nodeList, dataRect, rect, canvas); // 節点拘束
      // 荷重
      if (devTypeNum == 0) {
        _drawPower(data.nodeList, data.elemList, dataRect, data.canvasData, canvas, isValueText: false);
      }else{
        _drawPower(data.nodeList, data.elemList, dataRect, data.canvasData, canvas);
      }
      _drawNode(data.nodeList, false, nodeWidth, canvas); // 節点
      if(devTypeNum == 0) {
        _drawResultNode(nodeWidth, canvas);
      } else if (devTypeNum == 1) {
        _drawFrea(nodes, dataRect, rect, canvas);
      }

      (Rect, double, double, double, bool) memory = (Rect.zero,0,0,0,false);
      rect = Rect.fromLTRB((size.width-width)/2, size.height/2-heigh/2, size.width-(size.width-width)/2, size.height/2+heigh/2);
      data.updateCanvasPos(rect, nodeWidth, elemWidth);
      memory = _drawShear(Rect.fromLTRB(rect.left-75, rect.top, rect.right, rect.bottom), canvas); // せん断力
      MyPainter.text(canvas, Offset(rect.center.dx-50, rect.bottom-25), "せん断力図", 18, Colors.black, true, 1000);
      _drawElem(data.elemList, false, elemWidth, canvas); // 辺
      canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left, rect.bottom), Paint());
      canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.bottom), Paint());
      MyPainter.memory(canvas, Rect.fromLTRB(rect.right, rect.top, rect.right, rect.bottom), memory.$2, memory.$3, memory.$4, memory.$5);

      rect = Rect.fromLTRB((size.width-width)/2, size.height/6*5-heigh/2-25, size.width-(size.width-width)/2, size.height/6*5+heigh/2-25);
      data.updateCanvasPos(rect, nodeWidth, elemWidth);
      memory = _drawMoment(Rect.fromLTRB(rect.left-75, rect.top, rect.right, rect.bottom), canvas); // 曲げモーメント
      MyPainter.text(canvas, Offset(rect.center.dx-65, rect.bottom-25), "曲げモーメント図", 18, Colors.black, true, 1000);
      _drawElem(data.elemList, false, elemWidth, canvas); // 辺
      canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left, rect.bottom), Paint());
      canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.bottom), Paint());
      MyPainter.memory(canvas, Rect.fromLTRB(rect.right, rect.top, rect.right, rect.bottom), memory.$2, memory.$3, memory.$4, memory.$5);
    }
  }


  // 節点
  void _drawNode(List<Node> nodes, bool isSelect, double width, Canvas canvas) {
    // バグ対策
    if(nodes.isEmpty){
      return;
    }

    Paint paint = Paint()
      ..strokeWidth = 2;

    for(int i = 0; i < nodes.length; i++){
      paint.style = PaintingStyle.fill;
      if(nodes[i].constXYR[3]){ // ヒンジ
        paint.color = Colors.white;
        canvas.drawCircle(nodes[i].canvasPos, width*1.25, paint);
      }else{
        paint.color = const Color.fromARGB(255, 79, 79, 79);
        canvas.drawCircle(nodes[i].canvasPos, width, paint);
      }

      paint.style = PaintingStyle.stroke;
      if((nodes[i].isSelect) && isSelect){
        paint.color = Colors.red;
      }else{
        paint.color = const Color.fromARGB(255, 0, 0, 0);
      }

      if(nodes[i].constXYR[3]){ // ヒンジ
        canvas.drawCircle(nodes[i].canvasPos, width*1.25, paint);
      }else{
        canvas.drawCircle(nodes[i].canvasPos, width, paint);
      }
    }
  }

  // 節点番号
  void _drawNodeNumber(List<Node> nodes, bool isSelect, Canvas canvas) {
    // バグ対策
    if(nodes.isEmpty){
      return;
    }

    for(int i = 0; i < nodes.length; i++){
      Offset pos = nodes[i].canvasPos;
      Color color = Colors.red;
      if(nodes[i].isSelect && isSelect){
        color = Colors.red;
      }else{
        color = Colors.black;
      }
      MyPainter.text(canvas, Offset(pos.dx - 30, pos.dy - 30), (i+1).toString(), 20, color, true, 100);
    }
  }

  // 要素
  void _drawElem(List<Elem> elems, bool isSelect, double width, Canvas canvas) {
    // バグ対策
    if(elems.isEmpty){
      return;
    }

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 99, 99, 99)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    for(int i = 0; i < elems.length; i++){
      if(elems[i].nodeList[0] != null && elems[i].nodeList[1] != null){
        if(isSelect){
          if(elems[i].isSelect){
            paint.color = Colors.red;
          }else{
            paint.color = const Color.fromARGB(255, 86, 86, 86);
          }
        }
        canvas.drawLine(elems[i].nodeList[0]!.canvasPos, elems[i].nodeList[1]!.canvasPos, paint);
      }
    }
  }

  // 拘束
  void _drawConst(List<Node> nodes, Rect dataRect, Rect rect, Canvas canvas) {
    // バグ対策
    if (nodes.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (rect.height > 300) {
      rect = Rect.fromLTRB(rect.left, rect.center.dy-150, rect.right, rect.center.dy+150);
    }


    for (int i = 0; i < nodes.length; i++) {
      paint.style = PaintingStyle.fill;
      if (nodes[i].constXYR[0] && nodes[i].constXYR[1] && nodes[i].constXYR[2]) { // 壁
        if (nodes[i].pos.dx <= dataRect.center.dx) {
          Offset cpos = nodes[i].canvasPos;
          paint.color = const Color.fromARGB(255, 181, 181, 181);
          canvas.drawRect(Rect.fromLTRB(cpos.dx-rect.height/5, rect.top, cpos.dx, rect.bottom), paint);
          paint.color = Colors.black;
          canvas.drawLine(Offset(cpos.dx, rect.top), Offset(cpos.dx, rect.bottom), paint);
        }
        else {
          Offset cpos = nodes[i].canvasPos;
          paint.color = const Color.fromARGB(255, 181, 181, 181);
          canvas.drawRect(Rect.fromLTRB(cpos.dx, rect.top, cpos.dx+rect.height/5, rect.bottom), paint);
          paint.color = Colors.black;
          canvas.drawLine(Offset(cpos.dx, rect.top), Offset(cpos.dx, rect.bottom), paint);
        }
      } else if (nodes[i].constXYR[1]) { // 三角
        Offset cpos = nodes[i].canvasPos;
        paint.style = PaintingStyle.stroke;
        Path path = Path();
        path.moveTo(cpos.dx, cpos.dy+5);
        path.lineTo(cpos.dx-10, cpos.dy+25);
        path.lineTo(cpos.dx+10, cpos.dy+25);
        path.close();
        canvas.drawPath(path, paint);

        if (!nodes[i].constXYR[0]) { // 下線
          canvas.drawLine(Offset(cpos.dx-20, cpos.dy+30), Offset(cpos.dx+20, cpos.dy+30), paint);
        }
      }
    }
  }

  // 荷重
  void _drawPower(List<Node> nodes, List<Elem> elems, Rect dataRect, CanvasData canvasData, Canvas canvas, {bool isValueText = true}) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 63, 95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    
    if(nodes.isNotEmpty){
      for(int i = 0; i < nodes.length; i++){
        Offset pos = nodes[i].canvasPos;
        if(nodes[i].loadXY[1] != 0){ // 集中荷重
          if(nodes[i].loadXY[1] < 0){
            MyPainter.arrow(Offset(pos.dx, pos.dy-75), Offset(pos.dx, pos.dy-5), 4, const Color.fromARGB(255, 0, 63, 95), canvas);
            if (isValueText) {
              MyPainter.text(canvas, Offset(pos.dx-20, pos.dy-95), 
                MyPainter.doubleToString(nodes[i].loadXY[1].abs(), 3), 16, Colors.black, true, 1000,);
            }
          }else{
            MyPainter.arrow(Offset(pos.dx, pos.dy+75), Offset(pos.dx, pos.dy+5), 4, const Color.fromARGB(255, 0, 63, 95), canvas);
            if (isValueText) {
              MyPainter.text(canvas, Offset(pos.dx-20, pos.dy+75), 
                MyPainter.doubleToString(nodes[i].loadXY[1].abs(), 3), 16, Colors.black, true, 1000,);
            }
          }
        }

        if(nodes[i].loadXY[2] != 0.0){ // 曲げモーメント
          if(nodes[i].pos.dx < dataRect.center.dx) {
            paint.style = PaintingStyle.stroke;
            canvas.drawArc(Rect.fromCircle(center: pos, radius: 40), pi/3*2, pi/3*2, false, paint);
            paint.style = PaintingStyle.fill;
            if(nodes[i].loadXY[2] > 0.0){
              MyPainter.triangleEquilateral(Offset(pos.dx-17, pos.dy+40), 20, -pi/3*0.8, paint, canvas);
            }else{
              MyPainter.triangleEquilateral(Offset(pos.dx-17, pos.dy-40), 20, pi/3*0.8, paint, canvas);
            }
            if (isValueText) {
              MyPainter.text(canvas, Offset(pos.dx-50, pos.dy+35), 
                MyPainter.doubleToString(nodes[i].loadXY[2].abs(), 3), 16, Colors.black, true, 1000,);
            }
          }else{
            paint.style = PaintingStyle.stroke;
            canvas.drawArc(Rect.fromCircle(center: pos, radius: 40), -pi/3, pi/3*2, false, paint);
            paint.style = PaintingStyle.fill;
            if(nodes[i].loadXY[2] > 0.0){
              MyPainter.triangleEquilateral(Offset(pos.dx+17, pos.dy-40), 20, pi/3*2.2, paint, canvas);
            }else{
              MyPainter.triangleEquilateral(Offset(pos.dx+17, pos.dy+40), 20, -pi/3*2.2, paint, canvas);
            }
            if (isValueText) {
              MyPainter.text(canvas, Offset(pos.dx+10, pos.dy+35), 
                MyPainter.doubleToString(nodes[i].loadXY[2].abs(), 3), 16, Colors.black, true, 1000,);
            }
          }
        }
      }
    }

    paint.strokeWidth = 3;
    if(elems.isNotEmpty) {
      for(int i = 0; i < elems.length; i++){
        if(elems[i].nodeList[0] != null && elems[i].nodeList[1] != null && elems[i].load != 0.0){
          double left = 0.0;
          double right = 0.0;
          if(elems[i].nodeList[0]!.pos.dx > elems[i].nodeList[1]!.pos.dx){
            left = elems[i].nodeList[1]!.pos.dx;
            right = elems[i].nodeList[0]!.pos.dx;
          }else{
            left = elems[i].nodeList[0]!.pos.dx;
            right = elems[i].nodeList[1]!.pos.dx;
          }
          double width = right-left;
          int count = (width/(dataRect.width/10)).toInt();
          for(int j = 0; j <= count; j++){
            Offset cpos = canvasData.dToC(Offset(left+width/count*j, 0));
            if(elems[i].load < 0){
              MyPainter.arrow(Offset(cpos.dx, cpos.dy-50), Offset(cpos.dx, cpos.dy-5), 3, const Color.fromARGB(255, 0, 63, 95), canvas, lineWidth: 2);
            }
            else{
              MyPainter.arrow(Offset(cpos.dx, cpos.dy+50), Offset(cpos.dx, cpos.dy+5), 3, const Color.fromARGB(255, 0, 63, 95), canvas, lineWidth: 2);
            }
          }
          Offset cleftPos = canvasData.dToC(Offset(left, 0));
          Offset cRightPos = canvasData.dToC(Offset(right, 0));
          if(elems[i].load < 0){
            canvas.drawLine(Offset(cleftPos.dx, cleftPos.dy-48.5), Offset(cRightPos.dx, cRightPos.dy-48.5), paint);
            if (isValueText) {
              MyPainter.text(canvas, Offset((cleftPos.dx+cRightPos.dx)/2-20, cleftPos.dy-70), 
                MyPainter.doubleToString(elems[i].load.abs(), 3), 16, Colors.black, true, 1000,);
            }
          }else{
            canvas.drawLine(Offset(cleftPos.dx, cleftPos.dy+48.5), Offset(cRightPos.dx, cRightPos.dy+48.5), paint);
            if (isValueText) {
              MyPainter.text(canvas, Offset((cleftPos.dx+cRightPos.dx)/2-20, cleftPos.dy+50), 
                MyPainter.doubleToString(elems[i].load.abs(), 3), 16, Colors.black, true, 1000,);
            }
          }

        }
      }
    }
  }

  // 変形後の要素
  void _drawResultElem(Rect canvasRect, double width, Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 225, 135, 135)
      ..style = PaintingStyle.fill
      ..strokeWidth = width;

    double max = data.resultNodeList[0].becPos.dy;
    double min = data.resultNodeList[0].becPos.dy;
    for(int i = 1; i < data.resultNodeList.length; i++){
      if(max < data.resultNodeList[i].becPos.dy) max = data.resultNodeList[i].becPos.dy;
      if(min > data.resultNodeList[i].becPos.dy) min = data.resultNodeList[i].becPos.dy;
    }
    double scale = 1.0;
    if(max.abs() > min.abs()){
      scale = (canvasRect.height/data.canvasData.scale/2) / max.abs();
    }else{
      scale = (canvasRect.height/data.canvasData.scale/2) / min.abs();
    }
    for(int i = 0; i < data.resultNodeList.length; i++){
      data.resultNodeList[i].afterPos = data.resultNodeList[i].pos + data.resultNodeList[i].becPos*scale;
    }

    for(int i = 0; i < data.resultElemList.length; i++){
      canvas.drawLine(data.canvasData.dToC(data.resultElemList[i].nodeList[0]!.afterPos), data.canvasData.dToC(data.resultElemList[i].nodeList[1]!.afterPos), paint);
    }
  }

  // 変形後の節点
  void _drawResultNode(double width, Canvas canvas) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    List<Node> leftNodes = [];
    for(int i = 0; i < data.nodeList.length; i++){
      leftNodes.add(data.nodeList[i]);
    }
    leftNodes.sort((a, b) => a.pos.dx.compareTo(b.pos.dx));
    for(int i = 0; i < data.nodeList.length; i++){
      Offset cpos = data.canvasData.dToC(data.resultNodeList[i].afterPos);
      paint.style = PaintingStyle.fill;
      if(data.nodeList[i].constXYR[3]){ // ヒンジ
        paint.color = const Color.fromARGB(255, 255, 255, 255);
        canvas.drawCircle(cpos, width*1.25, paint);
      }else{
        paint.color = const Color.fromARGB(255, 79, 79, 79);
        canvas.drawCircle(cpos, width, paint);
      }
      paint.style = PaintingStyle.stroke;
      paint.color = const Color.fromARGB(255, 0, 0, 0);
      if(data.nodeList[i].constXYR[3]){ // ヒンジ
        canvas.drawCircle(cpos, width*1.25, paint);
      }else{
        canvas.drawCircle(cpos, width, paint);
      }

      // 結果の数値
      String text = "v=${MyPainter.doubleToString(data.resultNodeList[i].result[0], 3)}\n";
      if(data.nodeList[i] == leftNodes[leftNodes.length-1]){
        text += "θ=${MyPainter.doubleToString(data.resultNodeList[i].result[2], 3)}";
      }else if(data.nodeList[i] == leftNodes[0]){
        text += "θ=${MyPainter.doubleToString(data.resultNodeList[i].result[1], 3)}";
      }else{
        if(data.nodeList[i].constXYR[3]){
          text += "θ1=${MyPainter.doubleToString(data.resultNodeList[i].result[1], 3)}\n";
          text += "θ2=${MyPainter.doubleToString(data.resultNodeList[i].result[2], 3)}";
        }else{
          text += "θ=${MyPainter.doubleToString(data.resultNodeList[i].result[2], 3)}";
        }
      }
      MyPainter.text(canvas, Offset(cpos.dx-10, cpos.dy), text, 16, Colors.black, true, 1000, );
    }
  }

  // 反力
  void _drawFrea(List<Node> nodes, Rect dataRect, Rect rect, Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 196, 0, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    
    if(nodes.isNotEmpty){
      for(int i = 0; i < nodes.length; i++){
        Offset pos = nodes[i].canvasPos;
        if(nodes[i].result[3] != 0.0){ // 反力V
          if(nodes[i].result[3] < 0){
            MyPainter.arrow(Offset(pos.dx, pos.dy+30), Offset(pos.dx, pos.dy+75), 4, const Color.fromARGB(255, 196, 0, 0), canvas, lineWidth: 3.5);
          }else{
            MyPainter.arrow(Offset(pos.dx, pos.dy+75), Offset(pos.dx, pos.dy+30), 4, const Color.fromARGB(255, 196, 0, 0), canvas, lineWidth: 3.5);
          }
          MyPainter.text(canvas, Offset(pos.dx-20, pos.dy+75), 
            MyPainter.doubleToString(data.nodeList[i].result[3].abs(), 3), 16, Colors.black, true, 1000,);
        }

        if(nodes[i].result[4] != 0.0){ // 反力M
          if(nodes[i].pos.dx < dataRect.center.dx) {
            paint.style = PaintingStyle.stroke;
            canvas.drawArc(Rect.fromCircle(center: pos, radius: 40), pi/3*2, pi/3*2, false, paint);
            paint.style = PaintingStyle.fill;
            if(nodes[i].result[4] > 0.0){
              MyPainter.triangleEquilateral(Offset(pos.dx-17, pos.dy+40), 20, -pi/3*0.8, paint, canvas);
            }else{
              MyPainter.triangleEquilateral(Offset(pos.dx-17, pos.dy-40), 20, pi/3*0.8, paint, canvas);
            }
            MyPainter.text(canvas, Offset(pos.dx-55, pos.dy-55), 
              MyPainter.doubleToString(data.nodeList[i].result[4].abs(), 3), 16, Colors.black, true, 1000,);
          }else{
            paint.style = PaintingStyle.stroke;
            canvas.drawArc(Rect.fromCircle(center: pos, radius: 40), -pi/3, pi/3*2, false, paint);
            paint.style = PaintingStyle.fill;
            if(nodes[i].result[4] > 0.0){
              MyPainter.triangleEquilateral(Offset(pos.dx+17, pos.dy-40), 20, pi/3*2.2, paint, canvas);
            }else{
              MyPainter.triangleEquilateral(Offset(pos.dx+17, pos.dy+40), 20, -pi/3*2.2, paint, canvas);
            }
            MyPainter.text(canvas, Offset(pos.dx+10, pos.dy-55), 
              MyPainter.doubleToString(data.nodeList[i].result[4].abs(), 3), 16, Colors.black, true, 1000,);
          }
        }
      }
    }
  }

  // せん断力図
  (Rect rect, double max, double min, double value, bool isReverse) _drawShear(Rect canvasRect, Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.fill;

    double max = 0.0;
    double min = 0.0;
    for(int i = 1; i < data.resultElemList.length; i++){
      if(max < data.resultElemList[i].result[4]) max = data.resultElemList[i].result[4];
      if(min > data.resultElemList[i].result[4]) min = data.resultElemList[i].result[4];
    }

    if(max == 0.0 && min == 0.0){
      var me = _memoryMaxAbs(1, -1);
      return (Rect.fromLTRB(canvasRect.left-50, canvasRect.top, canvasRect.left+100, canvasRect.bottom), me.$1, -me.$1, me.$2, false); 
    }

    var me = _memoryMaxAbs(max, min);
    double scale = (canvasRect.height/data.canvasData.scale/2) / me.$1;
    List<double> sList = List.filled(data.resultElemList.length, 0);
    for(int i = 0; i < data.resultElemList.length; i++){
      sList[i] = data.resultElemList[i].result[4]*scale;
    }


    for(int i = 0; i < data.resultElemList.length; i++){
      Offset topLeft = data.canvasData.dToC(Offset(data.resultElemList[i].nodeList[0]!.afterPos.dx, sList[i]));
      Offset topRight = data.canvasData.dToC(Offset(data.resultElemList[i].nodeList[1]!.afterPos.dx, sList[i]));
      Offset bottomRight = data.canvasData.dToC(Offset(data.resultElemList[i].nodeList[1]!.afterPos.dx, 0));
      paint.color = const Color.fromARGB(255, 153, 194, 228);
      Path path = Path();
      path.moveTo(topLeft.dx, topLeft.dy);
      path.lineTo(topRight.dx, topRight.dy);
      path.lineTo(topRight.dx, bottomRight.dy);
      path.lineTo(topLeft.dx, bottomRight.dy);
      path.close();
      canvas.drawPath(path, paint);
      paint.color = Colors.black;
      canvas.drawLine(topLeft, topRight, paint);
    }

    return (Rect.fromLTRB(canvasRect.left-50, canvasRect.top, canvasRect.left+100, canvasRect.bottom), me.$1, -me.$1, me.$2, false);
  }

  // 曲げモーメント図
  (Rect rect, double max, double min, double value, bool isReverse) _drawMoment(Rect canvasRect, Canvas canvas) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.fill;

    double max = 0.0;
    double min = 0.0;
    for(int i = 1; i < data.resultElemList.length; i++){
      if(max < data.resultElemList[i].result[5]) max = data.resultElemList[i].result[5];
      if(min > data.resultElemList[i].result[5]) min = data.resultElemList[i].result[5];
      if(max < data.resultElemList[i].result[6]) max = data.resultElemList[i].result[6];
      if(min > data.resultElemList[i].result[6]) min = data.resultElemList[i].result[6];
    }
    var me = _memoryMaxAbs(max, min);
    double scale = (canvasRect.height/data.canvasData.scale/2) / me.$1;
    List<List<double>> mList = List.generate(data.resultElemList.length, (_) => List<double>.filled(2, 0));
    for(int i = 0; i < data.resultElemList.length; i++){
      mList[i][0] = data.resultElemList[i].result[5]*scale;
      mList[i][1] = data.resultElemList[i].result[6]*scale;
    }

    for(int i = 0; i < data.resultElemList.length; i++){
      Offset left = Offset(data.resultElemList[i].nodeList[0]!.afterPos.dx, -mList[i][0]);
      Offset right = Offset(data.resultElemList[i].nodeList[1]!.afterPos.dx, -mList[i][1]);
      canvas.drawLine(data.canvasData.dToC(left), data.canvasData.dToC(right), paint);
      Offset topLeft = data.canvasData.dToC(Offset(data.resultElemList[i].nodeList[0]!.afterPos.dx, -mList[i][0]));
      Offset topRight = data.canvasData.dToC(Offset(data.resultElemList[i].nodeList[1]!.afterPos.dx, -mList[i][1]));
      Offset bottomRight = data.canvasData.dToC(Offset(data.resultElemList[i].nodeList[1]!.afterPos.dx, 0));
      paint.color = const Color.fromARGB(255, 222, 171, 167);
      Path path = Path();
      path.moveTo(topLeft.dx, topLeft.dy);
      path.lineTo(topRight.dx, topRight.dy);
      path.lineTo(topRight.dx, bottomRight.dy);
      path.lineTo(topLeft.dx, bottomRight.dy);
      path.close();
      canvas.drawPath(path, paint);
      paint.color = Colors.black;
      canvas.drawLine(topLeft, topRight, paint);
    }

    return (Rect.fromLTRB(canvasRect.left-50, canvasRect.top, canvasRect.left+100, canvasRect.bottom), me.$1, -me.$1, me.$2, true);
  }

  (double maxAbs, double nextValue) _memoryMaxAbs(double max, double min) {
    // 絶対値の最大値を取得
    double maxAbs = max.abs() > min.abs() ? max.abs() : min.abs();

    // 絶対値に応じた拡大率を計算
    double digitScale = 1.0;
    if (maxAbs > 10.0) {
      while (maxAbs > 10.0) {
        maxAbs /= 10.0;
        digitScale /= 10.0;
      }
    } else if (maxAbs < 1.0 && maxAbs > 0) {
      while (maxAbs < 1.0) {
        maxAbs *= 10.0;
        digitScale *= 10.0;
      }
    }

    int maxAbsInt = maxAbs.toInt()+1;
    maxAbs = maxAbsInt.toDouble();

    maxAbs /= digitScale;

    return (maxAbs, maxAbs/2);
  } 


  @override
  bool shouldRepaint(covariant BeamPainter oldDelegate) {
    return false;
  }
}