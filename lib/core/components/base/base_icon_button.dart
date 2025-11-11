import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseIconButton extends StatelessWidget {
  BaseIconButton({ 
    super.key, 
    required this.onPressed, 
    required this.icon, 
    this.tooltip = "",
    this.width = BaseDimens.buttonWidth,
    this.margin = EdgeInsets.zero,
    BorderRadius? borderRadius,
    this.borderWidth = BaseDimens.buttonBorderWidth,
    this.borderColor = BaseColors.buttonBorder,
    this.foregroundColor = BaseColors.buttonContent,
    this.overlayColor = BaseColors.buttonHover,
  }) : borderRadius = borderRadius ?? BaseDimens.buttonBorderRadius;

  final void Function() onPressed;
  final Widget icon;
  final String? tooltip;
  final double? width;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      // デザイン
      width: width,
      height: width,
      margin: margin,

      
      child: IconButton(
        // デザイン
        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(
              color: borderColor!,
              width: borderWidth!,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: borderRadius!
            ),
          ),
          iconSize: const WidgetStatePropertyAll(BaseDimens.iconSize),
          overlayColor: WidgetStatePropertyAll(overlayColor),
          foregroundColor: WidgetStatePropertyAll(foregroundColor),
        ),

        tooltip: tooltip,
        // イベント
        onPressed: onPressed, 
        // ウィジェット
        icon: icon,
      ),
    );
  }
}