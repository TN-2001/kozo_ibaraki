import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseIconButton extends StatelessWidget {
  BaseIconButton({ 
    super.key, 
    required this.onPressed, 
    required this.icon, 
    this.tooltip = "",
    this.width = BaseDimens.buttonWidth,
    this.height = BaseDimens.buttonHeight,
    this.margin = EdgeInsets.zero,
    BorderRadius? borderRadius,
    this.borderColor = BaseColors.buttonBorder,
    this.borderWidth = BaseDimens.buttonBorderWidth,
  }) : borderRadius = borderRadius ?? BaseDimens.buttonBorderRadius;

  final void Function() onPressed;
  final Widget icon;
  final String tooltip;
  final double width;
  final double height;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      // デザイン
      width: width,
      height: height,
      margin: margin,

      
      child: IconButton(
        // デザイン
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
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