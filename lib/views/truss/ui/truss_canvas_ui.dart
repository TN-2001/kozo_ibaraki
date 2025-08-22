import 'package:flutter/material.dart';
import '../../../components/component.dart';
import '../../../components/my_painter.dart';
import '../../../constants/constant.dart';
import '../models/truss_data.dart';

class TrussCanvasUi extends StatefulWidget {
  const TrussCanvasUi({super.key, required this.controller});

  final TrussData controller;

  @override
  State<TrussCanvasUi> createState() => _TrussCanvasUiState();
}

class _TrussCanvasUiState extends State<TrussCanvasUi> {
  late TrussData _controller;


  Widget landscapeColorContour() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                BaseText(
                  MyPainter.doubleToString(_controller.resultMax, 3),
                  isStroke: true,
                ),

                const SizedBox(height: MyDimens.baseSpacing,),

                Expanded(
                  child: Container(
                    height: double.infinity,
                    width: 30,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 255, 0, 0),
                          Color.fromARGB(255, 255, 255, 0),
                          Color.fromARGB(255, 0, 255, 0),
                          Color.fromARGB(255, 0, 255, 255),
                          Color.fromARGB(255, 0, 0, 255),
                        ]
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: MyDimens.baseSpacing,),

                BaseText(
                  MyPainter.doubleToString(_controller.resultMin, 3),
                  isStroke: true,
                ),
              ],
            ),

            const SizedBox(width: MyDimens.baseSpacing * 2,),
          ]
        ),
      ),
    );
  }

  Widget portraitColorContour() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                BaseText(
                  MyPainter.doubleToString(_controller.resultMax, 3),
                  isStroke: true,
                ),

                const SizedBox(width: MyDimens.baseSpacing,),

                Expanded(
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Color.fromARGB(255, 255, 0, 0),
                          Color.fromARGB(255, 255, 255, 0),
                          Color.fromARGB(255, 0, 255, 0),
                          Color.fromARGB(255, 0, 255, 255),
                          Color.fromARGB(255, 0, 0, 255),
                        ]
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: MyDimens.baseSpacing,),

                BaseText(
                  MyPainter.doubleToString(_controller.resultMin, 3),
                  isStroke: true,
                ),
              ],
            ),

            const SizedBox(height: MyDimens.baseSpacing * 2,),
          ]
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(MyDimens.baseSpacing * 2),
        child: Stack(
          children: [
            if (_controller.isCalculation && _controller.resultIndex <= 2)...{
              if (orientation == Orientation.landscape)...{
                landscapeColorContour(),
              }
              else...{
                portraitColorContour(),
              }
            }
          ],
        )
      ),
    );
  }
}