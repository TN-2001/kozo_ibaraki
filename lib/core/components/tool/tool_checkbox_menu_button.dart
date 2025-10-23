import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class ToolCheckboxMenuButton extends StatelessWidget {
  const ToolCheckboxMenuButton({super.key, required this.value, required this.onChanged, required this.text});

  final bool value;
  final void Function(bool value) onChanged;
  final String text;

  @override
  Widget build(BuildContext context) {
    return CheckboxMenuButton(
      style: MenuItemButton.styleFrom(
        backgroundColor: Colors.white,
        fixedSize: const Size.fromHeight(MyDimens.toolButtonHeight),
      ),
      value: value,
      onChanged: (bool? value) {
        if (value != null) {
          onChanged(value);
        }
      },
      child: Text(text),
    );
  }
}