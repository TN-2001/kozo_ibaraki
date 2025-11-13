import 'package:flutter/material.dart';

import '../../constants/constant.dart';


class BaseTextField extends StatefulWidget {
  const BaseTextField({
    super.key, 
    this.width, 
    required this.onChanged, 
    this.onSubmitted,
    required this.text,
    this.enabled = true,
    this.keyboardType = TextInputType.number,
  });

  final double? width;
  final void Function(String text) onChanged;
  final void Function(String text)? onSubmitted;
  final String text;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  State<BaseTextField> createState() => _BaseTextFieldState();
}

class _BaseTextFieldState extends State<BaseTextField> {
  late double? width;
  late void Function(String text) onChanged;
  late void Function(String text)? onSubmitted;
  late String text;
  late bool enabled;
  late TextInputType? keyboardType;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    width = widget.width;
    onChanged = widget.onChanged;
    onSubmitted = widget.onSubmitted;
    text = widget.text;
    enabled = widget.enabled;
    keyboardType = widget.keyboardType;

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          
        });
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }


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