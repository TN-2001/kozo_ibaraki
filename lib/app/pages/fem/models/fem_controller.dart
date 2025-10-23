import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem2d.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_data.dart';
import 'package:kozo_ibaraki/core/utils/math_utils.dart';
export 'package:kozo_ibaraki/app/pages/fem/models/fem_data.dart';

class FemController extends ChangeNotifier {
  FemController() {
    data.addNode();
    initSelect();
  }

  // パラメータ
  final FemData data = FemData();
  int _typeIndex = 0; // 選択されているタイプのインデックス（0:節点、1:要素）
  int _toolIndex = 0; // 選択されているツールのインデックス（0:新規、1:修正）
  int _resultIndex = 0; // 選択されている結果のインデックス（0:変形図、1:反力、2:せん断力図、3:曲げモーメント図）
  int _selectedNumber = -1;
  bool _isCalculated = false;
  final List<bool> _isDisplays = [true, true, true, true]; // キャンバスで表示のOn・Off 

  double _resultMin = 0;
  double _resultMax = 0;

  static const double minValue = 10e-13; // 最小値

  // ゲッター
  int get typeIndex => _typeIndex;
  int get toolIndex => _toolIndex;
  int get resultIndex => _resultIndex;
  int get selectedNumber => _selectedNumber;
  bool get isCalculated => _isCalculated;
  bool getIsDisplay(int index) => _isDisplays[index];

  double get resultMin => _resultMin;
  double get resultMax => _resultMax;


  // 関数
  // 選択されたタイプとツールのインデックスを変更
  void _removeTemporaryData() {
    if (_toolIndex == 0) {
      if (_typeIndex == 0) {
        data.removeNode(data.nodeCount - 1);
      } else if (_typeIndex == 1) {
        data.removeElem(data.elemCount - 1);
      }
    }
    initSelect();
  }
  void _changeTypeAndToolIndex() {
    if (_typeIndex == 0 && _toolIndex == 0) {
      data.addNode();
    } else if (_typeIndex == 1 && _toolIndex == 0) {
      data.addElem();
    }
    initSelect();
  }
  void changeTypeIndex(int index) {
    _removeTemporaryData();
    _typeIndex = index;
    _changeTypeAndToolIndex();

    notifyListeners();
  }
  void changeToolIndex(int index) {
    _removeTemporaryData();
    _toolIndex = index;
    _changeTypeAndToolIndex();

    notifyListeners();
  }

  // 解析結果の選択インデックスを変更
  void changeResultIndex(int index) {
    _resultIndex = index;

    if (index <= 10) {
      _resultMin = data.getElem(0).getResult(resultIndex);
      _resultMax = data.getElem(0).getResult(resultIndex);
      for (int i = 0; i < data.elemCount; i++) {
        _resultMin = min(resultMin, data.getElem(i).getResult(resultIndex));
        _resultMax = max(resultMax, data.getElem(i).getResult(resultIndex));
      }
    }

    notifyListeners();
  }

  // 表示の設定
  void setIsDisplay(int index, bool value) {
    _isDisplays[index] = value;
    notifyListeners();
  }

  // 選択
  void initSelect() {
    _selectedNumber = -1;
    if (_typeIndex == 0 && _toolIndex == 0) {
      _selectedNumber = data.nodeCount - 1;
    } else if (_typeIndex == 1 && _toolIndex == 0) {
      _selectedNumber = data.elemCount - 1;
    }

    notifyListeners();
  }
  void setSelectNode(Offset pos) {
    initSelect();

    double nodeRadius = data.getNodeRadius();

    for (int i = 0; i < data.nodeCount; i++) {
      double dis = (data.getNode(i).pos - pos).distance;
      if (dis <= nodeRadius * 3) {
        _selectedNumber = i;
        break;
      }
    }

    notifyListeners();
  }
  void setSelectElem(Offset pos) {
    initSelect();

    for (int i = 0; i < data.elemCount; i++) {
      Elem elem = data.getElem(i);
      List<Offset> p = [];
      for (int j = 0; j < elem.nodeCount; j++) {
        p.add(data.getElem(i).getNode(j)!.pos);
      }

      if (elem.nodeCount == 3) {
        if (MathUtils.isPointInTriangle(pos, p[0], p[1], p[2])) {
          _selectedNumber = i;
          break;
        }
      } else {
        if (MathUtils.isPointInRectangle(pos, p[0], p[1], p[2], p[3])) {
          _selectedNumber = i;
          break;
        }
      }
    }

    notifyListeners();
  }
  
