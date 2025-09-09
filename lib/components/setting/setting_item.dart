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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label ?? "",
                  style: const TextStyle(
                    fontSize: MyDimens.baseFontSize,
                  )
                ),
              ),
            ),
          ),
          
          Expanded(
            flex: fieldFlex ?? MyDimens.settingItemFieldFlex,
            child: child ?? const SizedBox(),
          ),
        ],
      ),
    );
  }

  static Widget labelFit({String? label, Widget? child}) {
    return SizedBox(
      height: MyDimens.settingItemHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.only(
                  left: MyDimens.baseSpacing,
                  right: MyDimens.baseSpacing,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: MyDimens.baseFontSize,
                    )
                  ),
                ),
              ),
            ),
          ],
          
          child ?? const SizedBox(),
        ],
      ),
    );
  }

  static Widget labelNotFit({String? label, Widget? child}) {
    return SizedBox(
      height: MyDimens.settingItemHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (label != null) ...[
            Container(
              padding: const EdgeInsets.only(
                left: MyDimens.baseSpacing,
                right: MyDimens.baseSpacing,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: MyDimens.baseFontSize,
                )
              ),
            ),
          ],
          
          Expanded(
            child: child ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}