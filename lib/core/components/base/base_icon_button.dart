import 'package:flutter/material.dart';

class BaseIconButton extends StatelessWidget {
  const BaseIconButton({ 
    super.key, 
    required this.onPressed, 
    required this.icon, 
    this.message = "",
    this.width = 50,
    this.height = 50,
    this.margin = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
  });

  final void Function() onPressed;
  final Widget icon;
  final String message;
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

      child: Tooltip(
        message: message,
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
          // イベント
          onPressed: onPressed, 
          // ウィジェット
          icon: icon,
        ),
      ),
    );
  }
}