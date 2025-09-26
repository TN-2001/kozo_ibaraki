import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/frame/models/data_manager.dart';
import 'package:kozo_ibaraki/app/pages/frame/models/frame2d.dart';
import 'package:kozo_ibaraki/core/utils/my_calculator.dart';
export 'package:kozo_ibaraki/app/pages/frame/models/data_manager.dart';

class FrameController extends ChangeNotifier {
  FrameController() {
    data.addNode();
    initSelect();
  }

  // パラメータ
  final DataManager data = DataManager();
  int _typeIndex = 0; // 選択されているタイプのインデックス（0:節点、1:要素）
  int _toolIndex = 0; // 選択されているツールのインデックス（0:新規、1:修正）
  int _resultIndex = 0; // 選択されている結果のインデックス（0:変形図、1:反力、2:せん断力図、3:曲げモーメント図）
  int _selectedNumber = -1;
  bool _isCalculated = false;

  double _resultMin = 0;
  double _resultMax = 0;

  // ゲッター
  int get typeIndex => _typeIndex;
  int get toolIndex => _toolIndex;
  int get resultIndex => _resultIndex;
  int get selectedNumber => _selectedNumber;
  bool get isCalculated => _isCalculated;

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

    if (index <= 2) {
      _resultMin = data.getResultElem(0).getResult(resultIndex);
      _resultMax = data.getResultElem(0).getResult(resultIndex);
      for (int i = 0; i < data.resultElemCount; i++) {
        _resultMin = min(resultMin, data.getResultElem(i).getResult(resultIndex));
        _resultMax = max(resultMax, data.getResultElem(i).getResult(resultIndex));
      }
    }

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
  void selectNode(Offset pos) {
    initSelect();

    for (int i = 0; i < data.nodeCount; i++) {
      double dis = (data.getNode(i).pos - pos).distance;
      if (dis <= data.nodeRadius * 3) {
        _selectedNumber = i;
        break;
      }
    }

    notifyListeners();
  }
  void selectElem(Offset pos) {
    initSelect();

    for (int i = 0; i < data.elemCount; i++) {
      List<Offset> nodePosList = [];
      for (int j = 0; j < 2; j++) {
        nodePosList.add(data.getElem(i).getNode(j)!.pos);
      }

      List<Offset> p = MyCalculator.getRectanglePoints(nodePosList[0], nodePosList[1], data.elemWidth * 3);

      if(MyCalculator.isPointInRectangle(pos, p[0], p[1], p[2], p[3])){
        _selectedNumber = i;
        break;
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
    final int nx = data.nodeCount; // 節点数
    final List<List<double>> xyz0 = List.generate(nx, (_) => List.filled(2, 0.0));
    final List<List<int>> mfix = List.generate(nx, (_) => List.filled(4, 0));
    final List<List<double>> fnod = List.generate(nx, (_) => List.filled(3, 0.0));
    final int nelx = data.elemCount; // 要素数
    final List<List<int>> ijk0 = List.generate(nelx, (_) => List.filled(2, 0));
    final List<List<double>> prp0 = List.generate(nelx, (_) => List.filled(3, 0.0));
    final List<double> felm = List<double>.filled(nelx, 0.0);

    for (int i = 0; i < nx; i++) {
      Node node = data.getNode(i);
      xyz0[i][0] = node.pos.dx;
      xyz0[i][1] = node.pos.dy;
      mfix[i][0] = node.getConst(0) ? 1 : 0;
      mfix[i][1] = node.getConst(1) ? 1 : 0;
      mfix[i][2] = node.getConst(2) ? 1 : 0;
      mfix[i][3] = node.getConst(3) ? 1 : 0;
      fnod[i][0] = node.getLoad(0);
      fnod[i][1] = node.getLoad(1);
      fnod[i][2] = node.getLoad(2);
    }

    for (int i = 0; i < nelx; i++) {
      Elem elem = data.getElem(i);
      ijk0[i][0] = elem.getNode(0)!.number;
      ijk0[i][1] = elem.getNode(1)!.number;
      prp0[i][0] = elem.getRigid(0);
      prp0[i][1] = elem.getRigid(1);
      prp0[i][2] = elem.getRigid(2);
      felm[i] = elem.load;
    }

    Map<String, Object> input = {
      'nx': nx,
      'xyz0': xyz0,
      'mfix': mfix,
      'fnod': fnod,
      'nelx': nelx,
      'ijk0': ijk0,
      'prp0': prp0,
      'felm': felm,
    };

    Map<String, Object> output = frame2d(input);

    final int nx2 = output['nx2'] as int;
    final List<List<double>> xyzn = output['xyzn'] as List<List<double>>;
    final int nelx2 = output['nelx2'] as int;
    final int node = output['node'] as int;
    final List<List<int>> ijke = output['ijke'] as List<List<int>>;
    final List<List<List<int>>> mhng = output['mhng'] as List<List<List<int>>>;
    final int ndof = output['ndof'] as int;
    final List<double> disp = output['disp'] as List<double>;
    final List<List<double>> fint = output['fint'] as List<List<double>>;
    final List<double> frea = output['frea'] as List<double>;

    data.initResultNode(nx2);
    data.initResultElem(nelx2);

    // 分割した節点の初期化
    for (int ix = 0; ix < nx2; ix++) {
      Node node = data.getResultNode(ix);
      node.changePos(Offset(xyzn[ix][0], xyzn[ix][1]));
    }

    // 変位
    double maxBecPos = 0;
    for (int ie = 0; ie < nelx2; ie++) {
      Elem elem = data.getResultElem(ie);
      for (int jn = 0; jn < node; jn++) {
        double ui = disp[mhng[ie][jn][0]];
        double vi = disp[mhng[ie][jn][1]];
        double qi = disp[mhng[ie][jn][2]];

        Node node = data.getResultNode(ijke[ie][jn]);
        node.changeBecPos(Offset(ui, vi));
        node.changeAfterPos(node.pos + node.becPos / 100);
        node.changeResult(3, qi);
        elem.changeNode(jn, node);

        maxBecPos = max(maxBecPos, ui.abs());
        maxBecPos = max(maxBecPos, vi.abs());
      }
    }

    // ワールド範囲の最大1/8まで変位
    final double rectWidth = max(data.rect.width, data.rect.height);
    for (int ix = 0; ix < nx2; ix++) {
      Node node = data.getResultNode(ix);
      node.changeAfterPos(
        Offset(
          node.pos.dx + node.becPos.dx / maxBecPos * rectWidth / 8,
          node.pos.dy + node.becPos.dy / maxBecPos * rectWidth / 8
        )
      );
    }
    
    // 力
    for (int ie = 0; ie < nelx2; ie++) {
      Elem elem = data.getResultElem(ie);
      elem.changeResult(0, fint[ie][0]);
      elem.changeResult(1, fint[ie][1]);
      elem.changeResult(2, fint[ie][2]);
    }
    
    // 反力
    for (int ix = 0; ix < nx; ix++) {
      Node node = data.getNode(ix);
      node.changeResult(0, 0.0);
      node.changeResult(1, 0.0);
      node.changeResult(2, 0.0);
      if (mfix[ix][0] == 1) {
        node.changeResult(0, frea[ndof * ix + 0]);
      }
      if (mfix[ix][1] == 1) {
        node.changeResult(1, frea[ndof * ix + 1]);
      }
      if (mfix[ix][2] == 1 && mfix[ix][3] == 0) {
        node.changeResult(2, frea[ndof * ix + 2]);
      }
    }

    for (int ix = 0; ix < nx; ix++) {
      Node node = data.getNode(ix);
      node.changeBecPos(data.getResultNode(ix).becPos);
      node.changeAfterPos(data.getResultNode(ix).afterPos);
    }
  }
  void resetCalculation() {
    _isCalculated = false;
    _changeTypeAndToolIndex();
  }
}