import 'dart:math';
import 'package:flutter/material.dart';

class DataManager  extends ChangeNotifier {
  // パラメータ
  final List<Node> _nodeList = [];
  final List<Elem> _elemList = [];
  List<Node> _resultNodeList = [];
  List<Elem> _resultElemList = [];

  // ゲッター
  Node getNode(int index) {
    return _nodeList[index];
  }
  int get nodeCount => _nodeList.length;
  Elem getElem(int index) {
    return _elemList[index];
  }
  int get elemCount => _elemList.length;
  // 節点の範囲座標
  Rect get rect {
    if(_nodeList.isEmpty) {
      return Rect.zero; // 節点データがないとき終了
    } 

    Offset pos = _nodeList[0].pos;

    double left = pos.dx;
    double right = pos.dx;
    double top = pos.dy;
    double bottom = pos.dy;

    if(_nodeList.length > 1){
      for (int i = 1; i < _nodeList.length; i++) {
        pos = _nodeList[i].pos;
        left = min(left, pos.dx);
        right = max(right, pos.dx);
        top = min(top, pos.dy);
        bottom = max(bottom, pos.dy);
      }
    }

    if (left == right && top == bottom) {
      // 範囲が0の場合、適当な範囲を設定
      left -= 1;
      right += 1;
      top -= 1;
      bottom += 1;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }
  // 節点の半径
  double get nodeRadius {
    Rect newRect = rect;
    if (newRect.width > newRect.height) {
      return newRect.width * 2 / 100;
    } else {
      return newRect.height * 2 / 100;
    }
  }
  // 要素の幅
  double get elemWidth {
    Rect newRect = rect;
    if (newRect.width > newRect.height) {
      return newRect.width * 3 / 100;
    } else {
      return newRect.height * 3 / 100;
    }
  }
  double getMaxElemResult(int index) {
    if (_elemList.isEmpty) {
      return 0.0;
    }

    double value = _elemList[0].getResult(index);
    for (int i = 1; i < _elemList.length; i++) {
      value = max(value, _elemList[i].getResult(index));
    }

    return value;
  }
  double getMinElemResult(int index) {
    if (_elemList.isEmpty) {
      return 0.0;
    }

    double value = _elemList[0].getResult(index);
    for (int i = 1; i < _elemList.length; i++) {
      value = min(value, _elemList[i].getResult(index));
    }

    return value;
  }
  
  Node getResultNode(int index) {
    return _resultNodeList[index];
  }
  int get resultNodeCount => _resultNodeList.length;
  Elem getResultElem(int index) {
    return _resultElemList[index];
  }
  int get resultElemCount => _resultElemList.length;

  // 関数
  void addNode() {
    Node node = Node(nodeCount);
    node.addListener(notifyListeners);
    _nodeList.add(node);
    notifyListeners();
  }
  void removeNode(int index) {
    _nodeList.removeAt(index);
    for (int i = index; i < _nodeList.length; i++) {
      _nodeList[i].changeNumber(i);
    }
    notifyListeners();
  }
  void addElem() {
    Elem elem = Elem(elemCount);
    elem.addListener(notifyListeners);
    _elemList.add(elem);
    notifyListeners();
  }
  void removeElem(int index) {
    _elemList.removeAt(index);
    for (int i = index; i < _elemList.length; i++) {
      _elemList[i].changeNumber(i);
    }
    notifyListeners();
  }
  
  void initResultNode(int length) {
    _resultNodeList = List.generate(length, (i) => Node(i));
    notifyListeners();
  }
  void initResultElem(int length) {
    _resultElemList = List.generate(length, (i) => Elem(i));
    notifyListeners();
  }
}

class Node extends ChangeNotifier{
  Node(int number) {
    _number = number;
  }

  // パラメータ
  int _number = 0;
  Offset _pos = Offset.zero;
  final List<bool> _const = [false, false, false, false]; // 拘束条件 0:水平、1：鉛直、2：回転、3:ヒンジ
  final List<double> _load = [0.0, 0.0, 0.0]; // 荷重条件 0:水平、1：鉛直、2：曲げモーメント
  Offset _becPos = Offset.zero;
  Offset _afterPos = Offset.zero;
  final List<double> _result = [0.0, 0.0, 0.0, 0.0]; // 0:水平方向の反力、1:垂直方向の反力、2:モーメン、3:たわみ角

  // ゲッター
  int get number => _number;
  Offset get pos => _pos;
  bool getConst(int index) {
    return _const[index];
  }
  double getLoad(int index) {
    return _load[index];
  }
  Offset get becPos => _becPos;
  Offset get afterPos => _afterPos;
  double getResult(int index) {
    return _result[index];
  }

  // 関数
  void changeNumber(int number) {
    _number = number;
    notifyListeners();
  }
  void changePos(Offset pos) {
    _pos = pos;
    notifyListeners();
  }
  void changeConst(int index, bool value) {
    _const[index] = value;
    notifyListeners();
  }
  void changeLoad(int index, double value) {
    _load[index] = value;
    notifyListeners();
  }
  void changeBecPos(Offset pos) {
    _becPos = pos;
    notifyListeners();
  }
  void changeAfterPos(Offset pos) {
    _afterPos = pos;
    notifyListeners();
  }
  void changeResult(int index, double value) {
    _result[index] = value;
    notifyListeners();
  }
}

class Elem extends ChangeNotifier{
  Elem(int number) {
    _number = number;
  }

  // パラメータ
  int _number = 0;
  final List<Node?> _nodeList = [null, null];
  final List<double> _rigid = [1.0, 1.0, 1.0]; // 0:ヤング率、1：断面二次モーメント、2:断面積
  double _load = 0.0; // 荷重
  final List<double> _result = [0.0, 0.0, 0.0, 0.0, 0.0]; // 0:軸力、1:せん断力、2:曲げモーメント、3:曲げモーメントa, 4: 曲げモーメントb

  // ゲッター
  int get number => _number;
  Node? getNode(int index) {
    return _nodeList[index];
  }
  double getRigid(int index) {
    return _rigid[index];
  }
  double get load => _load;
  double getResult(int index) {
    return _result[index];
  }

  // 関数
  void changeNumber(int number) {
    _number = number;
    notifyListeners();
  }
  void changeNode(int index, Node? node) {
    _nodeList[index] = node;
    notifyListeners();
  }
  void changeLigid(int index, double value) {
    _rigid[index] = value;
    notifyListeners();
  }
  void changeLoad(double value) {
    _load = value;
    notifyListeners();
  }
  void changeResult(int index, double value) {
    _result[index] = value;
    notifyListeners();
  }
}