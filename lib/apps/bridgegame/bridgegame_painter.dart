import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/apps/bridgegame/bridgegame_data.dart';
import 'package:kozo_ibaraki/components/my_painter.dart';
import 'package:kozo_ibaraki/utils/camera.dart';

class BridgegamePainter extends CustomPainter {
  BridgegamePainter({required this.data, required this.camera, required this.image});

  final BridgegameData data;
  Camera camera; // カメラ
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    Rect dataRect = data.rect();

    Paint paint = Paint();

    // カメラの初期化
    camera.init(
      _getCameraScale(Rect.fromLTRB((size.width/10), (size.height/4), size.width-(size.width/10), size.height-(size.height/4)), dataRect), 
      dataRect.center, 
      Offset(size.width/2, size.height/2)
    );

    // 画像を描画
    _drawImage(canvas, size);

    if (!data.isCalculation || data.resultList.isEmpty) {
      // 要素
      _drawElem(false, canvas); // 要素
      _drawElemEdge(false, canvas); // 要素の辺

      // 中心線
      paint = Paint()
        ..color = const Color.fromARGB(255, 0, 0, 0)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(camera.worldToScreen(data.nodeList[35].pos), camera.worldToScreen(data.nodeList[71*25+35].pos), paint);

      // 矢印
      double arrowSize = 0.2;

      if(data.powerType == 0){ // 3点曲げ
        paint.color = const Color.fromARGB(255, 0, 0, 0);
        paint.style = PaintingStyle.fill;
        paint.strokeWidth = 3.0;
        for(int i = 34; i <= 36; i++){
          Offset pos = data.nodeList[i].pos;
          MyPainter.arrow(camera.worldToScreen(pos), camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }else if(data.powerType == 1){ // 4点曲げ
        paint.color = const Color.fromARGB(255, 0, 0, 0);
        paint.style = PaintingStyle.fill;
        paint.strokeWidth = 3.0;
        for(int i = 22; i <= 24; i++){
          Offset pos = data.nodeList[i].pos;
          MyPainter.arrow(camera.worldToScreen(pos), camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
        for(int i = 46; i <= 48; i++){
          Offset pos = data.nodeList[i].pos;
          MyPainter.arrow(camera.worldToScreen(pos), camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }

      // 体積
      int elemLength = data.elemCount();
      Color color = Colors.black;
      if(elemLength > 1000){
        color = Colors.red;
      }
      MyPainter.text(canvas, const Offset(10, 10), "体積：$elemLength", 16, color, true, size.width, );
    } else {
      if (data.powerType == 0) {
        data.dispScale = 90.0; // 3点曲げの変位倍率
      } else if (data.powerType == 1) {
        data.dispScale = 2.0; // 4点曲げの変位倍率
      } else {
        data.dispScale = 100.0; // その他の変位倍率
      }
      data.dispScale /= (data.vvar * data.elemCount());

      // 要素
      _drawElem(true, canvas); // 要素
      _drawElemEdge(true, canvas); // 要素の辺

      // 選択
      paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      if(data.selectedNumber >= 0){
        if(data.elemList[data.selectedNumber].e > 0){
          final path = Path();
          for(int j = 0; j < data.elemNode; j++){
            Offset pos = camera.worldToScreen(
              data.elemList[data.selectedNumber].nodeList[j]!.pos + data.elemList[data.selectedNumber].nodeList[j]!.becPos*data.dispScale);
            if(j == 0){
              path.moveTo(pos.dx, pos.dy);
            }else{
              path.lineTo(pos.dx, pos.dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      }
      if(data.selectedNumber >= 0){
        if(data.elemList[data.selectedNumber].e > 0){
          MyPainter.text(canvas, camera.worldToScreen(data.elemList[data.selectedNumber].nodeList[0]!.pos + data.elemList[data.selectedNumber].nodeList[0]!.becPos*data.dispScale), 
            MyPainter.doubleToString(data.resultList[data.selectedNumber], 3), 14, Colors.black, true, size.width);
        }
      }

      // 虹色
      if(size.width > size.height){
        Rect cRect = Rect.fromLTRB(size.width - 85, 50, size.width - 60, size.height - 50);
        if(cRect.height > 500){
          cRect = Rect.fromLTRB(cRect.left, size.height/2-250, cRect.right, size.height/2+250);
        }
        // 虹色
        MyPainter.rainbowBand(canvas, cRect, 50);

        // 最大最小
        MyPainter.text(canvas, Offset(cRect.left+5, cRect.top-20), 
          "大", 14, Colors.black, true, size.width);
        MyPainter.text(canvas, Offset(cRect.left+5, cRect.bottom+5), 
          "小", 14, Colors.black, true, size.width);
        
        // ラベル
        MyPainter.text(canvas, Offset(cRect.right+5, cRect.center.dy-40), "引張の力", 14, Colors.black, true, 14);
      }else{
        Rect cRect = Rect.fromLTRB(50, size.height - 75, size.width - 50, size.height - 50);
        if(cRect.width > 500){
          cRect = Rect.fromLTRB(size.width/2-250, cRect.top, size.width/2+250, cRect .bottom);
        }
        // 虹色
        MyPainter.rainbowBand(canvas, cRect, 50);

        // 最大最小
        MyPainter.text(canvas, Offset(cRect.right+5, cRect.top+3), 
          "大", 14, Colors.black, true, size.width);
        MyPainter.text(canvas, Offset(cRect.left-20, cRect.top+3), 
          "小", 14, Colors.black, true, size.width);
        
        // ラベル
        MyPainter.text(canvas, Offset(cRect.center.dx-20, cRect.bottom+5), "引張の力", 14, Colors.black, true, size.width);
      }

      // 点数
      MyPainter.text(canvas, const Offset(10, 10), "${data.resultPoint.toStringAsFixed(2)}点", 32, Colors.black, true, size.width, );

      // 体積
      MyPainter.text(canvas, const Offset(10, 50), "体積：${data.elemCount()}", 16, Colors.black, true, size.width, );
    }
  }

  // カメラの拡大率を取得
  double _getCameraScale(Rect screenRect, Rect worldRect){
    double width = worldRect.width;
    double height = worldRect.height;
    if(width == 0 && height == 0){
      width = 100;
    }
    if(screenRect.width / width < screenRect.height / height){
      return screenRect.width / width;
    }
    else{
      return screenRect.height / height;
    }
  }

  // 画像を描画
  void _drawImage(Canvas canvas, Size size) {
    double imageWidth = image.width.toDouble();
    double imageHeight = image.height.toDouble();
    Offset imageCameraPos = const Offset(0, -676); // 画像のカメラ位置
    double imageScale = camera.scale / 22.7; // 画像の拡大率
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imageWidth, imageHeight), // 画像全体の範囲
      Rect.fromLTRB(
        (-imageWidth/2-imageCameraPos.dx)*imageScale + size.width/2, 
        (-imageHeight/2-imageCameraPos.dy)*imageScale + size.height/2, 
        (imageWidth/2-imageCameraPos.dx)*imageScale + size.width/2, 
        (imageHeight/2-imageCameraPos.dy)*imageScale + size.height/2
      ),
      Paint(),
    );
  }

  // 要素の辺
  void _drawElemEdge(bool isAfter, Canvas canvas){
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 132, 132, 132)
      ..style = PaintingStyle.stroke;

    if(data.elemList.isNotEmpty){
      for(int i = 0; i < data.elemList.length; i++){
        if((data.elemList[i].e > 0 && isAfter) || !isAfter){
          final path = Path();
          for(int j = 0; j < data.elemNode; j++){
            Offset pos;
            if(!isAfter){
              pos = camera.worldToScreen(data.elemList[i].nodeList[j]!.pos);
            }else{
              pos = camera.worldToScreen(data.elemList[i].nodeList[j]!.pos + data.elemList[i].nodeList[j]!.becPos*data.dispScale);
            }

            if(j == 0){
              path.moveTo(pos.dx, pos.dy);
            }else{
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
  void _drawElem(bool isAfter, Canvas canvas){
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 49, 49, 49);

    for(int i = 0; i < data.elemList.length; i++){
      if(data.elemList[i].e > 0){
        if(isAfter && (data.resultMax != 0 || data.resultMin != 0)){
          paint.color = MyPainter.getColor((data.resultList[i] - data.resultMin) / (data.resultMax - data.resultMin) * 100);
        }
        else if(!isAfter){
          if(data.elemList[i].isCanPaint){
            paint.color = const Color.fromARGB(255, 184, 25, 63);
          }
          else{
            paint.color = const Color.fromARGB(255, 106, 23, 43);
          }
        }

        final path = Path();
        for(int j = 0; j < data.elemNode; j++){
          Offset pos;
          if(!isAfter){
            pos = camera.worldToScreen(data.elemList[i].nodeList[j]!.pos);
          }else{
            pos = camera.worldToScreen(data.elemList[i].nodeList[j]!.pos + data.elemList[i].nodeList[j]!.becPos*data.dispScale);
          }
          if(j == 0){
            path.moveTo(pos.dx, pos.dy);
          }else{
            path.lineTo(pos.dx, pos.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BridgegamePainter oldDelegate) {
    return false;
  }
}