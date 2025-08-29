import 'dart:ui';

class DataManager {
  // パラメータ
  final List<Node> _nodeList = [];
  final List<Elem> _elemList = [];

  // ゲッター
  Node getNode(int index) {
    return _nodeList[index];
  }
  int get nodeCount => _nodeList.length;
  Elem getElem(int index) {
    return _elemList[index];
  }
  int get elemCount => _elemList.length;

  // 関数
  void addNode() {
    _nodeList.add(Node(nodeCount));
  }
  void removeNode(int index) {
    _nodeList.removeAt(index);
    for (int i = index; i < _nodeList.length; i++) {
      _nodeList[i].changeNumber(i);
    }
  }
  void addElem() {
    _elemList.add(Elem(elemCount));
  }
  void removeElem(int index) {
    _elemList.removeAt(index);
    for (int i = index; i < _elemList.length; i++) {
      _elemList[i].changeNumber(i);
    }
  }
}

class Node {
  Node(int number) {
    _number = number;
  }

  // パラメータ
  int _number = 0;
  Offset _pos = Offset.zero;
  final List<bool> _const = [false, false]; // 拘束条件
  final List<double> _load = [0.0, 0.0]; // 荷重条件

  // ゲッター
  int get number => _number;
  Offset get pos => _pos;
  bool getConst(int index) {
    return _const[index];
  }
  double getLoad(int index) {
    return _load[index];
  }

  // 関数
  void changeNumber(int number) {
    _number = number;
  }
  void changePos(Offset pos) {
    _pos = pos;
  }
  void changeConst(int index, bool value) {
    _const[index] = value;
  }
  void changeLoad(int index, double value) {
    _load[index] = value;
  }
}

class Elem {
  Elem(int number) {
    _number = number;
  }

  // パラメータ
  int _number = 0;
  final List<Node?> _nodeList = [null, null];
  final List<double> _rigid = [0.0, 0.0]; // 0:ヤング率、1：断面積

  // ゲッター
  int get number => _number;
  Node? getNode(int index) {
    return _nodeList[index];
  }
  double getRigid(int index) {
    return _rigid[index];
  }
  

  // 関数
  void changeNumber(int number) {
    _number = number;
  }
  void changeNode(int index, Node? node) {
    _nodeList[index] = node;
  }
  void changeLigid(int index, double value) {
    _rigid[index] = value;
  }
}