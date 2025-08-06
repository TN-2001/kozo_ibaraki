import 'package:flutter/material.dart';

import '../../constants/dimens.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    this.label,
    this.child,
  });

  final String? label;
  final Widget? child;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MyDimens.settingItemHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: MyDimens.baseSpacing,),
          Text(label ?? ""),
          
          const Expanded(child: SizedBox()),

          child ?? const SizedBox(),
        ],
      ),
    );
  }
}