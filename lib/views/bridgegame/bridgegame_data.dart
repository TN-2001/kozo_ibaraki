import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/views/bridgegame/des_fem70x25.dart';
import 'package:kozo_ibaraki/utils/my_calculator.dart';

class BridgegameData{
  BridgegameData({required this.onDebug}){
    elemNode = 4;
    int countX = 70;
    int countY = 25;
    for(int i = 0; i <= countY; i++){
      for(int j = 0; j <= countX; j++){
        Node node = Node();
        node.pos = Offset(j.toDouble(), i.toDouble());
        nodeList.add(node);
      }
    }
    for(int i = 0; i < countY; i++){
      for(int j = 0; j < countX; j++){
        Elem elem = Elem();
        elem.nodeList = [nodeList[i*(countX+1)+j],nodeList[i*(countX+1)+j+1],nodeList[(i+1)*(countX+1)+j+1],nodeList[(i+1)*(countX+1)+j]];
        elemList.add(elem);
      }
    }

    // 要素は確定か
    // 2段確定
    for(int i = 0; i < countX; i++){
      elemList[i].isCanPaint = false;
      elemList[i].e = 1;
      elemList[countX+i].isCanPaint = false;
      elemList[countX+i].e = 1;
    }
  }

  final Function(String value) onDebug;

  // データ
  int elemNode = 4; // 要素節点数
  List<Node> nodeList = []; // 節点データ
  List<Elem> elemList = []; // 要素データ
  // 追加データ
  Node? node; // 新規節点データ
  Elem? elem; // 新規要素データ

  bool isCalculation = false; // 解析したかどうか
  List<double> resultList = [];
  double resultMin = 0, resultMax = 0;
  // 選択番号
  int selectedNumber = -1;
  int powerType = 0; // 荷重条件（0:3点曲げ、1:4点曲げ、2:自重）

