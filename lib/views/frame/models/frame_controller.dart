import 'package:flutter/material.dart';

class FrameController extends ChangeNotifier {
  FrameController() {
    addNode();
  }

  // パラメータ
  final List<Node> _nodeList = [];
  bool _isCalculated = false;

  // ゲッター
  Node getNode(int index) {
    return _nodeList[index];
  }
  int get nodeCount => _nodeList.length;
  bool get isCalculated => _isCalculated;

  // 関数
  void addNode() {
    _nodeList.add(Node(nodeCount));
  }
}

class Node {
  Node(int number) {
    _number = number;
  }

  // パラメータ
  int _number = 0;

  // ゲッター
  int get number => _number;
}