import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/components/zoomable_gesture_paint.dart';
import 'package:kozo_ibaraki/app/pages/frame/models/frame_controller.dart';
import 'package:kozo_ibaraki/app/pages/frame/canvas/frame_painter.dart';
import 'package:kozo_ibaraki/core/utils/camera.dart';

class FrameCanvas extends StatefulWidget {
  const FrameCanvas({super.key, required this.controller});

  final FrameController controller;

  @override
  State<FrameCanvas> createState() => _FrameCanvasState();
}

class _FrameCanvasState extends State<FrameCanvas> {
  late FrameController _controller;
  final Camera _camera = Camera(1, Offset.zero, Offset.zero);

  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }


  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
    _controller.data.addListener(_onUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return ZoomableGesturePaint(
      onTapUp: (details) {
        if(!_controller.isCalculated){
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
      painter: FramePainter(controller: _controller, camera: _camera),
    );
  }
}