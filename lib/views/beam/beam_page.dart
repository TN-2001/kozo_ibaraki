import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/components/base_divider.dart';
import 'package:kozo_ibaraki/components/my_decorations.dart';
import 'package:kozo_ibaraki/components/my_widgets.dart';
import 'package:kozo_ibaraki/constants/colors.dart';
import 'package:kozo_ibaraki/views/beam/beam_painter.dart';
import 'package:kozo_ibaraki/views/beam/beam_data.dart';
import 'package:kozo_ibaraki/main.dart';
import 'package:kozo_ibaraki/views/beam/ui/beam_bar.dart'; // スマホアプリのときはコメントアウト


class BeamPage extends StatefulWidget {
  const BeamPage({super.key});

  @override
  State<BeamPage> createState() => _BeamPageState();
}

class _BeamPageState extends State<BeamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BeamData data;
  int devTypeNum = 0;
  int toolTypeNum = 0, toolNum = 0;
  bool isSumaho = false;
  Elem currentElem = Elem();


  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }


  @override
  void initState() {
    super.initState();
    data = BeamData(onDebug: (value){},);
    data.node = Node();
    data.addListener(_onUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size; // 画面サイズ取得
    if(size.height > size.width && isSumaho == false) {
      setState(() {
        isSumaho = true;
        if(devTypeNum > 1){
          devTypeNum = 0;
        }
      });
    }else if (size.height < size.width && isSumaho == true) {
      setState(() {
        isSumaho = false;
      });
    }  

    return Scaffold(
      backgroundColor: BaseColors.baseColor,
      key: _scaffoldKey,
      drawer: drawer(context), // スマホアプリのときはコメントアウト
      body: Column(
        children: [
          BeamBar(controller: data, scaffoldKey: _scaffoldKey),
          
          const BaseDivider(),

          Expanded(
            child: Stack(
              children: [
                BeamCanvas(controller: data, devTypeNum: data.getResultIndex, isSumaho: isSumaho),

                if(!data.isCalculation)...{
                  if(data.getTypeIndex == 0)...{
                    if(data.getToolIndex == 0)...{
                      // 新規ノード
                      nodeSetting(true, size.width),
                    }
                    else if(data.selectNodeNumber >= 0)...{
                      // 既存ノード
                      nodeSetting(false, size.width),
                    }
                  }
                  else if(data.getTypeIndex == 1)...{
                    if(data.getToolIndex == 0)...{
                      // 新規要素
                      elemSetting(true, size.width),
                    }
                    else if(data.selectElemNumber >= 0)...{
                      // 既存要素
                      elemSetting(false, size.width),
                    }
                  }
                },
              ]
            ),
          ),
        ],
      ),
    );
  }

  Widget settingPC(List<MyProperty> propertyList, String title, String buttonName, Function() onButtonPressed, double width) {
    return MyAlign(
      alignment: Alignment.bottomCenter,
      isIntrinsicHeight: true,
      isIntrinsicWidth: true,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        decoration: myBoxDecoration,
        child: Column(children: [
          MyProperty(
            name: title,
            width: (width > 505) ? 475 : width-30,
            buttonName: buttonName,
            onButtonPressed: onButtonPressed,
          ),
          const SizedBox(height: 5,),
          const Divider(height: 0, color: MyColors.border,),
          const SizedBox(height: 5,),
          for(int i = 0; i < propertyList.length; i++)...{
            propertyList[i],
            if(i < propertyList.length-1)...{
              const SizedBox(height: 2.5,),
            }
          },
        ],),
      )
      
    );
  }

  Widget nodeSetting(bool isAdd, double width) {
    double propWidth = (width > 505) ? 100 : (width-30-75-4)/4;
    double labelWidth = 75;

    List<MyProperty> propertyList(Node node) {
      MyProperty prop2_1(Node node) {
        return MyProperty(
          name: "水平",
          labelAlignment: Alignment.centerRight,
          width: propWidth > 70 ? 70 : propWidth,
          boolValue: node.constXYR[0],
          onChangedBool: (value) {
            setState(() {
              node.constXYR[0] = value;
            });
          },
        );
      }
      MyProperty prop2_2(Node node) {
        return MyProperty(
          name: "鉛直",
          labelAlignment: Alignment.centerRight,
          width: propWidth > 70 ? 70 : propWidth,
          boolValue: node.constXYR[1],
          onChangedBool: (value) {
            setState(() {
              node.constXYR[1] = value;
            });
          },
        );
      }
      MyProperty prop2_3(Node node) {
        return MyProperty(
          name: "回転",
          labelAlignment: Alignment.centerRight,
          width: propWidth > 70 ? 70 : propWidth,
          boolValue: node.constXYR[2],
          onChangedBool: (value) {
            setState(() {
              node.constXYR[2] = value;
            });
          },
        );
      }
      MyProperty prop2_4(Node node) {
        return MyProperty(
          name: "ヒンジ",
          labelAlignment: Alignment.centerRight,
          width: propWidth > 70 ? 70 : propWidth,
          boolValue: node.constXYR[3],
          onChangedBool: (value) {
            setState(() {
              node.constXYR[3] = value;
            });
          },
        );
      }

      return [
        MyProperty(
          name: "節点座標（1次元）",
          labelWidth: labelWidth+propWidth*2,
          filledWidth: propWidth*2,
          doubleValue: node.pos.dx,
          onChangedDouble: (value) {
            node.pos = Offset(value, node.pos.dy);
          },
        ),
        MyProperty(
          name: "拘束条件",
          width: labelWidth+propWidth*4,
          children: [
            prop2_1(node),
            prop2_2(node),
            prop2_3(node),
            prop2_4(node),
          ],
        ),
        // MyProperty(
        //   name: "集中荷重",
        //   labelWidth: labelWidth,
        //   children: [
        //     prop3_1(node),
        //     prop3_2(node),
        //   ],
        // ),
        MyProperty(
          name: "集中荷重（鉛直方向）",
          labelWidth: labelWidth+propWidth*2,
          filledWidth: propWidth*2,
          doubleValue: (node.loadXY[1] != 0.0) ? node.loadXY[1] : null,
          onChangedDouble: (value) {
            node.loadXY[1] = value;
          },
        ),
        MyProperty(
          name: "モーメント荷重",
          labelWidth: labelWidth+propWidth*2,
          filledWidth: propWidth*2,
          doubleValue: (node.loadXY[2] != 0.0) ? node.loadXY[2] : null,
          onChangedDouble: (value) {
            node.loadXY[2] = value;
          },
        ),
      ];
    }

    if(isAdd){
      // 追加時
      return settingPC(
        propertyList(data.node!), 
        "No. ${data.node!.number+1}", 
        "追加", 
        (){
          setState(() {
            data.addNode();
            data.initSelect();
          });
        },
        width
      );
    }
    else{
      // タッチ時
      return settingPC(
        propertyList(data.nodeList[data.selectNodeNumber]), 
        "No. ${data.nodeList[data.selectNodeNumber].number+1}", 
        "削除", 
        (){
          setState(() {
            data.removeNode(data.selectNodeNumber);
            data.initSelect();
          });
        },
        width
      );
    }
  }

  Widget elemSetting(bool isAdd, double width) {
    double propWidth = (width > 505) ? 100 : (width-30-75-4)/4;
    List<MyProperty> propertyList(Elem elem) {
      currentElem = elem;
      return [
        MyProperty(
          name: "結合情報（節点番号）",
          labelWidth: 75+propWidth*2,
          children: [
            MyProperty(
              width: propWidth,
              filledWidth: propWidth,
              intValue: (elem.nodeList[0] != null) ? (elem.nodeList[0]!.number+1) : null,
              onChangedInt: (value) {
                if(0 <= value-1  && value-1 < data.nodeList.length){
                  elem.nodeList[0] = data.nodeList[value-1];
                }
              },
            ),
            MyProperty(
              width: propWidth,
              filledWidth: propWidth,
              intValue: (elem.nodeList[1] != null) ? (elem.nodeList[1]!.number+1) : null,
              onChangedInt: (value) {
                if(0 <= value-1 && value-1 < data.nodeList.length){
                  elem.nodeList[1] = data.nodeList[value-1];
                }
              },
            )
          ],
        ),
        MyProperty(
          name: "ヤング率",
          labelWidth: 75+propWidth*2,
          filledWidth: propWidth*2,
          doubleValue: elem.e,
          onChangedDouble: (value) {
            elem.e = value;
          },
        ),
        MyProperty(
          name: "断面二次モーメント",
          labelWidth: 75+propWidth*2,
          filledWidth: propWidth*2,
          doubleValue: elem.v,
          onChangedDouble: (value) {
            elem.v = value;
          },
        ),
        MyProperty(
          name: "等分布荷重（鉛直方向）",
          labelWidth: 75+propWidth*2,
          filledWidth: propWidth*2,
          doubleValue: (elem.load != 0.0) ? elem.load : null,
          onChangedDouble: (value) {
            elem.load = value;
          },
        ),
      ];
    }

    if(isAdd){
      // 追加時
      return settingPC(
        propertyList(data.elem!), 
        "No. ${data.elem!.number+1}", 
        "追加", 
        (){
          setState(() {
            data.addElem();
            data.elem!.e = 1;
            data.elem!.v = 1;
            data.initSelect();
          });
        },
        width
      );
    }
    else{
      // タッチ時
      return settingPC(
        propertyList(data.elemList[data.selectElemNumber]), 
        "No. ${data.elemList[data.selectElemNumber].number+1}",
        "削除", 
        (){
          setState(() {
            data.removeElem(data.selectElemNumber);
            data.initSelect();
          });
        },
        width
      );
    }
  }

}

