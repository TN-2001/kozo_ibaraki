import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/apps/bridgegame/bridgegame_data.dart';
import 'package:kozo_ibaraki/apps/bridgegame/bridgegame_painter.dart';
import 'package:kozo_ibaraki/components/my_widgets.dart';
import 'package:kozo_ibaraki/main.dart';

class BridgegamePage extends StatefulWidget {
  const BridgegamePage({super.key});

  @override
  State<BridgegamePage> createState() => _BridgegamePageState();
}

class _BridgegamePageState extends State<BridgegamePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // メニュー用キー
  late BridgegameData data; // データ
  int toolNum = 0;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();

    data = BridgegameData(onDebug: (value){});
    loadImage('assets/images/background/material-03_02.png');
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold (
      scaffoldKey: _scaffoldKey,

      drawer: drawer(context),

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
          },
        ],

        right: [
          if(!data.isCalculation)...{
            // 解析開始ボタン
            MyIconButton(
              icon: Icons.play_arrow,
              message: "計算",
              onPressed: (){
                if(data.elemCount() <= 1000){
                  setState(() {
                    data.calculation();
                  });
                }else{
                  snacbar();
                }
              },
            ),
          }else...{
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
      body: Stack(
        children:[
          if(_image != null)...{
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: BridgegameBackgroundPainter(data: data, image: _image!)
              ),
            ),
          },
          painter(),
        ]
      )
    );
  }

  // カスタムペインター
  Widget painter(){
    return MyCustomPaint(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
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
          data.selectElem(position,0);
          if(data.selectedNumber >= 0){
            if(data.elemList[data.selectedNumber].isCanPaint){
              if(toolNum == 0 && data.elemList[data.selectedNumber].e < 1){
                data.elemList[data.selectedNumber].e = 1;
              }
              else if(toolNum == 1 && data.elemList[data.selectedNumber].e > 0){
                data.elemList[data.selectedNumber].e = 0;
              }
            }
          }
          setState(() {
          });
        }
      },
      painter: BridgegamePainter(data: data), 
    );
  }

  // メッセージ
  void snacbar(){
    final snackBar = SnackBar(
      content: const Text('体積は1000以下にしよう'),
      action: SnackBarAction(
        label: '閉じる', 
        onPressed: () {  },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> loadImage(String asset) async {
    // final ImageStream stream = AssetImage(asset).resolve(
    //   const ImageConfiguration()
    // );
    // final Completer<ui.Image> completer = Completer();
    // stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
    //   completer.complete(info.image);
    // }));
    // final ui.Image image = await completer.future;
    final ImageStream stream = AssetImage(asset).resolve(
      const ImageConfiguration(), // devicePixelRatioの指定を削除
    );
    final Completer<ui.Image> completer = Completer();
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));
    final ui.Image image = await completer.future;

  
    // デバッグ情報を出力
    setState(() {
      _image = image;
    });
  }
}

class BridgegameBackgroundPainter extends CustomPainter {
  const BridgegameBackgroundPainter({required this.data, required this.image});

  final BridgegameData data;
  final ui.Image image;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    data.updateCanvasPos(Rect.fromLTRB((size.width/10), (size.height/4), size.width-(size.width/10), size.height-(size.height/4)), 0);
    double scale = data.canvasData.scale;

    double imageWidth = image.width.toDouble();
    double imageHeight = image.height.toDouble();
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imageWidth, imageHeight), // 画像全体の範囲
      Rect.fromLTWH(size.width/2-(imageWidth/2+23)*scale/22.7, size.height/2-(imageHeight/2-630)*scale/22.7, imageWidth*scale/22.7, imageHeight*scale/22.7),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant BridgegameBackgroundPainter oldDelegate) {
    return false;
  }
}