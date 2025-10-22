import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/truss/models/truss2d.dart';
import 'package:kozo_ibaraki/core/utils/math_utils.dart';

class TrussData extends ChangeNotifier {
  TrussData() {
    node = Node();
    node!.number = nodeList.length;
    initSelect();
  }

  /*
    パラメータ
  */
  // ツール操作関係
  int _typeIndex = 0; // 選択されているタイプのインデックス（0:節点、1:要素）
  int _toolIndex = 0; // 選択されているツールのインデックス（0:新規、2修正）
  int _resultIndex = 0; // 選択されている結果のインデックス（"変形図", "反力", "せん断力図","曲げモーメント図",）

  List<Node> nodeList = []; // 節点データ
  List<Elem> elemList = []; // 要素データ

  final double _nodeRadiusPercent = 2.0;
  final double _elemWidthPercent = 3.0; // 要素の幅のパーセンテージ

  int _selectedNumber = -1; // 選択番号

  bool isCalculation = false; // 解析したかどうか

  static const double minValue = 10e-13; // 最小値

  /*
    ゲッター
  */
  // ツール操作関係
  int get typeIndex => _typeIndex; // 選択されているタイプのインデックスを取得
  int get toolIndex => _toolIndex; // 選択されているツールのインデックスを取得
  int get resultIndex => _resultIndex; // 選択されている結果のインデックスを取得

  Node getNode(int number) {
    if (number < 0 || number >= nodeList.length) {
      throw RangeError('Node number out of range: $number');
    }
    return nodeList[number];
  }
  int get nodeCount => nodeList.length; // 節点の数を取得

  Elem getElem(int number) {
    if (number < 0 || number >= elemList.length) {
      throw RangeError('Element number out of range: $number');
    }
    return elemList[number];
  }
  int get elemCount => elemList.length; // 要素の数を取得

