import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/components/my_decorations.dart';
import 'package:kozo_ibaraki/components/my_widgets.dart';
import 'package:kozo_ibaraki/apps/beam/beam_painter.dart';
import 'package:kozo_ibaraki/apps/beam/beam_data.dart';
import 'package:kozo_ibaraki/main.dart';


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

  int currentMenuNumber = -1;
  final FocusNode _focusElemSetting0 = FocusNode(); // 設定画面の要素0
  final FocusNode _focusElemSetting1 = FocusNode(); // 設定画面の要素1
  final FocusNode _focusElemSetting2 = FocusNode(); // 設定画面の要素2
  final FocusNode _focusElemSetting3 = FocusNode(); // 設定画面の要素3
  final FocusNode _focusElemSetting4 = FocusNode(); // 設定画面の要素4


  @override
  void initState() {
    super.initState();
    data = BeamData(onDebug: (value){},);
    data.node = Node();
    _focusElemSetting0.addListener(() {
      if (_focusElemSetting0.hasFocus) {
        currentMenuNumber = 0;
      }
    });
    _focusElemSetting1.addListener(() {
      if (_focusElemSetting1.hasFocus) {
        currentMenuNumber = 1;
      }
    });
    _focusElemSetting2.addListener(() {
      if (_focusElemSetting2.hasFocus) {
        currentMenuNumber = 2;
      }
    });
    _focusElemSetting3.addListener(() {
      if (_focusElemSetting3.hasFocus) {
        currentMenuNumber = 3;
      }
    });
    _focusElemSetting4.addListener(() {
      if (_focusElemSetting4.hasFocus) {
        currentMenuNumber = 4;
      }
    });
  }


  @override
  void dispose() {
    super.dispose(); 
    _focusElemSetting0.dispose();
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

    return MyScaffold(
      scaffoldKey: _scaffoldKey,

      drawer: drawer(context),
      
      header: MyHeader(
        isBorder: true,
        left: [
          // メニューボタン
          MyIconButton(
            icon: Icons.menu,
            message: "メニュー", 
            onPressed: (){
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          if(!data.isCalculation)...{
            // ツールタイプ
            MyIconToggleButtons(
              icons: const [Icons.circle, Icons.square], 
              messages: const ["節点", "要素"],
              value: toolTypeNum, 
              onPressed: (value){
                initValue();
                setState(() {
                  toolTypeNum = value;
                  data.node = null;
                  data.elem = null;
                  if(toolTypeNum == 0 && toolNum == 0){
                    data.node = Node();
                    data.node!.number = data.nodeList.length;
                  }else if(toolTypeNum == 1 && toolNum == 0){
                    data.elem = Elem();
                    data.elem!.number = data.elemList.length;
                    data.elem!.e = 1;
                    data.elem!.v = 1;
                  }
                  data.initSelect();
                });
              }
            ),
            // ツール
            if(toolTypeNum < 2)...{
              MyIconToggleButtons(
                icons: const [Icons.add, Icons.touch_app], 
                messages: const ["新規","修正"],
                value: toolNum, 
                onPressed: (value){
                  initValue();
                  setState(() {
                    toolNum = value;
                    data.node = null;
                    data.elem = null;
                    if(toolTypeNum == 0 && toolNum == 0){
                      data.node = Node();
                      data.node!.number = data.nodeList.length;
                    }else if(toolTypeNum == 1 && toolNum == 0){
                      data.elem = Elem();
                      data.elem!.number = data.elemList.length;
                      data.elem!.e = 1;
                      data.elem!.v = 1;
                    }
                    data.initSelect();
                  });
                }
              ),
            },
          },
        ],

        right: [
          if(!data.isCalculation)...{
            // 解析開始ボタン
            MyIconButton(
              icon: Icons.play_arrow,
              message: "計算",
              onPressed: (){
                onCalculation();
              },
            ),
          }else...{
            // 解析結果選択
            if(!isSumaho)... {
              MyMenuDropdown(
                items: const ["変形図", "反力", "せん断力図","曲げモーメント図",],
                value: devTypeNum,
                onPressed: (value){
                  setState(() {
                    devTypeNum = value;
                  });
                },
              ),
            }else...{
              MyMenuDropdown(
                items: const ["変形図", "反力"],
                value: devTypeNum,
                onPressed: (value){
                  setState(() {
                    devTypeNum = value;
                  });
                },
              ),
            },
            // 再開ボタン
            MyIconButton(
              icon: Icons.restart_alt,
              message: "再編集",
              onPressed: (){
                setState(() {
                  data.resetCalculation();
                });
              },
            ),
          }
        ]
      ),

      body: Stack(
        children: [
          // メインビュー
          MyCustomPaint(
            backgroundColor: MyColors.wiget1,
            onTap: (position) {
              if(!data.isCalculation){
                setState(() {
                  if(toolNum == 1){
                    if(toolTypeNum == 0){
                      data.selectNode(position);
                    }
                    else if(toolTypeNum == 1 && (currentMenuNumber >= 2 || currentMenuNumber == -1)){
                      data.selectElem(position);
                    }
                  }
                });
                // 要素設定時
                if(toolTypeNum == 1 && (0 <= currentMenuNumber && currentMenuNumber <= 1)){
                  data.selectNode(position);
                  if(data.selectNodeNumber >= 0){
                    setState(() {
                      if (currentMenuNumber == 0 && currentElem.nodeList[1] != data.nodeList[data.selectNodeNumber]) {
                        currentElem.nodeList[0] = data.nodeList[data.selectNodeNumber];
                      } else if (currentElem.nodeList[0] != data.nodeList[data.selectNodeNumber]){
                        currentElem.nodeList[1] = data.nodeList[data.selectNodeNumber];
                      }
                    });
                  }
                  initValue();
                  data.initSelect(isElem: false);
                }
              }
            },
            painter: BeamPainter(data: data, devTypeNum: devTypeNum, isSumaho: isSumaho),
          ),
          if(!data.isCalculation)...{
            if(toolTypeNum == 0)...{
              if(toolNum == 0)...{
                // 新規ノード
                nodeSetting(true, size.width),
              }
              else if(data.selectNodeNumber >= 0)...{
                // 既存ノード
                nodeSetting(false, size.width),
              }
            }
            else if(toolTypeNum == 1)...{
              if(toolNum == 0)...{
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
          name: "X",
          labelAlignment: Alignment.centerRight,
          width: propWidth,
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
          name: "Y",
          labelAlignment: Alignment.centerRight,
          width: propWidth,
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
          width: propWidth,
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
          width: propWidth,
          boolValue: node.constXYR[3],
          onChangedBool: (value) {
            setState(() {
              node.constXYR[3] = value;
            });
          },
        );
      }
      MyProperty prop3_1(Node node) {
        return MyProperty(
          name: "鉛直",
          labelAlignment: Alignment.centerRight,
          width: propWidth*2,
          filledWidth: 75,
          doubleValue: (node.loadXY[1] != 0.0) ? node.loadXY[1] : null,
          onChangedDouble: (value) {
            node.loadXY[1] = value;
          },
        );
      }
      MyProperty prop3_2(Node node) {
        return MyProperty(
          name: "モーメント",
          labelAlignment: Alignment.centerRight,
          width: propWidth*2,
          filledWidth: 75,
          doubleValue: (node.loadXY[2] != 0.0) ? node.loadXY[2] : null,
          onChangedDouble: (value) {
            node.loadXY[2] = value;
          },
        );
      }

      return [
        MyProperty(
          name: "座標",
          labelWidth: labelWidth,
          children: [
            MyProperty(
              name: "X",
              labelAlignment: Alignment.centerRight,
              width: propWidth*2,
              filledWidth: 75,
              doubleValue: node.pos.dx,
              onChangedDouble: (value) {
                node.pos = Offset(value, node.pos.dy);
              },
            )
          ],
        ),
        MyProperty(
          name: "拘束",
          labelWidth: labelWidth,
          children: [
            prop2_1(node),
            prop2_2(node),
            prop2_3(node),
            prop2_4(node),
          ],
        ),
        MyProperty(
          name: "集中荷重",
          labelWidth: labelWidth,
          children: [
            prop3_1(node),
            prop3_2(node),
          ],
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
            initValue();
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
          name: "節点番号",
          labelWidth: 75,
          children: [
            MyProperty(
              name: "a",
              labelAlignment: Alignment.centerRight,
              width: propWidth*2,
              filledWidth: 75,
              intValue: (elem.nodeList[0] != null) ? (elem.nodeList[0]!.number+1) : null,
              onChangedInt: (value) {
                if(0 <= value-1  && value-1 < data.nodeList.length){
                  elem.nodeList[0] = data.nodeList[value-1];
                }
              },
              focusNode: _focusElemSetting0,
            ),
            MyProperty(
              name: "b",
              labelAlignment: Alignment.centerRight,
              width: propWidth*2,
              filledWidth: 75,
              intValue: (elem.nodeList[1] != null) ? (elem.nodeList[1]!.number+1) : null,
              onChangedInt: (value) {
                if(0 <= value-1 && value-1 < data.nodeList.length){
                  elem.nodeList[1] = data.nodeList[value-1];
                }
              },
              focusNode: _focusElemSetting1,
            )
          ],
        ),
        MyProperty(
          name: "剛性",
          labelWidth: 75,
          children: [
            MyProperty(
              name: "ヤング率",
              labelAlignment: Alignment.centerRight,
              width: propWidth*2,
              filledWidth: 75,
              doubleValue: elem.e,
              onChangedDouble: (value) {
                elem.e = value;
              },
              focusNode: _focusElemSetting2,
            ),
            MyProperty(
              name: "断面二次モーメント",
              labelAlignment: Alignment.centerRight,
              width: propWidth*2,
              filledWidth: 75,
              doubleValue: elem.v,
              onChangedDouble: (value) {
                elem.v = value;
              },
              focusNode: _focusElemSetting3,
            ),
          ],
        ),
        MyProperty(
          name: "分布荷重",
          labelWidth: 75,
          children: [
            MyProperty(
              name: "鉛直",
              labelAlignment: Alignment.centerRight,
              width: propWidth*2,
              filledWidth: 75,
              doubleValue: (elem.load != 0.0) ? elem.load : null,
              onChangedDouble: (value) {
                elem.load = value;
              },
              focusNode: _focusElemSetting4,
            ),
          ],
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
          initValue();
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
          initValue();
          setState(() {
            data.removeElem(data.selectElemNumber);
            data.initSelect();
          });
        },
        width
      );
    }
  }


  // 値を初期化
  void initValue(){
    currentMenuNumber = -1;
  }

  // 計算ボタン
  void onCalculation(){
    bool isPower = false;

    int xyrConstCount = 0;
    int xyConstCount = 0;
    int yConstCount = 0;

    for(int i = 0; i < data.nodeList.length; i++){
      if(data.nodeList[i].constXYR[0] && data.nodeList[i].constXYR[1] && data.nodeList[i].constXYR[2]){
        xyrConstCount ++;
      }else if(data.nodeList[i].constXYR[0] && data.nodeList[i].constXYR[1]){
        xyConstCount ++;
      }else if(data.nodeList[i].constXYR[1]){
        yConstCount ++;
      }

      if((!data.nodeList[i].constXYR[1] && data.nodeList[i].loadXY[1] != 0)
        || (!data.nodeList[i].constXYR[2] && data.nodeList[i].loadXY[2] != 0)){
          isPower = true;
      }
    }

    for(int i = 0; i < data.elemList.length; i++){
      if(data.elemList[i].load != 0){
        isPower = true;
      }
    }

    if(data.elemList.isEmpty){
      snacbar("節点は2つ以上、要素は1つ以上必要");
    }else if(!(xyrConstCount > 0) && !(xyConstCount > 0 && yConstCount > 0)){
      snacbar("拘束条件が不足");
    }else if(!isPower){
      snacbar("荷重条件が不足");
    }else{
      setState(() {
        data.calculation();
      });
    }
  }

  // メッセージ
  void snacbar(String text){
    final snackBar = SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: '閉じる', 
        onPressed: () {  },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

