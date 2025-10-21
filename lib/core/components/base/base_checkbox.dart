import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class BaseCheckbox extends StatelessWidget {
  const BaseCheckbox({super.key, required this.onChanged, required this.value, this.enabled = true});

  final void Function(bool? value) onChanged;
  final bool value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MyDimens.baseCheckboxSize,
      height: MyDimens.baseCheckboxSize,

      
      child: enabled ? Checkbox(
        value: value, 
        onChanged: onChanged
      ) : Checkbox(
        value: value, 
        onChanged: null
      )
    );
  }
}