  // 節点の範囲座標
  Rect rect(){
    List<Node> nodes = nodeList;
    if(nodes.isEmpty) return Rect.zero; // 節点データがないとき終了

    double left = nodes[0].pos.dx;
    double right = nodes[0].pos.dx;
    double top = nodes[0].pos.dy;
    double bottom = nodes[0].pos.dy;

    if(nodes.length > 1){
      for (int i = 1; i < nodes.length; i++) {
        left = min(left, nodes[i].pos.dx);
        right = max(right, nodes[i].pos.dx);
        top = min(top, nodes[i].pos.dy);
        bottom = max(bottom, nodes[i].pos.dy);
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }
  double dispScale = 1.0; // 変位倍率


  int elemCount(){ // 要素数
    int elemCount = 0;
    for(int i = 0; i < elemList.length; i++){
      if(elemList[i].e > 0){
        elemCount ++;
      }
    }
    return elemCount;
  }
  double vvar = 0; // 荷重中央たわみ/体積（基準モデル）
  double resultPoint = 0; // 点数

  // 対称化
  void symmetrical(){
    int countX = 70;
    int countY = 25;

    for(int y = 0; y < countY; y++){
      for(int x = 0; x < countX/2; x++){
        if(elemList[countX*y+countX-x-1].isCanPaint){
          elemList[countX*y+countX-x-1].e = elemList[countX*y+x].e;
        }
      }
    }
  }

  // 解析
  void calculation(){
    const int npx1 = 70;
    const int npx2 = 25;
    const int nd = 2;

    List<List<int>> zeroOneList = List.generate(npx1, (_) => List.filled(npx2, 0));
    for (int n2 = 0; n2 < npx2; n2++) {
      for (int n1 = 0; n1 < npx1; n1++) {
        zeroOneList[n1][n2] = elemList[npx1*(npx2-n2-1)+n1].e.toInt();
      }
    }

    // 解析実行
    final result = desFEM70x25(zeroOneList, powerType);

    // 変位を入手
    for (int n2 = 0; n2 < npx2+1; n2++) {
      for (int n1 = 0; n1 < npx1+1; n1++) {
        nodeList[(npx1+1)*(npx2-n2)+n1].becPos = Offset(result.$1[((npx1+1)*n2+n1)*nd], result.$1[((npx1+1)*n2+n1)*nd+1]);
      }
    }
    // 変位後の座標
    for(int i = 0; i < nodeList.length; i++){
      nodeList[i].afterPos = Offset(nodeList[i].pos.dx+nodeList[i].becPos.dx, nodeList[i].pos.dy+nodeList[i].becPos.dy);
    }

    // 結果の入手
    for (int n2 = 0; n2 < npx2; n2++) {
      for (int n1 = 0; n1 < npx1; n1++) {
        elemList[npx1*(npx2-n2-1)+n1].strainXY[0] = result.$2[n1][n2][0];
        elemList[npx1*(npx2-n2-1)+n1].strainXY[1] = result.$2[n1][n2][1];
        elemList[npx1*(npx2-n2-1)+n1].strainXY[2] = result.$2[n1][n2][2];
        elemList[npx1*(npx2-n2-1)+n1].stlessXY[0] = result.$3[n1][n2][0];
        elemList[npx1*(npx2-n2-1)+n1].stlessXY[1] = result.$3[n1][n2][1];
        elemList[npx1*(npx2-n2-1)+n1].stlessXY[2] = result.$3[n1][n2][2];
        elemList[npx1*(npx2-n2-1)+n1].stlessXY[3] = result.$3[n1][n2][3];
        elemList[npx1*(npx2-n2-1)+n1].stlessXY[4] = result.$3[n1][n2][4];
      }
    }

    // 最下層要素の変位の体積の1/2
    double he = 2.0; // 要素の幅高さ
    double ss = 0.0; // 面積
    for (int i = 0; i < 35-2; i++) {
      int h1 = 2 + i;
      int h2 = h1 + 1;
      double v1 = nodeList[h1].becPos.dy.abs();
      double v2 = nodeList[h2].becPos.dy.abs();
      double ds = (v1 + v2) * he / 2.0; // 台形の面積
      ss += ds;
    }
    // print(ss);


    // 点数
    double maxBecPos = nodeList[35].becPos.dy.abs();
    // print(maxBecPos);
    int elemLength = elemCount();

    // シグモイド関数
    // vvar = 125446.5437*pow(elemLength,-3.4227461);

    double a = 3.25;
    // ニュートン補間
    double b0, b1, b2;
    if (powerType == 0) {
      // if (elemLength >= 70 && elemLength < 140) {
      //   b0 =  3.4159242117E+00;
      //   b1 = -4.9026406049E-02;
      //   b2 =  3.2743136695E-04;
      //   vvar = b0 + b1 * (elemLength - 70) + b2 * (elemLength - 70) * (elemLength - 105);
      // } else if (elemLength >= 140 && elemLength < 210) {
      //   b0 =  7.8628263731E-01;
      //   b1 = -9.3223610660E-03;
      //   b2 =  6.4502077503E-05;
      //   vvar = b0 + b1 * (elemLength - 140) + b2 * (elemLength - 140) * (elemLength - 175);
      // } else if (elemLength >= 210 && elemLength < 350) {
      //   b0 = 2.9174745257E-01;
      //   b1 = -2.0613303788E-03;
      //   b2 = 8.5850173811E-06;
      //   vvar = b0 + b1 * (elemLength - 210) + b2 * (elemLength - 210) * (elemLength - 280);
      // } else if (elemLength >= 350 && elemLength < 490) {
      //   b0 = 8.7294369877E-02;
      //   b1 = -4.4232646612E-04;
      //   b2 = 1.3426382928E-06;
      //   vvar = b0 + b1 * (elemLength - 350) + b2 * (elemLength - 350) * (elemLength - 420);
      // } else if (elemLength >= 490 && elemLength < 630) {
      //   b0 = 3.8526519889E-02;
      //   b1 = -1.5628977445E-04;
      //   b2 = 3.9630188412E-07;
      //   vvar = b0 + b1 * (elemLength - 490) + b2 * (elemLength - 490) * (elemLength - 560);
      // } else if (elemLength >= 630 && elemLength < 770) {
      //   b0 = 2.0529709931E-02;
      //   b1 = -6.7666021124E-05;
      //   b2 = 1.4764385486E-07;
      //   vvar = b0 + b1 * (elemLength - 630) + b2 * (elemLength - 630) * (elemLength - 700);
      // } else if (elemLength >= 770 && elemLength < 910) {
      //   b0 = 1.2503376751E-02;
      //   b1 = -3.3617200755E-05;
      //   b2 = 6.3902626225E-08;
      //   vvar = b0 + b1 * (elemLength - 770) + b2 * (elemLength - 770) * (elemLength - 840);
      // } else if (elemLength >= 910 && elemLength < 1050) {
      //   b0 = 8.4232143822E-03;
      //   b1 = -1.8513034220E-05;
      //   b2 = 3.1060716901E-08;
      //   vvar = b0 + b1 * (elemLength - 910) + b2 * (elemLength - 910) * (elemLength - 980);
      // }

      if (elemLength >= 70 && elemLength < 140) {
        b0 =  1.14352383677698E+02;
        b1 = -1.66721096221994E+00;
        b2 =  1.18542771682426E-02;
        vvar = b0 + b1 * (elemLength - 70) + b2 * (elemLength - 70) * (elemLength - 105);
      } else if (elemLength >= 140 && elemLength < 210) {
        b0 =  2.66905953844964E+01;
        b1 = -3.05445582414183E-01;
        b2 =  2.00394171633253E-03;
        vvar = b0 + b1 * (elemLength - 140) + b2 * (elemLength - 140) * (elemLength - 175);
      } else if (elemLength >= 210 && elemLength < 350) {
        b0 =  1.02190618205183E+01;
        b1 = -6.97691756490674E-02;
        b2 =  2.83641259924221E-04;
        vvar = b0 + b1 * (elemLength - 210) + b2 * (elemLength - 210) * (elemLength - 280);
      } else if (elemLength >= 350 && elemLength < 490) {
        b0 =  3.23106157690622E+00;
        b1 = -1.59895769550567E-02;
        b2 =  4.69488303935214E-05;
        vvar = b0 + b1 * (elemLength - 350) + b2 * (elemLength - 350) * (elemLength - 420);
      } else if (elemLength >= 490 && elemLength < 630) {
        b0 =  1.45261934105479E+00;
        b1 = -5.87671735944886E-03;
        b2 =  1.46286617935886E-05;
        vvar = b0 + b1 * (elemLength - 490) + b2 * (elemLength - 490) * (elemLength - 560);
      } else if (elemLength >= 630 && elemLength < 770) {
        b0 =  7.73239796309118E-01;
        b1 = -2.58705375400604E-03;
        b2 =  5.58703804795765E-06;
        vvar = b0 + b1 * (elemLength - 630) + b2 * (elemLength - 630) * (elemLength - 700);
      } else if (elemLength >= 770 && elemLength < 910) {
        b0 =  4.65805243618257E-01;
        b1 = -1.29507360226176E-03;
        b2 =  2.44723668462653E-06;
        vvar = b0 + b1 * (elemLength - 770) + b2 * (elemLength - 770) * (elemLength - 840);
      } else if (elemLength >= 910 && elemLength < 1050) {
        b0 =  3.08477858810951E-01;
        b1 = -7.15756135938629E-04;
        b2 =  1.19740054331377E-06;
        vvar = b0 + b1 * (elemLength - 910) + b2 * (elemLength - 910) * (elemLength - 980);
      }
      a = 3.5;
      maxBecPos = ss; // 体積を基準にする
    } else if (powerType == 1) { // 4点曲げ
      // print(nodeList[23].becPos.dy.abs());
      maxBecPos = nodeList[23].becPos.dy.abs();
      if (elemLength >= 70 && elemLength < 140) {
        b0 =  3.83095784081963E+00;
        b1 = -5.80273668805609E-02;
        b2 =  4.53615168754680E-04;
        vvar = b0 + b1 * (elemLength - 70) + b2 * (elemLength - 70) * (elemLength - 105);
      } else if (elemLength >= 140 && elemLength < 210) {
        b0 =  8.80399322629337E-01;
        b1 = -9.72569493226677E-03;
        b2 =  5.66108143337244E-05;
        vvar = b0 + b1 * (elemLength - 140) + b2 * (elemLength - 140) * (elemLength - 175);
      } else if (elemLength >= 210 && elemLength < 350) {
        b0 =  3.38297172488288E-01;
        b1 = -2.29427110273659E-03;
        b2 =  9.29880951489469E-06;
        vvar = b0 + b1 * (elemLength - 210) + b2 * (elemLength - 210) * (elemLength - 280);
      } else if (elemLength >= 350 && elemLength < 490) {
        b0 =  1.08227551351134E-01;
        b1 = -5.30257640222751E-04;
        b2 =  1.54965659068093E-06;
        vvar = b0 + b1 * (elemLength - 350) + b2 * (elemLength - 350) * (elemLength - 420);
      } else if (elemLength >= 490 && elemLength < 630) {
        b0 =  4.91781163086219E-02;
        b1 = -1.95951437338516E-04;
        b2 =  4.86441085534530E-07;
        vvar = b0 + b1 * (elemLength - 490) + b2 * (elemLength - 490) * (elemLength - 560);
      } else if (elemLength >= 630 && elemLength < 770) {
        b0 =  2.65120377194681E-02;
        b1 = -8.64750318306500E-05;
        b2 =  1.86445191479459E-07;
        vvar = b0 + b1 * (elemLength - 630) + b2 * (elemLength - 630) * (elemLength - 700);
      } else if (elemLength >= 770 && elemLength < 910) {
        b0 =  1.62326961396758E-02;
        b1 = -4.33425084092314E-05;
        b2 =  8.18144201538573E-08;
        vvar = b0 + b1 * (elemLength - 770) + b2 * (elemLength - 770) * (elemLength - 840);
      } else if (elemLength >= 910 && elemLength < 1050) {
        b0 =  1.09665262798912E-02;
        b1 = -2.39707508636930E-05;
        b2 =  4.00697386158101E-08;
        vvar = b0 + b1 * (elemLength - 910) + b2 * (elemLength - 910) * (elemLength - 980);
      }
      a = 4;
    } else { // 自重
      if (elemLength >= 70 && elemLength < 140) {
        b0 =  8.33226515366013E+01;
        b1 = -8.09218615331466E-01;
        b2 =  4.97838360573298E-03;
        vvar = b0 + b1 * (elemLength - 70) + b2 * (elemLength - 70) * (elemLength - 105);
      } else if (elemLength >= 140 && elemLength < 210) {
        b0 =  3.88743882974445E+01;
        b1 = -2.82125379926986E-01;
        b2 =  1.57740787186547E-03;
        vvar = b0 + b1 * (elemLength - 140) + b2 * (elemLength - 140) * (elemLength - 175);
      } else if (elemLength >= 210 && elemLength < 350) {
        b0 =  2.29902609886259E+01;
        b1 = -9.27268061060814E-02;
        b2 =  2.81100949420674E-04;
        vvar = b0 + b1 * (elemLength - 210) + b2 * (elemLength - 210) * (elemLength - 280);
      } else if (elemLength >= 350 && elemLength < 490) {
        b0 =  1.27632974380971E+01;
        b1 = -3.73390866924414E-02;
        b2 =  6.98389962465673E-05;
        vvar = b0 + b1 * (elemLength - 350) + b2 * (elemLength - 350) * (elemLength - 420);
      } else if (elemLength >= 490 && elemLength < 630) {
        b0 =  8.22024746437166E+00;
        b1 = -2.05701004427023E-02;
        b2 =  3.64498927922009E-05;
        vvar = b0 + b1 * (elemLength - 490) + b2 * (elemLength - 490) * (elemLength - 560);
      } else if (elemLength >= 630 && elemLength < 770) {
        b0 =  5.69764235175691E+00;
        b1 = -1.17497724276513E-02;
        b2 =  1.94089794928541E-05;
        vvar = b0 + b1 * (elemLength - 630) + b2 * (elemLength - 630) * (elemLength - 700);
      } else if (elemLength >= 770 && elemLength < 910) {
        b0 =  4.24288221091570E+00;
        b1 = -7.02637280466071E-03;
        b2 =  1.07265644494510E-05;
        vvar = b0 + b1 * (elemLength - 770) + b2 * (elemLength - 770) * (elemLength - 840);
      } else if (elemLength >= 910 && elemLength < 1050) {
        b0 =  3.36431034986782E+00;
        b1 = -4.38305983819901E-03;
        b2 =  6.29674005598068E-06;
        vvar = b0 + b1 * (elemLength - 910) + b2 * (elemLength - 910) * (elemLength - 980);
      }
      a = 3.5;
      maxBecPos = ss; // 自重のときは体積を基準にする
    }
    vvar = vvar/elemLength;

    double vvvar = maxBecPos/elemLength-vvar;
    // if(vvvar > 0){
    //   a = 0.5;
    // }
    resultPoint = 100 * (1-1/(1+(pow(e, -a*(vvvar)/vvar))));
    selectResult(3);

    isCalculation = true;
  }
  void resetCalculation(){
    for(int i = 0; i < elemList.length; i++){
      for(int j = 0; j < elemList[i].stlessXY.length; j++){
        elemList[i].stlessXY[j] = 0;
      }
      for(int j = 0; j < elemList[i].strainXY.length; j++){
        elemList[i].strainXY[j] = 0;
      }
    }

    isCalculation = false;
  }
  void selectResult(int num){ // 結果
    resultList = List.filled(elemList.length, 0);
    for (int i = 0; i < elemList.length; i++) {
      if(num == 0) {
        resultList[i] = elemList[i].stlessXY[0];
      } else if(num == 1) {
        resultList[i] = elemList[i].stlessXY[1];
      } else if(num == 2) {
        resultList[i] = elemList[i].stlessXY[2];
      } else if(num == 3) {
        resultList[i] = elemList[i].stlessXY[3];
      } else if(num == 4) {
        resultList[i] = elemList[i].stlessXY[4];
      } else if(num == 5) {
        resultList[i] = elemList[i].strainXY[0];
      } else if(num == 6) {
        resultList[i] = elemList[i].strainXY[1];
      } else if(num == 7) {
        resultList[i] = elemList[i].strainXY[2];
      } else {
        resultList = List.empty();
      }
    }

    resultList = MyCalculator.normalizeArray(resultList);

    resultMax = resultList.reduce(max);
    resultMin = resultList.reduce(min);
  }

  // 節点の選択
  void initSelect(){
    selectedNumber = -1;
    for(int i = 0; i < elemList.length; i++){
      elemList[i].isSelect = false;
    }
    for(int i = 0; i < nodeList.length; i++){
      nodeList[i].isSelect = false;
    }
  }
  void selectElem(Offset pos, int type){
    initSelect();

    for(int i = 0; i < elemList.length; i++){
      List<Offset> nodePosList = List.empty(growable: true);
      for(int j = 0; j < elemNode; j++){
        nodePosList.add(elemList[i].nodeList[j]!.pos);
      }
      // 四角形のとき
      Offset p0 = elemList[i].nodeList[0]!.pos;
      Offset p1 = elemList[i].nodeList[1]!.pos;
      Offset p2 = elemList[i].nodeList[2]!.pos;
      Offset p3 = elemList[i].nodeList[3]!.pos;
      if(isCalculation){
        p0 = elemList[i].nodeList[0]!.pos + elemList[i].nodeList[0]!.becPos*dispScale;
        p1 = elemList[i].nodeList[1]!.pos + elemList[i].nodeList[1]!.becPos*dispScale;
        p2 = elemList[i].nodeList[2]!.pos + elemList[i].nodeList[2]!.becPos*dispScale;
        p3 = elemList[i].nodeList[3]!.pos + elemList[i].nodeList[3]!.becPos*dispScale;
      }

      if(MyCalculator.isPointInRectangle(pos, p0, p1, p2, p3)){
        selectedNumber = i;
        elemList[i].isSelect = true;
        return;
      }
    }
  }
}

class Node
{
  // 基本データ
  int number = 0;
  Offset pos = Offset.zero;
  List<bool> constXY = [false, false]; // 拘束（0:x、1:y）
  List<double> loadXY = [0, 0]; // 荷重（0:x、1:y）

  // 計算結果
  Offset becPos = Offset.zero;
  Offset afterPos = Offset.zero;
  List<double> result = [0,0,0,0,0,0,0,0,0]; // 0:たわみ、1:たわみ角1、2:たわみ角2

  // キャンバス情報
  bool isSelect = false; // 選択されているか
}

class Elem
{
  // 基本データ
  int number = 0;
  double e = 0.0;
  double v = 0.0;
  List<Node?> nodeList = [null, null, null, null];
  double load = 0.0; // 分布荷重

  // 計算結果
  List<double> strainXY = [0,0,0]; // 0:X方向ひずみ、1:Y方向ひずみ、2:せん断ひずみ
  List<double> stlessXY = [0,0,0,0,0,0,0]; // 0:X方向応力、1:Y方向応力、2:せん断応力、3:最大主応力、4:最小主応力、5:曲げモーメント左、6:曲げモーメント右
  List<double> result = [0,0,0,0,0,0,0,0,0]; // 0:たわみ1、1:たわみ角1、2:たわみ2、3:たわみ角2、4:せん断力、5:曲げモーメント1、6:曲げモーメント2

  // キャンバス情報
  bool isSelect = false; // 選択されているか
  bool isCanPaint = true; // 色がかわるか
}
