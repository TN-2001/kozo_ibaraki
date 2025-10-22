import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class ColorContour extends StatelessWidget {
  const ColorContour({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  static Widget landscape({String maxText = "", String minText = ""}) {
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
                  maxText,
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
                  minText,
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

  static Widget portrait({String maxText = "", String minText = ""}) {
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
                  maxText,
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
                  minText,
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
}