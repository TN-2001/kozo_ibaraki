import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/beam/models/beam_data.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/colors.dart';
import 'beam_painter.dart';


class BeamCanvas extends StatelessWidget {
  const BeamCanvas({super.key, required this.controller, required this.devTypeNum, required this.isSumaho});

  final BeamData controller;
  final int devTypeNum;
  final bool isSumaho;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: MyColors.canvasBackground,
          child: BaseZoomableWidget(
            child: SizedBox(
              width: width,
              height: height,
              child: GestureDetector(
                onTapDown: (details) {
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
                child: CustomPaint(
                  painter: BeamPainter(data: controller, devTypeNum: devTypeNum, isSumaho: isSumaho),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}


