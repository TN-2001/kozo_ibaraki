import 'package:kozo_ibaraki/app/pages/bridgegame/models/bridgegame_controller.dart';

class BridgegameFreeController extends BridgegameController {
  BridgegameFreeController();

  /*
    パラメータ
  */
  final int _gridWidth = 100; // グリッド幅
  final int _gridHeight = 36; // グリッド高さ
  final int _powerIndex = 2;

  /*
    ゲッター
  */
  @override
  int get gridWidth => _gridWidth;
  @override
  int get gridHeight => _gridHeight;
  @override
  int get powerIndex => _powerIndex;

  /*
    関数
  */
  @override
  double newton3p2Prudence(int elemLength) {
    double b0, b1, b2;
    double vvar;

    if (elemLength >= 100 && elemLength < 300) {
      b0 = 3.50947779709583E+02;
      b1 = -1.35265037401038E+00;
      b2 = 2.55663118810290E-03;
      vvar = b0 +
          b1 * (elemLength - 100) +
          b2 * (elemLength - 100) * (elemLength - 200);
    } else if (elemLength >= 300 && elemLength < 500) {
      b0 = 1.31550328669565E+02;
      b1 = -3.76757033576814E-01;
      b2 = 8.31549619775485E-04;
      vvar = b0 +
          b1 * (elemLength - 300) +
          b2 * (elemLength - 300) * (elemLength - 400);
    } else if (elemLength >= 500 && elemLength < 700) {
      b0 = 7.28299143497119E+01;
      b1 = -1.44819761394149E-01;
      b2 = 1.81011258993510E-04;
      vvar = b0 +
          b1 * (elemLength - 500) +
          b2 * (elemLength - 500) * (elemLength - 600);
    } else if (elemLength >= 700 && elemLength < 900) {
      b0 = 4.74861872507523E+01;
      b1 = -8.32110288762810E-02;
      b2 = 9.53548685034349E-05;
      vvar = b0 +
          b1 * (elemLength - 700) +
          b2 * (elemLength - 700) * (elemLength - 800);
    } else if (elemLength >= 900 && elemLength < 1100) {
      b0 = 3.27510788455648E+01;
      b1 = -4.97708317920970E-02;
      b2 = 5.39583735582001E-05;
      vvar = b0 +
          b1 * (elemLength - 900) +
          b2 * (elemLength - 900) * (elemLength - 1000);
    } else if (elemLength >= 1100 && elemLength < 1300) {
      b0 = 2.38760799583094E+01;
      b1 = -3.08585660995160E-02;
      b2 = 3.07693716916651E-05;
      vvar = b0 +
          b1 * (elemLength - 1100) +
          b2 * (elemLength - 1100) * (elemLength - 1200);
    } else if (elemLength >= 1300 && elemLength < 1500) {
      b0 = 1.83197541722395E+01;
      b1 = -1.99933242146800E-02;
      b2 = 1.82486527921898E-05;
      vvar = b0 +
          b1 * (elemLength - 1300) +
          b2 * (elemLength - 1300) * (elemLength - 1400);
    } else if (elemLength >= 1500 && elemLength < 1700) {
      b0 = 1.46860623851473E+01;
      b1 = -1.34812835105990E-02;
      b2 = 1.13617313988300E-05;
      vvar = b0 +
          b1 * (elemLength - 1500) +
          b2 * (elemLength - 1500) * (elemLength - 1600);
    } else if (elemLength >= 1700 && elemLength < 1900) {
      b0 = 1.22170403110041E+01;
      b1 = -9.38358775443799E-03;
      b2 = 7.41373143016988E-06;
      vvar = b0 +
          b1 * (elemLength - 1700) +
          b2 * (elemLength - 1700) * (elemLength - 1800);
    } else if (elemLength >= 1900 && elemLength < 2100) {
      b0 = 1.04885973887199E+01;
      b1 = -6.68370579131269E-03;
      b2 = 5.04458626939339E-06;
      vvar = b0 +
          b1 * (elemLength - 1900) +
          b2 * (elemLength - 1900) * (elemLength - 2000);
    } else if (elemLength >= 2100 && elemLength < 2300) {
      b0 = 9.25274795584523E+00;
      b1 = -4.83084261390919E-03;
      b2 = 3.55956522180741E-06;
      vvar = b0 +
          b1 * (elemLength - 2100) +
          b2 * (elemLength - 2100) * (elemLength - 2200);
    } else if (elemLength >= 2300 && elemLength < 2500) {
      b0 = 8.35777073749954E+00;
      b1 = -3.51370050291719E-03;
      b2 = 2.59124490500038E-06;
      vvar = b0 +
          b1 * (elemLength - 2300) +
          b2 * (elemLength - 2300) * (elemLength - 2400);
    } else if (elemLength >= 2500 && elemLength < 2700) {
      b0 = 7.70685553501611E+00;
      b1 = -2.54871978750430E-03;
      b2 = 1.93729916096696E-06;
      vvar = b0 +
          b1 * (elemLength - 2500) +
          b2 * (elemLength - 2500) * (elemLength - 2600);
    } else {
      b0 = 7.23585756073459E+00;
      b1 = -1.82329069626940E-03;
      b2 = 1.48177972237851E-06;
      vvar = b0 +
          b1 * (elemLength - 2700) +
          b2 * (elemLength - 2700) * (elemLength - 2800);
    }

    return vvar;
  }
}
