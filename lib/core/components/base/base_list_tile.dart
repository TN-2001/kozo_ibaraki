import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseListTile extends StatelessWidget {
  BaseListTile({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.selected = false,
    this.margin = EdgeInsets.zero,
    BorderRadius? borderRadius,
    this.borderWidth = BaseDimens.buttonBorderWidth,
    this.borderColor = BaseColors.buttonBorder,
    this.contentPadding = BaseDimens.buttonContentPadding
  }) : borderRadius = borderRadius ?? BaseDimens.buttonBorderRadius;

  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final void Function()? onTap;
  final bool? enabled;
  final bool? selected;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final EdgeInsets? contentPadding;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,

      child: ListTile(
        leading: leading,
        title: title,
        trailing: trailing,
        onTap: onTap,

        enabled: enabled!,
        selected: selected!,

        minTileHeight: BaseDimens.buttonHeight,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: borderColor!,
            width: borderWidth!,
          ),
          borderRadius: borderRadius!,
        ),
        contentPadding: contentPadding,
        titleTextStyle: const TextStyle(
          fontSize: BaseDimens.fontSize,
          fontWeight: BaseDimens.fontWeight,
          letterSpacing: BaseDimens.fontSpacing,
        ),
        iconColor: BaseColors.buttonContent,
        textColor: BaseColors.buttonContent,
        selectedColor: BaseColors.buttonContent,
        selectedTileColor: BaseColors.buttonHover,
      ),
    );
  }
}