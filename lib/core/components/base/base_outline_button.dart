import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseOutlineButton extends StatelessWidget {
  BaseOutlineButton({
    super.key, 
    required this.onPressed, 
    required this.label,
    this.icon,
    this.enabled = true,
    this.height = BaseDimens.buttonHeight,
    this.constraints = const BoxConstraints(minWidth: double.infinity),
    this.margin = EdgeInsets.zero,
    this.labelPadding = BaseDimens.buttonTextPadding,
    BorderRadius? borderRadius,
    this.borderWidth = BaseDimens.buttonBorderWidth,
    this.borderColor = BaseColors.buttonBorder,
    this.foregroundColor = BaseColors.buttonForegroundColor,
    this.backgroundColor = BaseColors.buttonBackground,
    this.overlayColor = BaseColors.buttonOverlayColor,
  }) : borderRadius = borderRadius ?? BaseDimens.buttonBorderRadius ;

  final void Function() onPressed;
  final Widget label;
  final Widget? icon;
  final bool enabled;
  final double? height;
  final BoxConstraints constraints;
  final EdgeInsets margin;
  final EdgeInsets labelPadding;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      constraints: constraints,

      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,

        style: ButtonStyle(
          side: WidgetStatePropertyAll(
            BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: borderRadius
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(enabled ? backgroundColor : overlayColor),
          overlayColor: WidgetStatePropertyAll(enabled ? overlayColor : Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(foregroundColor),

          alignment: Alignment.centerLeft,
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        ), 

        child: Row(
          children: [
            if (icon != null)
            SizedBox(
              width: height,
              height: height,
              child: icon!,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: icon == null ? labelPadding.left : 0,
                right: labelPadding.right,
              ),
              child: label,
            ),
          ],
        ),
      ),
    );
  }
}