  // 節点の範囲座標
  Rect get rect {
    List<Node> nodes = allNodeList();
    if(nodes.isEmpty) return Rect.zero; // 節点データがないとき終了

    double left = nodes[0].pos.dx;
    double right = nodes[0].pos.dx;
    double top = nodes[0].pos.dy;
    double bottom = nodes[0].pos.dy;

    if(allNodeList().length > 1){
      for (int i = 1; i < nodes.length; i++) {
        left = min(left, nodes[i].pos.dx);
        right = max(right, nodes[i].pos.dx);
        top = min(top, nodes[i].pos.dy);
        bottom = max(bottom, nodes[i].pos.dy);
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

  double get nodeRadius {
    if (rect.width > rect.height) {
      return rect.width * _nodeRadiusPercent / 100;
    } else {
      return rect.height * _nodeRadiusPercent / 100;
    }
  }

  double get elemWidth {
    if (rect.width > rect.height) {
      return rect.width * _elemWidthPercent / 100;
    } else {
      return rect.height * _elemWidthPercent / 100;
    }
  }

  int get selectedNumber => _selectedNumber; // 選択番号

  // データ
  int elemNode = 2; // 要素節点数
  // 追加データ
  Node? node; // 新規節点データ
  Elem? elem; // 新規要素データ

  List<double> resultList = [];
  double resultMin = 0, resultMax = 0;

  // 全データ
  List<Node> allNodeList() // 節点データ+新規節点データ
  {
    List<Node> n = List.empty(growable: true);

    for(int i = 0; i < nodeList.length; i++){
      n.add(nodeList[i]);
    }
    if(node != null){
      n.add(node!);
    }

    return n;
  }
  List<Elem> allElemList() // 要素データ+新規要素データ
  {
    List<Elem> e = List.empty(growable: true);

    for(int i = 0; i < elemList.length; i++){
      e.add(elemList[i]);
    }
    if(elem != null){
      e.add(elem!);
    }

    return e;
  }
  

  /*
    関数
  */
  // 選択されたタイプとツールのインデックスを変更
  void _changeTypeAndToolIndex() {
    node = null; // 新規節点データをリセット
    elem = null; // 新規要素データをリセット
    if(_typeIndex == 0 && _toolIndex == 0){
      node = Node();
      node!.number = nodeList.length;
    }else if(_typeIndex == 1 && _toolIndex == 0){
      elem = Elem();
      elem!.number = elemList.length;
      elem!.e = 1;
      elem!.v = 1;
    }
    initSelect();
  }
  void changeTypeIndex(int index) {
    _typeIndex = index;

    _changeTypeAndToolIndex();

    notifyListeners();
  }
  void changeToolIndex(int index) {
    _toolIndex = index;

    _changeTypeAndToolIndex();

    notifyListeners();
  }

  // 解析結果の選択インデックスを変更
  void changeResultIndex(int index) {
    _resultIndex = index;

    resultList = List.filled(elemList.length, 0);
    for (int i = 0; i < elemList.length; i++) {
      if(index == 0) {
        resultList[i] = elemList[i].result[0];
      } else if (index == 1) {
        resultList[i] = elemList[i].result[1];
      } else if (index == 2) {
        resultList[i] = elemList[i].result[2];
      }
    }

    for (int i = 0; i < resultList.length; i++) {
      if(i == 0){
        resultMax = resultList[i];
        resultMin = resultList[i];
      }else{
        resultMax = max(resultMax, resultList[i]);
        resultMin = min(resultMin, resultList[i]);
      }
    }

    notifyListeners();
  }

  // 追加削除
  void addNode(){
    // バグ対策
    if(node == null) return;
    for(int i = 0; i < nodeList.length; i++){
      if(node!.pos.dx == nodeList[i].pos.dx && node!.pos.dy == nodeList[i].pos.dy){
        return;
      }
    }

    // 追加
    nodeList.add(node!);
    node = Node();
    node!.number = nodeList.length;
    initSelect();
  }
  void removeNode(int number){
    // バグ対策
    if(nodeList.length-1 < number && nodeList.isNotEmpty) return;

    // 節点を使っている要素の削除
    for(int i = elemList.length-1; i >= 0; i--){
      for(int j = 0; j < elemNode; j++){
        if(elemList[i].nodeList[j]!.number == number){
          removeElem(i);
        }
      }
    }

    // 節点の削除
    nodeList.removeAt(number);

    // 節点の番号を修正
    for(int i = 0; i < nodeList.length; i++){
      nodeList[i].number = i;
    }
  }
  void addElem(){
    // バグ対策
    if(elem == null) return;
    for(int i = 0; i < elemNode; i++){
      if(elem!.nodeList[1] == null) return;
    }
    for(int i = 0; i < elemNode; i++){
      for(int j = 0; j < elemNode; j++){
        if(i != j && elem!.nodeList[i] == elem!.nodeList[j]){
          return;
        }
      }
    }
    for(int e = 0; e < elemList.length; e++){
      int count = 0;
      for(int i = 0; i < elemNode; i++){
        for(int j = 0; j < elemNode; j++){
          if(elem!.nodeList[i] == elemList[e].nodeList[j]){
            count ++;
            if(count == elemNode){
              return;
            }
          }
        }
      }
    }

    // 追加
    elemList.add(elem!);
    elem = Elem();
    elem!.number = elemList.length;
    initSelect();
  }
  void removeElem(int number){
    // バグ対策
    if(elemList.length-1 < number && elemList.isNotEmpty) return;

    // 要素の削除
    elemList.removeAt(number);

    // 要素の番号を修正
    for(int i = 0; i < elemList.length; i++){
      elemList[i].number = i;
    }
  }

  // 解析
  String checkCalculation() {
    bool isPower = false;

    int xyConstCount = 0;
    int xConstCount = 0;
    int yConstCount = 0;

    for(int i = 0; i < nodeList.length; i++){
      if(nodeList[i].constXY[0] && nodeList[i].constXY[1]){
        xyConstCount ++;
      }else if(nodeList[i].constXY[0]){
        xConstCount ++;
      }else if(nodeList[i].constXY[1]){
        yConstCount ++;
      }

      if((!nodeList[i].constXY[0] && nodeList[i].loadXY[0] != 0)
        || (!nodeList[i].constXY[1] && nodeList[i].loadXY[1] != 0)){
          isPower = true;
      }
    }

    if(elemList.length < 2){
      return "節点か要素が不足";
    }else if(!(xyConstCount > 0 && (xyConstCount + xConstCount + yConstCount) >= 2)){
      return "拘束条件が不足";
    }else if(!isPower){
      return "荷重条件が不足";
    }else{
      return ""; // 問題なし
    }
  }
  void calculation(){
    // バグ対策
    if(nodeList.isEmpty) return;
    if(elemList.isEmpty) return;
    for(int i = 0; i < elemList.length; i++){
      if(elemList[i].e <= 0 || elemList[i].v <= 0){
        return;
      }
      for(int j = 0; j < elemNode; j++){
        if(elemList[i].nodeList[j] == null){
          return;
        }
      }
    }

    final int nx = nodeCount; // 節点数
    final List<List<double>> xyzn = List.generate(nx, (_) => List.filled(2, 0.0));
    final List<List<int>> mfix = List.generate(nx, (_) => List.filled(2, 0));
    final List<List<double>> fnod = List.generate(nx, (_) => List.filled(2, 0.0));
    final int nelx = elemCount; // 要素数
    final List<List<int>> ijke = List.generate(nelx, (_) => List.filled(2, 0));
    final List<List<double>> prop = List.generate(nelx, (_) => List.filled(2, 0.0));

    for (int i = 0; i < nx; i++) {
      Node node = getNode(i);
      xyzn[i][0] = node.pos.dx;
      xyzn[i][1] = node.pos.dy;
      mfix[i][0] = node.constXY[0] ? 1 : 0;
      mfix[i][1] = node.constXY[1] ? 1 : 0;
      fnod[i][0] = node.loadXY[0];
      fnod[i][1] = node.loadXY[1];
    }

    for (int i = 0; i < nelx; i++) {
      Elem elem = getElem(i);
      ijke[i][0] = min(elem.nodeList[0]!.number, elem.nodeList[1]!.number);
      ijke[i][1] = max(elem.nodeList[0]!.number, elem.nodeList[1]!.number);
      prop[i][0] = elem.e;
      prop[i][1] = elem.v;
    }

    Map<String, Object> input = {
      'nx': nx,
      'xyzn': xyzn,
      'mfix': mfix,
      'fnod': fnod,
      'nelx': nelx,
      'ijke': ijke,
      'prop': prop,
    };

    Map<String, Object> output = truss2d(input);

    final int ndof = output['ndof'] as int;
    final List<double> disp = output['disp'] as List<double>;
    final List<double> fint = output['fint'] as List<double>;
    final List<double> frea = output['frea'] as List<double>;

    // 変位
    double maxDisp = 0;
    double rectWidth = max(rect.width, rect.height);
    for (int ix = 0; ix < nx; ix++) {
      Node node = getNode(ix);
      node.becPos = Offset(disp[ndof * ix + 0], disp[ndof * ix + 1]);
      if (node.becPos.dx.abs() < minValue) {
        node.becPos = Offset(0, node.becPos.dy);
      }
      if (node.becPos.dy.abs() < minValue) {
        node.becPos = Offset(node.becPos.dx, 0);
      }
      maxDisp = max(maxDisp, node.becPos.distance.abs());
    }
    for (int ix = 0; ix < nx; ix++) {
      Node node = getNode(ix);
      if (maxDisp == 0) {
        node.afterPos = node.pos;
        continue;
      }
      node.afterPos = Offset(
        node.pos.dx + node.becPos.dx / maxDisp * rectWidth / 8,
        node.pos.dy + node.becPos.dy / maxDisp * rectWidth / 8,
      );
    }
    
    // 軸力
    for (int ie = 0; ie < nelx; ie++) {
      Elem elem = getElem(ie);
      elem.result[0] = fint[ie];
      if (elem.result[0].abs() < minValue) {
        elem.result[0] = 0;
      }
    }

    // 応力（軸方向）
    for (int ie = 0; ie < nelx; ie++) {
      Elem elem = getElem(ie);
      elem.result[1] = fint[ie] / prop[ie][1];
      if (elem.result[1].abs() < minValue) {
        elem.result[1] = 0;
      }
    }

    // ひずみ
    for(int ie = 0; ie < nelx; ie++){
      Elem elem = getElem(ie);
      elem.result[2] = elem.result[0] / prop[ie][0];
      if (elem.result[2].abs() < minValue) {
        elem.result[2] = 0;
      }
    }
    
    // 反力
    for (int ix = 0; ix < nx; ix++) {
      Node node = getNode(ix);
      node.result[0] = mfix[ix][0] == 1 ? frea[ndof * ix + 0] : 0; // 水平方向の反力
      node.result[1] = mfix[ix][1] == 1 ? frea[ndof * ix + 1] : 0; // 垂直方向の反力
      if (node.result[0].abs() < minValue) {
        node.result[0] = 0;
      }
      if (node.result[1].abs() < minValue) {
        node.result[1] = 0;
      }
    }



    node = null; // 新規節点データをリセット
    elem = null; // 新規要素データをリセット
    _selectedNumber = -1; // 選択番号をリセット
    isCalculation = true;
    changeResultIndex(resultIndex); // 結果のインデックスを変更
  }
  void resetCalculation() {
    changeTypeIndex(typeIndex);
    isCalculation = false;
    notifyListeners();
  }

  // キャンバスに要素があるか
  void initSelect(){
    _selectedNumber = -1;

    if (node != null) {
      _selectedNumber = node!.number; // 新規節点の選択番号を設定
    } else if (elem != null) {
      _selectedNumber = elem!.number; // 新規要素の選択番号を設定
    }
  }
  void selectElem(Offset pos) {
    initSelect();

    for (int i = 0; i < elemList.length; i++) {
      List<Offset> nodePosList = [];
      for (int j = 0; j < 2; j++) {
        nodePosList.add(elemList[i].nodeList[j]!.pos);
      }

      List<Offset> p = MathUtils.getRectanglePoints(nodePosList[0], nodePosList[1], elemWidth);

      if(MathUtils.isPointInRectangle(pos, p[0], p[1], p[2], p[3])){
        _selectedNumber = i;
        break;
      }
    }

    notifyListeners();
  }
  void selectNode(Offset pos){
    initSelect();

    for(int i = 0; i < nodeList.length; i++){
      double dis = (nodeList[i].pos - pos).distance;
      if(dis <= nodeRadius){
        _selectedNumber = i;
        
        break;
      }
    }

    notifyListeners();
  }
}

class Node {
  // 基本データ
  int number = 0;
  Offset pos = Offset.zero;
  List<bool> constXY = [false, false]; // 拘束（0:x、1:y）
  List<double> loadXY = [0, 0]; // 荷重（0:x、1:y）

  // 計算結果
  Offset becPos = Offset.zero;
  Offset afterPos = Offset.zero;
  List<double> result = [0,0]; // 0:水平方向の反力、1:垂直方向の反力
}

class Elem {
  // 基本データ
  int number = 0;
  double e = 1.0;
  double v = 1.0;
  List<Node?> nodeList = [null, null];

  // 計算結果
  List<double> result = [0,0,0]; // 0:軸力、1:応力、2:ひずみ
}
