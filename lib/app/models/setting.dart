class Setting {
  Setting._(); // インスタンス化禁止（staticクラス風）

  static const double minAbs = 1e-9; // この値以下の結果は0に
  
  static bool _isNodeNumber = true;
  static bool _isElemNumber = true;
  static bool _isResultValue = true;


  static bool get isNodeNumber => _isNodeNumber;
  static bool get isElemNumber => _isElemNumber;
  static bool get isResultValue => _isResultValue;

  static void setIsNodeNumber(bool value) => _isNodeNumber = value;
  static void setIsElemNumber(bool value) => _isElemNumber = value;
  static void setIsResultValue(bool value) => _isResultValue = value;
}