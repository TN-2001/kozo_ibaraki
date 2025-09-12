import 'package:flutter/material.dart';

import '../../constants/constant.dart';

class BaseCheckbox extends StatelessWidget {
  const BaseCheckbox({super.key, required this.onChanged, required this.value});

  final void Function(bool? value) onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyDimens.baseCheckboxSize,
      height: MyDimens.baseCheckboxSize,

      child: Checkbox(
        value: value, 
        onChanged: onChanged
      ),
    );
  }
}