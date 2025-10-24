import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'tool_text.dart';

class ToolTextButton extends StatelessWidget {
  const ToolTextButton({super.key, required this.text, required this.onPressed, this.iconData, });

  final String text;
  final IconData? iconData;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        fixedSize: const Size.fromHeight(MyDimens.toolButtonHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // 👈 角を丸くしない（完全な四角）
        ),
      ),

      onPressed: onPressed, 
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToolText(text),
          if (iconData != null)
            Icon(
              iconData,
              size: 25,
            ),
        ],
      ),
    );
  }
}