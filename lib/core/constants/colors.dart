import 'package:flutter/material.dart';
/*
  色を定義する。
  Define colors here.
*/

class MyColors {
  static const Color baseBackground = Color.fromARGB(255, 255, 255, 255);
  static const Color baseDivider = Color.fromARGB(255, 200, 200, 200);
  static const Color baseBorder = Color.fromARGB(255, 200, 200, 200);
  static const Color baseText = Color.fromARGB(255, 0, 0, 0);
  static const Color baseTextDisabled = Color.fromARGB(100, 0, 0, 0);

  static const Color toolBarBackground = Color.fromARGB(255, 255, 255, 255);
  static const Color toolBarDivider = Color.fromARGB(255, 235, 235, 235);

  static const Color toolButtonBackground = toolBarBackground;
  static const Color toolButtonBorder = Color.fromARGB(0, 245, 245, 245);

  static const Color toolDropdownBackground = toolBarBackground;

  static const Color canvasBackground = Color.fromARGB(255, 235, 235, 235);
}

class BaseColors {
  static const Color drawerBackground = Colors.white;

  static const Color dialogBackground = Colors.white;
  
  static const Color buttonBackground = Colors.transparent;
  static const Color buttonBorder = Colors.transparent;
  static const Color buttonForegroundColor = Color.fromARGB(255, 75, 75, 75);
  static const Color buttonOverlayColor = Color(0x14000000);
}

class ToolColors {
  static const Color toolBarBackground = Color.fromARGB(255, 255, 255, 255);
  
  static const Color divider = Color.fromARGB(255, 235, 235, 235);

  static const Color buttonBackground = Colors.transparent;
  static const Color buttonBorder = Colors.transparent;

  static const Color toolDropdownBackground = toolBarBackground;
}
