import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/constant.dart';


class BaseTextField extends StatelessWidget {
  const BaseTextField({
    super.key, 
    this.width, 
    required this.onChanged, 
    required this.text,
    this.enabled = true,
  });

  final double? width;
  final void Function(String text) onChanged;
  final String text;
  final bool enabled;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: MyDimens.baseTextButtonHeight, // fontSize + contentPadding

      child: TextField(
        // デコレーション
        style: const TextStyle(
          fontSize: MyDimens.baseFontSize,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MyDimens.baseButtonBorderRadius),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: MyColors.baseBorder
            )
          ),

          isDense: true,
          contentPadding: const EdgeInsets.all(8),
        ),

        // 入力設定
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
        ],

        // OnOff
        enabled: enabled,

        // イベント
        onChanged: onChanged,
        controller: TextEditingController(text: text),
      ),
    );
  }
}