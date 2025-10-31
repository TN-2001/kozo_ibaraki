import 'dart:math';

class StringUtils {
  // doubleをStringにする
  static String doubleToString(double value, int digit, {double? minAbs}) {
    if (minAbs != null) {
      if (value.abs() < minAbs) {
        value = 0.0;
      }
    }

    // 数字を桁数(digit)分を文字にする
    String text;
    if(value == 0.0) {
      text = " 0";
    } else if(value.abs() >= 1.0 * pow(10, -(digit-1))) {
      text = value.toStringAsPrecision(digit);
    } else {
      text = value.toStringAsExponential(digit-1);
    }

    // -の分のスペースを開ける
    if(value > 0) {
      text = " $text";
    }

    return text;
  }
}