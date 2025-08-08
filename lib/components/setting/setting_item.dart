import 'package:flutter/material.dart';

import '../../constants/dimens.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    this.label,
    this.child,
    this.fieldFlex,
  });

  final String? label;
  final Widget? child;
  final int? fieldFlex;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MyDimens.settingItemHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(
                left: MyDimens.baseSpacing,
                right: MyDimens.baseSpacing,
              ),
              child: Text(
                label ?? "",
                style: const TextStyle(
                  fontSize: MyDimens.baseFontSize,
                )
              ),
            ),
          ),
          
          Expanded(
            flex: fieldFlex ?? 3,
            child: child ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}