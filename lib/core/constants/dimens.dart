/*
  寸法を定義する。
  Define dimensions here.
*/

import 'package:flutter/material.dart';

class MyDimens {
  static const double baseDividerWidth = 0.0; // 線の幅
  static const double baseFontSize = 16.0; // 文字の大きさ
  static const double baseSpacing = 4.0;
  static const double baseButtonBorderRadius = 4.0;
  static const double baseTextButtonHeight = 32.0;
  static const double baseCheckboxSize = 24.0;

  static const double toolBarWidth = 52.0;
  static const double toolBarHeight = 52.0;
  static const double toolBarSpacing = 4.0;
  static const double toolBarDividerWidth = 0.0;
  static const double toolBarDividerIndent = 1.0;

  static const double toolButtonWidth = toolBarWidth - toolBarSpacing * 2;
  static const double toolButtonHeight = toolBarHeight - toolBarSpacing * 2;
  static const double toolButtonBorderWidth = 0.0;
  static const double toolButtonBorderRadius = 0.0; // ボタンの角の丸み

  static const double toolDropdownElevation = 8.0; // 影の大きさ
  static const double toolDropdownBorderWidth = 0.0;
  static const double toolDropdownBorderRadius = 8.0; // ウィンドウの角の丸み
  static const double toolDropdownItemHeight = 48.0; // テキストボタンの高さ
  static const double toolDropdownItemFontSize = 16.0;

  static const double settingWindowBorderRadius = 4.0;
  static const double settingItemHeight = baseTextButtonHeight;
  static const int settingItemFieldFlex = 2;
}

class BaseDimens {
  static const double fontSize = 16.0;
  static const double titleFontSize = 20.0;
  static const double spacing = 8.0;
  static const EdgeInsets padding = EdgeInsets.all(spacing);

  static const double barWidth = 52.0;
  static const double barHeight = 52.0;
  static const double barSpacing = 4.0;

  static const double dividerWidth = 0.0;
  static const EdgeInsets dividerMargin = EdgeInsets.zero;

  static const double buttonWidth = barWidth - barSpacing * 2;
  static const double buttonHeight = barHeight - barSpacing * 2;
  static const double buttonBorderWidth = 0.0;
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(10);
  static const EdgeInsets buttonTextPadding = EdgeInsets.only(left: 16, right: 16);

  static const BoxConstraints dialogConstraints = BoxConstraints(maxWidth: 700, maxHeight: 600,);
  static final BorderRadius dialogBorderRadius = buttonBorderRadius;
}

class ToolDimens {
  static const double fontSize = 16.0;

  static const double barWidth = 52.0;
  static const double barHeight = 52.0;
  static const double barSpacing = 4.0;

  static const double dividerWidth = 0.0;
  static const EdgeInsets dividerMargin = EdgeInsets.only(left: barSpacing, right: barSpacing, top: 1.0, bottom: 1.0);

  static const double buttonWidth = barWidth - barSpacing * 2;
  static const double buttonHeight = barHeight - barSpacing * 2;
  static const double buttonBorderWidth = 0.0;

  static const double dropdownElevation = 8.0; // 影の大きさ
  static const double dropdownBorderWidth = 0.0;
  static const double dropdownBorderRadius = 8.0; // ウィンドウの角の丸み
  static const double dropdownItemHeight = 48.0; // テキストボタンの高さ
  static const double dropdownItemFontSize = 16.0;
}