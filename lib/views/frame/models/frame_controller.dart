import 'package:flutter/material.dart';

import 'data_manager.dart';
export 'data_manager.dart';

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

  // ゲッター
  int get typeIndex => _typeIndex;
  int get toolIndex => _toolIndex;
  int get resultIndex => _resultIndex;
  int get selectedNumber => _selectedNumber;
  bool get isCalculated => _isCalculated;


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

    // resultList = List.filled(elemList.length, 0);
    // for (int i = 0; i < elemList.length; i++) {
    //   if(index == 0) {
    //     resultList[i] = elemList[i].result[0];
    //   } else if (index == 1) {
    //     resultList[i] = elemList[i].result[1];
    //   } else if (index == 2) {
    //     resultList[i] = elemList[i].result[2];
    //   }
    // }

    // for (int i = 0; i < resultList.length; i++) {
    //   if(i == 0){
    //     resultMax = resultList[i];
    //     resultMin = resultList[i];
    //   }else{
    //     resultMax = max(resultMax, resultList[i]);
    //     resultMin = min(resultMin, resultList[i]);
    //   }
    // }

    notifyListeners();
  }

  // 選択の初期化
  void initSelect() {
    _selectedNumber = -1;
    if (_typeIndex == 0 && _toolIndex == 0) {
      _selectedNumber = data.nodeCount - 1;
    } else if (_typeIndex == 1 && _toolIndex == 0) {
      _selectedNumber = data.elemCount - 1;
    }
  }
}