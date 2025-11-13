import 'package:flutter/material.dart';

import '../../constants/constant.dart';


class BaseTextField extends StatelessWidget {
  BaseTextField({
    super.key, 
    this.width, 
    required this.onChanged, 
    this.onSubmitted,
    this.onUnFocus,
    required this.text,
    this.enabled = true,
    this.keyboardType = TextInputType.number,
  }) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus && onUnFocus != null) {
        onUnFocus!();
      }
    });
  }

  final double? width;
  final void Function(String text) onChanged;
  final void Function(String text)? onSubmitted;
  final void Function()? onUnFocus;
  final String text;
  final bool enabled;
  final TextInputType? keyboardType;

  final FocusNode focusNode = FocusNode();


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: MyDimens.baseTextButtonHeight, // fontSize + contentPadding

      child: TextField(
        // デコレーション
        style: const TextStyle(
          fontSize: BaseDimens.fontSize,
          fontWeight: BaseDimens.fontWeight,
          letterSpacing: BaseDimens.fontSpacing,
          color: BaseColors.font,
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

        // スマホのキーボード設定
        keyboardType: keyboardType, 
        // 入力制限
        // inputFormatters: [ 
        //   FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
        // ],

        // OnOff
        enabled: enabled,

        focusNode: focusNode,

        // イベント
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        controller: TextEditingController(text: text),
      ),
    );
  }
}