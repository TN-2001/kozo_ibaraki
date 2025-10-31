import 'package:flutter/material.dart';

class BaseText extends StatelessWidget {
  const BaseText(
    this.text, {
    super.key,
    this.isStroke = false,
    this.color = Colors.black,
    this.strokeColor = Colors.white,
    this.fontSize = 16,
    this.strokeWidth = 3.0,
    this.margin = EdgeInsets.zero,
  });

  final String text;
  final bool isStroke;
  final Color color;
  final Color strokeColor;
  final double fontSize;
  final double strokeWidth;
  final EdgeInsets margin;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        children: [
          if (isStroke)...{
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = strokeColor,
              ),
            ),
          },

          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}