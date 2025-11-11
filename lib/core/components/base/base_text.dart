import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseText extends StatelessWidget {
  const BaseText(
    this.text, {
    super.key,
    this.isStroke = false,
    this.color = BaseColors.font,
    this.strokeColor = Colors.white,
    this.fontSize = BaseDimens.fontSize,
    this.fontWeight = BaseDimens.fontWeight,
    this.fontSpacing = BaseDimens.fontSpacing,
    this.strokeWidth = 3.0,
    this.margin = EdgeInsets.zero,
  });

  final String text;
  final bool isStroke;
  final Color? color;
  final Color? strokeColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? fontSpacing;
  final double? strokeWidth;
  final EdgeInsets? margin;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        children: [
          if (isStroke)
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                letterSpacing: fontSpacing,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth!
                  ..color = strokeColor!,
              ),
            ),

          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: fontSpacing,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Widget title(String text, {EdgeInsets? margin}) {
    return BaseText(
      text,
      margin: margin,
      fontSize: BaseDimens.titleFontSize,
      fontWeight: BaseDimens.titleFontWeight,
      fontSpacing: BaseDimens.titleFontSpacing,
    );
  }
}