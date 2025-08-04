import 'package:flutter/material.dart';
import '../../../components/my_painter.dart';
import '../../../constants/constant.dart';
import '../../../utils/camera.dart';
import '../models/bridgegame_controller.dart';
import 'ground.dart';
import 'sea.dart';

class BridgegameCanvas extends StatelessWidget {
  BridgegameCanvas({super.key, required this.controller});

  final BridgegameController controller;
  final Camera camera = Camera(0,Offset.zero,Offset.zero); // カメラ


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

  Widget paintCanvas(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onPanStart: (details) {
          if (controller.isCalculation) {
            return;
          }
          controller.pcController.saveToUndo();
          controller.paintPixel(camera.screenToWorld(details.localPosition));
        },
        onPanUpdate: (details) {
          if (controller.isCalculation) {
            return;
          }
          controller.paintPixel(camera.screenToWorld(details.localPosition));
        },
        onTapDown: (details) {
          if (controller.isCalculation) {
            controller.selectElem(camera.screenToWorld(details.localPosition));
            return;
          }
          controller.pcController.saveToUndo();
          controller.paintPixel(camera.screenToWorld(details.localPosition));
        },
        child: CustomPaint(
          painter: BridgegamePainter(data: controller, camera: camera,),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        if (width / height < 16 / 9) {
          height = width / (16 / 9);
        } else if (width / height > 16 / 9) {
          width = height * (16 / 9);
        }

        camera.init(
          _getCameraScale(Rect.fromLTRB((width/10), (height/4), width-(width/10), height-(height/4)), controller.nodeRect), 
          controller.nodeRect.center, 
          Offset(constraints.maxWidth / 2, constraints.maxHeight / 2)
        );
        final double canvasWidth = camera.scale * controller.nodeRect.width;
        final double canvasHeight = camera.scale * controller.nodeRect.height;
        final double cellSize = camera.scale;


        return Center(
          child: Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 雲
                OverflowBox(
                  maxWidth: width * 1.21,
                  maxHeight: height * 1.21,
                  child: Transform(
                    transform: Matrix4.translationValues(- width * 0.01, height * 0.015, 0),
                    child: Image.asset(ImagePass.cloud, width: width * 1.21, height: height * 1.21,),
                  ),
                ),
                // 太陽
                Transform(
                  transform: Matrix4.translationValues(- width * 0.31, - height * 0.34, 0),
                  child: Image.asset(ImagePass.sun, width: height * 0.25, height: height * 0.25,),
                ),
                // 名前
                Transform(
                  transform: Matrix4.translationValues(width * 0.15, -height * 0.38, 0),
                  child: Image.asset(ImagePass.name, width: height * 1.25, height: height * 1.25 / 2,),
                ),
                // 海
                SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: const Sea(),
                ),
                // 船
                if (!controller.isCalculation)...{
                  Transform(
                    transform: Matrix4.translationValues(height * 0.25 - canvasWidth * 0.425, height * 0.375, 0),
                    child: Image.asset(ImagePass.ship, width: height * 0.5, height: height * 0.5,),
                  ),
                } else ...{
                  Transform(
                    transform: Matrix4.translationValues(- height * 0.25 + canvasWidth * 0.425, height * 0.375, 0),
                    child: Image.asset(ImagePass.ship, width: height * 0.5, height: height * 0.5,),
                  ),
                },
                // 土台
                SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: Ground(constWidth: cellSize*2, canvasWidth: canvasWidth, canvasHeight: canvasHeight,),
                ),
                // トラック
                if (!controller.isCalculation)...{
                  Transform(
                    transform: Matrix4.translationValues(canvasWidth * 0.5 + height * 0.075 + canvasHeight * 0.05, canvasHeight * 0.5 - cellSize * 3, 0),
                    child: Image.asset(ImagePass.truck, width: height * 0.15, height: height * 0.15,),
                  ),
                } else ...{
                  Transform(
                    transform: Matrix4.translationValues(- canvasWidth * 0.5 - height * 0.075 - canvasHeight * 0.05, canvasHeight * 0.5 - cellSize * 3, 0),
                    child: Image.asset(ImagePass.truck, width: height * 0.15, height: height * 0.15,),
                  ),
                },
                // 
                paintCanvas(context),
              ],
            ),
          ),
        );
      },
    );
  }
}


