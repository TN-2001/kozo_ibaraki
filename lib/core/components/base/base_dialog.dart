import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseDialog extends StatelessWidget {
  BaseDialog({
    super.key,
    BorderRadius? borderRadius, 
    this.backgroundColor = BaseColors.dialogBackground,
  }) : borderRadius = borderRadius ?? BaseDimens.dialogBorderRadius;

  final BorderRadius borderRadius;
  final Color backgroundColor;
  // final 

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      backgroundColor: backgroundColor,

      child: Container(
        // constraints: BoxConstraints(),
      ),
    );
  }
}