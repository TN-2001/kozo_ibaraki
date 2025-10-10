import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    this.label,
    this.child,
    this.fieldFlex,
    this.enabled = true,
  });

  final String? label;
  final Widget? child;
  final int? fieldFlex;
  final bool enabled;


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
                  style: TextStyle(
                    fontSize: MyDimens.baseFontSize,
                    color: enabled == true ? MyColors.baseText : MyColors.baseTextDisabled,
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

  static Widget labelFit({String? label, Widget? child, bool enabled = true}) {
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
                    style: TextStyle(
                      fontSize: MyDimens.baseFontSize,
                      color: enabled == true ? MyColors.baseText : MyColors.baseTextDisabled,
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

  static Widget labelNotFit({String? label, Widget? child, bool enabled = true}) {
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
                style: TextStyle(
                  fontSize: MyDimens.baseFontSize,
                  color: enabled == true ? MyColors.baseText : MyColors.baseTextDisabled,
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