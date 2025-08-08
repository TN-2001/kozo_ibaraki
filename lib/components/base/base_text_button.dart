import 'package:flutter/material.dart';

import '../../constants/constant.dart';

class BaseTextButton extends StatelessWidget {
  const BaseTextButton({super.key, required this.onPressed, required this.text});

  final void Function() onPressed;
  final String text; 

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed, 

      style: TextButton.styleFrom(
        side: const BorderSide(
          color: MyColors.baseBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MyDimens.baseButtonBorderRadius),
        ),

        padding: const EdgeInsets.all(0),
        textStyle: const TextStyle(
          fontSize: MyDimens.baseFontSize,
          letterSpacing: 0,
          fontWeight: FontWeight.normal,
        ),
        foregroundColor: Colors.black,
      ),

      child: Text(
        text,
      ),
    );
  }
}