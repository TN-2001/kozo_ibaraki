import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class BaseDivider extends StatelessWidget {
  const BaseDivider({
    super.key, 
    this.width = MyDimens.baseDividerWidth,
    this.margin = EdgeInsets.zero,
    this.color = MyColors.baseDivider,
    this.isVertivcal = false, 
  });

  final double width;
  final EdgeInsets margin;
  final Color color;
  final bool isVertivcal;

  @override
  Widget build(BuildContext context) {
    if (isVertivcal) {
      return Container(
        height: double.infinity,
        color: Colors.transparent,
        margin: margin,
        child: VerticalDivider(
          width: width,
          thickness: width,
          color: color,
        ),
      );
    }
    else {
      return Container(
        width: double.infinity,
        color: Colors.transparent,
        margin: margin,
        child: Divider(
          height: width,
          thickness: width,
          color: color,
        ),
      );
    }
  }
}