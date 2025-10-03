import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/truss/canvas/truss_painter.dart';
import 'package:kozo_ibaraki/app/pages/truss/models/truss_data.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'package:kozo_ibaraki/core/utils/camera.dart';


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
        return Container(
          width: width,
          height: height,
          color: MyColors.canvasBackground,
          child: BaseZoomableWidget(
            child: SizedBox(
              width: width,
              height: height,
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
            ),
          ),
        );
      },
    );
  }
}