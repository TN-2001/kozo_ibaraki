import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import '../base/base_icon_button.dart';

class ToolIconButton extends StatelessWidget {
  const ToolIconButton({
    super.key, 
    required this.onPressed, 
    required this.icon, 
    this.message = "",
  });

  final void Function() onPressed;
  final Widget icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      onPressed: onPressed, 
      icon: icon,
      tooltip: message,
      width: ToolDimens.buttonWidth,
      borderWidth: ToolDimens.buttonBorderWidth,
      borderColor: ToolColors.buttonBorder,
    );
  }
}