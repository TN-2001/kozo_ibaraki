import 'package:flutter/material.dart';

class BaseText extends StatelessWidget {
  const BaseText(
    this.text, {
    super.key,
    this.isStroke = false,
    this.color,
    this.strokeColor,
    this.fontSize,
    this.strokeSize,
  });

  final String text;
  final bool isStroke;
  final Color? color;
  final Color? strokeColor;
  final double? fontSize;
  final double? strokeSize;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isStroke)...{
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeSize ?? 3
                ..color = strokeColor ?? Colors.white,
            ),
          ),
        },

        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}