  // 計算
  void calculation() {
    try {
      _removeTemporaryData();
      _calculationFrame2d();
      _selectedNumber = -1; // 選択番号をリセット
      _isCalculated = true;
      changeResultIndex(resultIndex); // 結果のインデックスを変更
    } catch(e) {
      _changeTypeAndToolIndex();
    }
  }
  void _calculationFrame2d() {
    final Elem matElem = data.matElem;

    final int nx = data.nodeCount;
    final List<List<double>> xyzn = List.generate(nx, (_) => List.filled(2, 0.0));
    final List<List<int>> mfix = List.generate(nx, (_) => List.filled(2, 0));
    final List<List<double>> dnod = List.generate(nx, (_) => List.filled(2, 0.0));
    final List<List<double>> fnod = List.generate(nx, (_) => List.filled(2, 0.0));
    final int nelx = data.elemCount;
    final List<List<int>> ijke = List.generate(nelx, (_) => List.filled(5, 0));
    final List<List<double>> prop = List.generate(nelx, (_) => List.filled(2, 0.0));
    final List<List<double>> body = List.generate(nelx, (_) => List.filled(2, 0.0));
    final int n2d = matElem.plane + 1;
    final double he = matElem.getRigid(4);

    for (int i = 0; i < nx; i++) {
      Node node = data.getNode(i);
      xyzn[i][0] = node.pos.dx;
      xyzn[i][1] = node.pos.dy;
      mfix[i][0] = node.getConst(0) ? 1 : 0;
      mfix[i][1] = node.getConst(1) ? 1 : 0;
      dnod[i][0] = node.getLoad(0);
      dnod[i][1] = node.getLoad(1);
      fnod[i][0] = node.getLoad(2);
      fnod[i][1] = node.getLoad(3);
    }
    

    for (int i = 0; i < nelx; i++) {
      Elem elem = data.getElem(i);
      ijke[i][4] = elem.nodeCount;
      ijke[i][0] = elem.getNode(0)!.number + 1;
      ijke[i][1] = elem.getNode(1)!.number + 1;
      ijke[i][2] = elem.getNode(2)!.number + 1;
      if (elem.nodeCount == 4) {
        ijke[i][3] = elem.getNode(3)!.number;
      }
      prop[i][0] = elem.getRigid(0);
      prop[i][1] = elem.getRigid(1);
      body[i][0] = elem.getRigid(2);
      body[i][0] = elem.getRigid(3);
    }

    Map<String, Object> input = {
      'nx': nx,
      'xyzn': xyzn,
      'mfix': mfix,
      'dnod': dnod,
      'fnod': fnod,
      'nelx': nelx,
      'ijke': ijke,
      'prop': prop,
      'body': body,
      'n2d': n2d,
      'he': he,
    };

    Map<String, Object> output = fem2d(input);

    // final nx = output['nx'] as int;
    final nd = output['nd'] as int;
    final disp = output['disp'] as List<double>;
    // final nelx = output['nelx'] as int;
    // final ijke = output['ijke'] as List<List<int>>;
    final strs = output['strs'] as List<List<double>>;
    final strn = output['strn'] as List<List<double>>;
    

    // 変位
    double maxBecPos = 0;
    for (int ix = 0; ix < nx; ix++) {
      Node node = data.getNode(ix);

      double ui = disp[nd * ix + 0];
      double vi = disp[nd * ix + 1];

      maxBecPos = max(maxBecPos, ui.abs());
      maxBecPos = max(maxBecPos, vi.abs());

      node.setBecPos(Offset(ui, vi));
    }

    // ワールド範囲の最大1/8まで変位
    final Rect rect = data.getRect();
    final double rectWidth = max(rect.width, rect.height);
    for (int ix = 0; ix < nx; ix++) {
      Node node = data.getNode(ix);
      node.setAfterPos(
        Offset(
          node.pos.dx + node.becPos.dx / maxBecPos * rectWidth / 8,
          node.pos.dy + node.becPos.dy / maxBecPos * rectWidth / 8
        )
      );
    }
    
    // 力
    for (int ie = 0; ie < nelx; ie++) {
      Elem elem = data.getElem(ie);
      for (int i = 0; i < 7; i++) {
        elem.setResult(i, strs[ie][i]);
      }
      for (int i = 0; i < 4; i++) {
        elem.setResult(i + 7, strn[ie][i]);
      }
    }
  }
  void resetCalculation() {
    _isCalculated = false;
    _changeTypeAndToolIndex();
  }
}