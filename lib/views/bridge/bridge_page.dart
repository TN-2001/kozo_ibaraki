import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/views/bridge/bridge_data.dart';
import 'package:kozo_ibaraki/views/bridge/bridge_painter.dart';
import 'package:kozo_ibaraki/components/my_decorations.dart';
import 'package:kozo_ibaraki/components/my_widgets.dart';
import 'package:kozo_ibaraki/views/common/common_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class BridgePage extends StatefulWidget {
  const BridgePage({super.key});

  @override
  State<BridgePage> createState() => _BridgePageState();
}

class _BridgePageState extends State<BridgePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // メニュー用キー
  late BridgeData data; // データ
  static List<String> mathTpeList = ["中央荷重", "分布荷重", "自重"];
  static List<String> devTypeXYList = 
    ["X方向応力","Y方向応力","せん断応力","最大主応力","最小主応力","X方向ひずみ","y方向ひずみ","せん断ひずみ"];
  int toolNum = 0, devTypeNum = 0;

  @override
  void initState() {
    super.initState();

    data = BridgeData(onDebug: (value){});
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold (
      scaffoldKey: _scaffoldKey,

      drawer: CommonDrawer(
        onPressedHelpButton: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("使い方（動画リンク）"),
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width / 1.5,
                  height: MediaQuery.sizeOf(context).width / 1.5 /16*9,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: (){
                        final url = Uri.parse('https://youtu.be/9TabbZ8wR9A');
                        launchUrl(url);
                      },
                      child: Image.asset(
                        "assets/images/youtube/3.jpg",
                      )
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("閉じる"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            },
          );
        },
      ),

      // ヘッダーメニュー
      header: MyHeader(
        isBorder: true,

        left: [
          //メニューボタン
          MyIconButton(
            icon: Icons.menu, 
            message: "メニュー",
            onPressed: (){
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          if(!data.isCalculation)...{
            // ツールメニュー
            MyIconToggleButtons(
              icons: const [Icons.edit, Icons.auto_fix_normal], 
              messages: const ['ペン','消しゴム'],
              value: toolNum, 
              onPressed: (value){
                setState(() {
                  toolNum = value;
                });
              }
            ),
            // 対称化ボタン
            MyIconButton(
              icon: Icons.switch_right,
              message: "対称化（左を右にコピー）",
              onPressed: () {
                setState(() {
                  data.symmetrical();
                });
              },
            ),
            // 荷重タイプ
            MyMenuDropdown(
              items: mathTpeList,
              value: data.powerType,
              onPressed: (value){
                setState(() {
                  data.powerType = value;
                });
              },
            ),
          },
        ],

        right: [
          if(!data.isCalculation)...{
            // 解析開始ボタン
            MyIconButton(
              icon: Icons.play_arrow,
              message: "計算",
              onPressed: (){
                setState(() {
                  data.calculation();
                  devTypeNum = 0;
                });
              },
            ),
          }else...{
            // 解析結果選択
            MyMenuDropdown(
              items: devTypeXYList,
              value: devTypeNum,
              onPressed: (value){
                devTypeNum = value;
                setState(() {
                  data.selectResult(value);
                });
              },
            ),
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
        ],
      ),

      // メインビュー
      body: MyCustomPaint(
        backgroundColor: MyColors.wiget1,
        onTap: (position) {
          if(data.isCalculation){
            setState(() {
              data.selectElem(position,0);
              if(data.selectedNumber >= 0){
                data.selectedNumber = data.selectedNumber;
              }
            });
          }
        },
        onDrag: (position) {
          if(!data.isCalculation){
            setState(() {
              data.selectElem(position,0);
              if(data.selectedNumber >= 0){
                if(toolNum == 0 && data.elemList[data.selectedNumber].e < 1){
                  data.elemList[data.selectedNumber].e = 1;
                }
                else if(toolNum == 1 && data.elemList[data.selectedNumber].e > 0){
                  data.elemList[data.selectedNumber].e = 0;
                }
              }
            });
          }
        },
        painter: BridgePainter(data: data),
      ),
    );
  }
}