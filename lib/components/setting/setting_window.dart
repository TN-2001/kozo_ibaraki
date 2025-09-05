import 'package:flutter/material.dart';

import '../../constants/constant.dart';


class SettingWindow extends StatelessWidget {
  const SettingWindow({
    super.key, 
    required this.children,
    this.maxWidth,
  });

  final List<Widget> children;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? 500,
      ),
      padding: const EdgeInsets.all(MyDimens.baseSpacing),

      decoration: BoxDecoration(
        color: MyColors.baseBackground,
        borderRadius: BorderRadius.circular(MyDimens.settingWindowBorderRadius),
        border: Border.all(
          color: MyColors.baseBorder,
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          children[0],

          for (int i = 1; i < children.length; i++)...{
            const SizedBox(height: MyDimens.baseSpacing,),

            children[i],
          }
        ],
      ),
    );
  }


  static Widget scrolle({
    required List<Widget> children,
    double? maxWidth,
    double? maxHeight,
  }) {

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? 500,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: const EdgeInsets.all(MyDimens.baseSpacing),

      decoration: BoxDecoration(
        color: MyColors.baseBackground,
        borderRadius: BorderRadius.circular(MyDimens.settingWindowBorderRadius),
        border: Border.all(
          color: MyColors.baseBorder,
        ),
      ),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            children[0],

            for (int i = 1; i < children.length; i++)...{
              const SizedBox(height: MyDimens.baseSpacing,),

              children[i],
            }
          ],
        ),
      ),
    );
  }
}