import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/components/zoomable_gesture_paint.dart';
import 'package:kozo_ibaraki/app/pages/beam/models/beam_data.dart';
import 'beam_painter.dart';


class BeamCanvas extends StatelessWidget {
  const BeamCanvas({super.key, required this.controller, required this.devTypeNum, required this.isSumaho});

  final BeamData controller;
  final int devTypeNum;
  final bool isSumaho;

  @override
  Widget build(BuildContext context) {
    return ZoomableGesturePaint(
      onTapUp: (details) {
        if(!controller.isCalculation){
          if(controller.toolIndex == 1){
            if(controller.typeIndex == 0){
              controller.selectNode(details.localPosition);
            }
            else if(controller.typeIndex == 1){
              controller.selectElem(details.localPosition);
            }
          }
        }
      },
      painter: BeamPainter(data: controller, devTypeNum: devTypeNum, isSumaho: isSumaho),
    );
  }
}


