import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class ZoomableGesturePaint extends StatelessWidget {
  const ZoomableGesturePaint({super.key, required this.painter, this.onTapUp});

  final CustomPainter painter;
  final Function(TapUpDetails)? onTapUp;

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
                  if(onTapUp != null){
                    onTapUp!(details);
                  }
                },
                child: CustomPaint(
                  painter: painter,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}