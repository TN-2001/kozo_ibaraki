import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseDialog extends StatelessWidget {
  BaseDialog({
    super.key,
    required this.child,
    this.constraints = BaseDimens.dialogConstraints,
    this.padding = EdgeInsets.zero,
    BorderRadius? borderRadius, 
    this.backgroundColor = BaseColors.dialogBackground,
  }) : borderRadius = borderRadius ?? BaseDimens.dialogBorderRadius;

  final Widget child;
  final BoxConstraints constraints; 
  final EdgeInsets padding; 
  final BorderRadius borderRadius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      backgroundColor: backgroundColor,

      child: Container(
        constraints: constraints,
        padding: padding,
        child: child,
      ),
    );
  }
}