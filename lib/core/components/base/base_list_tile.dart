import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseListTile extends StatelessWidget {
  BaseListTile({
    super.key,
    this.leading,
    this.title,
    this.onTap,
    this.enabled = true,
    this.selected = false,
    this.margin = EdgeInsets.zero,
    BorderRadius? borderRadius,
    this.borderWidth = BaseDimens.buttonBorderWidth,
    this.borderColor = BaseColors.buttonBorder,
  }) : borderRadius = borderRadius ?? BaseDimens.buttonBorderRadius;

  final Widget? leading;
  final Widget? title;
  final void Function()? onTap;
  final bool enabled;
  final bool selected;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,

      child: ListTile(
        leading: leading,
        title: title,
        onTap: onTap,

        enabled: enabled,
        selected: selected,

        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: borderRadius,
        ),
        iconColor: BaseColors.buttonForegroundColor,
        textColor: BaseColors.buttonForegroundColor,
        selectedColor: BaseColors.buttonForegroundColor,
        selectedTileColor: BaseColors.buttonOverlayColor,
        contentPadding: BaseDimens.buttonContentPadding,
      ),
    );
  }
}