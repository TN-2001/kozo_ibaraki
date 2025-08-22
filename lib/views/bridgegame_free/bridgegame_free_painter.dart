import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/views/bridgegame_free/bridgegame_free_data.dart';
import 'package:kozo_ibaraki/utils/my_painter.dart';
import 'package:kozo_ibaraki/utils/camera.dart';

class BridgegameFreePainter extends CustomPainter {

  final BridgegameFreeData _data;
  final Camera _camera; // カメラ
  final ui.Image _image;

  // コンストラクタ
  BridgegameFreePainter({required BridgegameFreeData data, required Camera camera, required ui.Image image}) 
    : _image = image, _data = data, _camera = camera;

  @override
  void paint(Canvas canvas, Size size) {
    Rect dataRect = _data.rect;

    Paint paint = Paint();

    // カメラの初期化
    _camera.init(
      _getCameraScale(Rect.fromLTRB((size.width/10), (size.height/4), size.width-(size.width/10), size.height-(size.height/4)), dataRect), 
      dataRect.center, 
      Offset(size.width/2, size.height/2)
    );

    // 画像を描画
    _drawImage(canvas, size);

    if (!_data.isCalculation || _data.resultList.isEmpty) {
      // 要素
      _drawElem(false, canvas); // 要素
      _drawElemEdge(false, canvas); // 要素の辺

      // 中心線
      paint = Paint()
        ..color = const Color.fromARGB(255, 0, 0, 0)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        _camera.worldToScreen(_data.getNode((_data.countX/2).toInt()).pos), 
        _camera.worldToScreen(_data.getNode((_data.countX+1)*_data.countY+(_data.countX/2).toInt()).pos), 
        paint
      );

      // 矢印
      double arrowSize = 0.2;

      if(_data.powerType == 0){ // 3点曲げ
        paint.color = const Color.fromARGB(255, 0, 0, 0);
        paint.style = PaintingStyle.fill;
        paint.strokeWidth = 3.0;
        for(int i = (_data.countX/2).toInt()-1; i <= (_data.countX/2).toInt()+1; i++){
          Offset pos = _data.getNode(i).pos;
          MyPainter.arrow(_camera.worldToScreen(pos), _camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*_camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }else if(_data.powerType == 1){ // 4点曲げ
        paint.color = const Color.fromARGB(255, 0, 0, 0);
        paint.style = PaintingStyle.fill;
        paint.strokeWidth = 3.0;
        for(int i = 22; i <= 24; i++){
          Offset pos = _data.getNode(i).pos;
          MyPainter.arrow(_camera.worldToScreen(pos), _camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*_camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
        for(int i = 46; i <= 48; i++){
          Offset pos = _data.getNode(i).pos;
          MyPainter.arrow(_camera.worldToScreen(pos), _camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*_camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }

      // 体積
      int elemLength = _data.elemCount;
      Color color = Colors.black;
      if(elemLength > 1000){
        color = Colors.red;
      }
      MyPainter.text(canvas, const Offset(10, 10), "体積：$elemLength", 16, color, true, size.width, );
    } else {
      if (_data.powerType == 0) {
        _data.dispScale = 90.0; // 3点曲げの変位倍率
        // data.dispScale = 3;
      } else if (_data.powerType == 1) {
        _data.dispScale = 2.0; // 4点曲げの変位倍率
      } else {
        _data.dispScale = 100.0; // その他の変位倍率
      }
      _data.dispScale /= (_data.vvar * _data.elemCount);

      // 要素
      _drawElem(true, canvas); // 要素
      _drawElemEdge(true, canvas); // 要素の辺

      // 選択
      paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      if(_data.selectedNumber >= 0){
        if(_data.getElem(_data.selectedNumber).e > 0){
          final path = Path();
          for(int j = 0; j < _data.elemNode; j++){
            Offset pos = _camera.worldToScreen(
              _data.getElem(_data.selectedNumber).nodeList[j]!.pos + _data.getElem(_data.selectedNumber).nodeList[j]!.becPos*_data.dispScale);
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
      if(_data.selectedNumber >= 0){
        if(_data.getElem(_data.selectedNumber).e > 0){
          MyPainter.text(canvas, _camera.worldToScreen(_data.getElem(_data.selectedNumber).nodeList[0]!.pos + _data.getElem(_data.selectedNumber).nodeList[0]!.becPos*_data.dispScale), 
            MyPainter.doubleToString(_data.resultList[_data.selectedNumber], 3), 14, Colors.black, true, size.width);
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
      MyPainter.text(canvas, const Offset(10, 10), "${_data.resultPoint.toStringAsFixed(2)}点", 32, Colors.black, true, size.width, );

      // 体積
      MyPainter.text(canvas, const Offset(10, 50), "体積：${_data.elemCount}", 16, Colors.black, true, size.width, );
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
    double imageWidth = _image.width.toDouble();
    double imageHeight = _image.height.toDouble();
    Offset imageCameraPos = const Offset(0, -676); // 画像のカメラ位置
    double imageScale = _camera.scale / 22.7*(_data.countX/70); // 画像の拡大率
    canvas.drawImageRect(
      _image,
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

    if(_data.getElemListLength() > 0){
      for(int i = 0; i < _data.getElemListLength(); i++){
        if((_data.getElem(i).e > 0 && isAfter) || !isAfter){
          final path = Path();
          for(int j = 0; j < _data.elemNode; j++){
            Offset pos;
            if(!isAfter){
              pos = _camera.worldToScreen(_data.getElem(i).nodeList[j]!.pos);
            }else{
              pos = _camera.worldToScreen(_data.getElem(i).nodeList[j]!.pos + _data.getElem(i).nodeList[j]!.becPos*_data.dispScale);
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

    for(int i = 0; i < _data.getElemListLength(); i++){
      if(_data.getElem(i).e > 0){
        if(isAfter && (_data.resultMax != 0 || _data.resultMin != 0)){
          paint.color = MyPainter.getColor((_data.resultList[i] - _data.resultMin) / (_data.resultMax - _data.resultMin) * 100);
        }
        else if(!isAfter){
          if(_data.getElem(i).isCanPaint){
            paint.color = const Color.fromARGB(255, 184, 25, 63);
          }
          else{
            paint.color = const Color.fromARGB(255, 106, 23, 43);
          }
        }

        final path = Path();
        for(int j = 0; j < _data.elemNode; j++){
          Offset pos;
          if(!isAfter){
            pos = _camera.worldToScreen(_data.getElem(i).nodeList[j]!.pos);
          }else{
            pos = _camera.worldToScreen(_data.getElem(i).nodeList[j]!.pos + _data.getElem(i).nodeList[j]!.becPos*_data.dispScale);
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
  bool shouldRepaint(covariant BridgegameFreePainter oldDelegate) {
    return false;
  }
}