class BridgegamePainter extends CustomPainter {
  BridgegamePainter({required this.data, required this.camera,});

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
      canvas.drawLine(camera.worldToScreen(data.getNode(35).pos), camera.worldToScreen(data.getNode(71*25+35).pos), paint);

      // 矢印
      double arrowSize = 0.2;

      if(data.powerIndex == 0){ // 3点曲げ
        for(int i = 34; i <= 36; i++){
          Offset pos = data.getNode(i).pos;
          MyPainter.arrow(camera.worldToScreen(pos), camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
      }else if(data.powerIndex == 1){ // 4点曲げ
        for(int i = 22; i <= 24; i++){
          Offset pos = data.getNode(i).pos;
          MyPainter.arrow(camera.worldToScreen(pos), camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
        }
        for(int i = 46; i <= 48; i++){
          Offset pos = data.getNode(i).pos;
          MyPainter.arrow(camera.worldToScreen(pos), camera.worldToScreen(Offset(pos.dx, pos.dy-1.5)), arrowSize*camera.scale, const Color.fromARGB(255, 0, 63, 95), canvas);
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

      if(data.selectedElemIndex >= 0){
        if(data.getElem(data.selectedElemIndex).isPainted){
          final path = Path();
          for(int j = 0; j < 4; j++){
            Offset pos = camera.worldToScreen(
              data.getElem(data.selectedElemIndex).nodeList[j].pos + data.getElem(data.selectedElemIndex).nodeList[j].becPos*data.dispScale);
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
      if(data.selectedElemIndex >= 0){
        if(data.getElem(data.selectedElemIndex).isPainted){
          MyPainter.text(canvas, camera.worldToScreen(data.getElem(data.selectedElemIndex).nodeList[0].pos + data.getElem(data.selectedElemIndex).nodeList[0].becPos*data.dispScale), 
            MyPainter.doubleToString(data.getSelectedResult(data.selectedElemIndex), 3), 14, Colors.black, true, size.width);
        }
      }
    }
  }

  // 要素の辺
  void _drawElemEdge(bool isAfter, Canvas canvas){
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 150, 150, 150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    if(data.elemListLength > 0){
      for(int i = 0; i < data.elemListLength; i++){
        if((data.getElem(i).isPainted && isAfter) || !isAfter){
          final path = Path();
          for(int j = 0; j < 4; j++){
            Offset pos;
            if(!isAfter){
              pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos);
            }else{
              pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos + data.getElem(i).nodeList[j].becPos*data.dispScale);
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

    for(int i = 0; i < data.elemListLength; i++){
      if(data.getElem(i).isPainted || data.pcController.getPixelColor(i).a != 0){
        if(isAfter && (data.selectedResultMax != 0 || data.selectedResultMin != 0)){
          paint.color = MyPainter.getColor((data.getSelectedResult(i) - data.selectedResultMin) / (data.selectedResultMax - data.selectedResultMin) * 100);
        }
        else if(!isAfter){
          if(data.getElem(i).isCanPaint){
            // paint.color = const Color.fromARGB(255, 184, 25, 63);
            paint.color = data.pcController.getPixelColor(i);
          }
          else{
            // paint.color = const Color.fromARGB(255, 106, 23, 43);
            paint.color = data.pcController.getPixelColor(i);
          }
        }

        final path = Path();
        for(int j = 0; j < 4; j++){
          Offset pos;
          if(!isAfter){
            pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos);
          }else{
            pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos + data.getElem(i).nodeList[j].becPos*data.dispScale);
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

  void _drawElemPaint(Canvas canvas, Size size){
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 49, 49, 49);

    for(int i = 0; i < data.elemListLength; i++){
      if(data.getElem(i).isCanPaint){
        paint.color = data.pcController.getPixelColor(i);
      }
      else{
        paint.color = data.pcController.getPixelColor(i);
      }

      final path = Path();
      for(int j = 0; j < 4; j++){
        Offset pos;
        pos = camera.worldToScreen(data.getElem(i).nodeList[j].pos);
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


  @override
  bool shouldRepaint(covariant BridgegamePainter oldDelegate) {
    return false;
  }
}