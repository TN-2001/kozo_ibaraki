import 'package:flutter/material.dart';
import '../../../constants/constant.dart';
import '../../../utils/camera.dart';
import '../models/bridgegame_controller.dart';
import 'bridgegane_painter.dart';
import 'ground.dart';
import 'sea.dart';

class BridgegameCanvas extends StatefulWidget {
  const BridgegameCanvas({super.key, required this.controller});

  final BridgegameController controller;

  @override
  State<BridgegameCanvas> createState() => _BridgegameCanvasState();
}

class _BridgegameCanvasState extends State<BridgegameCanvas> {
  late BridgegameController controller;
  final Camera camera = Camera(0,Offset.zero,Offset.zero); // カメラ

  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;



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

  Widget paintCanvas(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          _previousScale = _scale;
          _previousOffset = _offset;
          _lastFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount == 1) {
            // 指1本のとき = ペイント用の処理
            if (!controller.isCalculation) {
              controller.paintPixel(camera.screenToWorld(details.localFocalPoint));
            }
          } else if (details.pointerCount >= 2) {
            // 指2本以上 = ズーム + パン
            setState(() {
              _scale = (_previousScale * details.scale).clamp(1, 4.0);
              _offset = _previousOffset + (details.focalPoint - _lastFocalPoint);
              if (_offset.dx > 0) {
                _offset = Offset(0, _offset.dy);
              } else if (_offset.dx < -(width * _scale - width)) {
                _offset = Offset(-(width * _scale - width), _offset.dy);
              }
              if (_offset.dy > 0) {
                _offset = Offset(_offset.dx, 0);
              } else if (_offset.dy < -(height * _scale - height)) {
                _offset = Offset(_offset.dx, -(height * _scale - height));
              }
            });
          }
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
  void initState() {
    super.initState();
    controller = widget.controller;
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


        return ClipRect(
          child: Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
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
                paintCanvas(constraints.maxWidth, constraints.maxHeight),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}