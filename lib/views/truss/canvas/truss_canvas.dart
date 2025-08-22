import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../utils/camera.dart';
import '../models/truss_data.dart';
import 'truss_painter.dart';


class TrussCanvas extends StatefulWidget {
  const TrussCanvas({super.key, required this.controller});

  final TrussData controller;

  @override
  State<TrussCanvas> createState() => _TrussCanvasState();
}

class _TrussCanvasState extends State<TrussCanvas> {
  late TrussData _controller;
  final Camera _camera = Camera(1, Offset.zero, Offset.zero);


  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        // final double worldWidth = _controller.rect.width;
        // final double worldHeight = _controller.rect.height;

        // double scale = 1.0;
        // if (width / worldWidth < height / worldHeight) {
        //   // 横幅に合わせる
        //   scale = width / worldWidth / 2;
        // } else {
        //   // 高さに合わせる
        //   scale = height / worldHeight / 2;
        // }

        // // カメラの初期化
        // _camera.init(
        //   scale,
        //   _controller.rect.center,
        //   Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
        // );

        return Container(
          width: width,
          height: height,
          color: MyColors.canvasBackground,
          child: GestureDetector(
            onTapUp: (details) {
              if(!_controller.isCalculation){
                if(_controller.toolIndex == 1){
                  if(_controller.typeIndex == 0){
                    _controller.selectNode(_camera.screenToWorld(details.localPosition));
                  }
                  else if(_controller.typeIndex == 1){
                    _controller.selectElem(_camera.screenToWorld(details.localPosition));
                  }
                }
              }
            },
            child: CustomPaint(
              painter: TrussPainter(data: _controller, camera: _camera),
            ),
          ),
        );
      },
    );
  }
}