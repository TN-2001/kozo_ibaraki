import 'dart:math';
import 'package:flutter/material.dart';

class FemData extends ChangeNotifier {
  FemData();

  // 変数
  final List<Node> _nodes = [];
  final List<Elem> _elems = [];
  final Elem _matElem = Elem(0); // 要素の共通部分を保存

  // ゲッター
  Node getNode(int index) => _nodes[index];
  int get nodeCount => _nodes.length;
  Elem getElem(int index) => _elems[index];
  int get elemCount => _elems.length;
  Elem get matElem => _matElem;
  // 節点の範囲座標
  Rect getRect() {
    if(_nodes.isEmpty) {
      return Rect.zero; // 節点データがないとき終了
    } 

    Offset pos = _nodes[0].pos;

    double left = pos.dx;
    double right = pos.dx;
    double top = pos.dy;
    double bottom = pos.dy;

    if(_nodes.length > 1){
      for (int i = 1; i < _nodes.length; i++) {
        pos = _nodes[i].pos;
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
  double getNodeRadius() {
    Rect newRect = getRect();
    if (newRect.width > newRect.height) {
      return newRect.width * 2 / 100;
    } else {
      return newRect.height * 2 / 100;
    }
  }
  // 要素の幅
  double getElemWidth() {
    Rect newRect = getRect();
    if (newRect.width > newRect.height) {
      return newRect.width * 3 / 100;
    } else {
      return newRect.height * 3 / 100;
    }
  }

  // 関数
  void addNode() {
    Node node = Node(nodeCount);
    node.addListener(notifyListeners);
    _nodes.add(node);
    notifyListeners();
  }
  void removeNode(int index) {
    _nodes.removeAt(index);
    for (int i = index; i < _nodes.length; i++) {
      _nodes[i].setNumber(i);
    }
    notifyListeners();
  }
  void addElem() {
    Elem elem = Elem(elemCount);
    elem.setNodeCount(matElem.nodeCount);
    elem.setRigid(0, matElem.getRigid(0));
    elem.setRigid(1, matElem.getRigid(1));
    elem.setRigid(2, matElem.getRigid(2));
    elem.setRigid(3, matElem.getRigid(3));
    
    elem.addListener(notifyListeners);
    _elems.add(elem);
    notifyListeners();
  }
  void removeElem(int index) {
    _elems.removeAt(index);
    for (int i = index; i < _elems.length; i++) {
      _elems[i].setNumber(i);
    }
    notifyListeners();
  }
}

class Node extends ChangeNotifier {
  Node(int number) {
    _number = number;
  }

  // 変数
  int _number = 0;
  Offset _pos = Offset.zero;
  final List<bool> _consts = [false, false]; // 拘束（0:x、1:y）
  final List<double> _loads = [0.0, 0.0, 0.0, 0.0]; // 強制変位（0:x、1:y）、集中荷重（2:x、3:y）
  Offset _becPos = Offset.zero;
  Offset _afterPos = Offset.zero;
  final List<double> _results = [0,0,0,0,0,0,0,0,0]; // 0:たわみ、1:たわみ角1、2:たわみ角2

  // ゲッター
  int get number => _number;
  Offset get pos => _pos;
  bool getConst(int index) => _consts[index];
  double getLoad(int index) => _loads[index];
  Offset get becPos => _becPos;
  Offset get afterPos => _afterPos;
  double getResult(int index) => _results[index];

  // 関数
  void setNumber(int number) {
    _number = number;
    notifyListeners();
  }
  void setPos(Offset pos) {
    _pos = pos;
    notifyListeners();
  }
  void setConst(int index, bool value) {
    _consts[index] = value;
    notifyListeners();
  }
  void setLoad(int index, double value) {
    _loads[index] = value;
    notifyListeners();
  }
  void setBecPos(Offset pos) {
    _becPos = pos;
    notifyListeners();
  }
  void setAfterPos(Offset pos) {
    _afterPos = pos;
    notifyListeners();
  }
  void setResult(int index, double value) {
    _results[index] = value;
    notifyListeners();
  }
}

class Elem extends ChangeNotifier{
  Elem(int number) {
    _number = number;
  }

  // 変数
  int _number = 0;
  int _nodeCount = 3; // 三角形か四角形か
  final List<Node?> _nodes = [null, null, null, null];
  final List<double> _rigids = [1.0, 1.0, 0.0, 0.0, 1.0]; // 0:ヤング率、1：ポアソン比, 物体力（2:bx, 3:by）,4:長さ 
  int _plane = 0; // 0=平面応力, 1=平面ひずみ
  // 応力（0:X方向、1:Y方向、2:せん断、3:Z方向、4:最大主、5:最小主、6:von-Mises相当）, ひずみ（7:X方向、8:Y方向、9:工学せん断、10:Z方向）
  final List<double> _results = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]; 

  // ゲッター
  int get number => _number;
  int get nodeCount => _nodeCount;
  Node? getNode(int index) => _nodes[index];
  double getRigid(int index) => _rigids[index];
  int get plane => _plane; 
  double getResult(int index) => _results[index];

  // 関数
  void setNumber(int number) {
    _number = number;
    notifyListeners();
  }
  void setNodeCount(int value) {
    _nodeCount = value;
    notifyListeners();
  }
  void setNode(int index, Node? node) {
    _nodes[index] = node;
    notifyListeners();
  }
  void setRigid(int index, double value) {
    _rigids[index] = value;
    notifyListeners();
  }
  void setPlane(int value) {
    _plane = value;
    notifyListeners();
  }
  void setResult(int index, double value) {
    _results[index] = value;
    notifyListeners();
  }
}