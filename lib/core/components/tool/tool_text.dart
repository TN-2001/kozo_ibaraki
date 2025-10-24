import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import '../base/base_text.dart';

class ToolText extends StatelessWidget {
  const ToolText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text,
      fontSize: ToolDimens.fontSize,
    );
  }
}