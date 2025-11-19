import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/models/bridgegame_controller.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BridgegameCanvasUi extends StatefulWidget {
  const BridgegameCanvasUi({super.key, required this.controller});

  final BridgegameController controller;

  @override
  State<BridgegameCanvasUi> createState() => _BridgegameCanvasUiState();
}

class _BridgegameCanvasUiState extends State<BridgegameCanvasUi> {
  late BridgegameController _controller;

  Widget landscapeColorContour() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Column(
            children: [
              const BaseText(
                "大",
                isStroke: true,
              ),
              const SizedBox(
                height: MyDimens.baseSpacing,
              ),
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
                        ]),
                  ),
                ),
              ),
              const SizedBox(
                height: MyDimens.baseSpacing,
              ),
              const BaseText(
                "小",
                isStroke: true,
              ),
            ],
          ),
          const SizedBox(
            width: MyDimens.baseSpacing,
          ),
          const BaseText(
            "引\n張\nの\n力",
            isStroke: true,
          ),
        ]),
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              const BaseText(
                "大",
                isStroke: true,
              ),
              const SizedBox(
                width: MyDimens.baseSpacing,
              ),
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
                        ]),
                  ),
                ),
              ),
              const SizedBox(
                width: MyDimens.baseSpacing,
              ),
              const BaseText(
                "小",
                isStroke: true,
              ),
            ],
          ),
          const SizedBox(
            height: MyDimens.baseSpacing,
          ),
          const BaseText(
            "引張の力",
            isStroke: true,
          ),
        ]),
      ),
    );
  }

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.pcController.addListener(_update);
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_controller.isCalculation) ...{
                    BaseText(
                      "${_controller.resultPoint.toStringAsFixed(2)}点",
                      isStroke: true,
                      fontSize: 32,
                    ),
                  },
                  BaseText(
                    "体積：${_controller.onElemListLength}",
                    isStroke: true,
                    fontSize: MyDimens.baseFontSize,
                  ),
                ],
              ),
              if (_controller.isCalculation) ...{
                if (orientation == Orientation.landscape) ...{
                  landscapeColorContour(),
                } else ...{
                  portraitColorContour(),
                }
              }
            ],
          )),
    );
  }
}
