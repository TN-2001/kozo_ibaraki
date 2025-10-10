import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/components/zoomable_gesture_paint.dart';
import 'package:kozo_ibaraki/app/pages/fem/canvas/fem_painter.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_data.dart';
import 'package:kozo_ibaraki/core/utils/camera.dart';


class FemCanvas extends StatefulWidget {
  const FemCanvas({super.key, required this.controller});

  final FemData controller;

  @override
  State<FemCanvas> createState() => _FemCanvasState();
}

class _FemCanvasState extends State<FemCanvas> {
  late FemData _controller;
  final Camera _camera = Camera(1, Offset.zero, Offset.zero);


  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return ZoomableGesturePaint(
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
      painter: FemPainter(controller: _controller, camera: _camera),
    );
  }
}