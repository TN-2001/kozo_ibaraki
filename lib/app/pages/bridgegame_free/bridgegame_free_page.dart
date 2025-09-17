import 'package:flutter/material.dart';

class BridgegameFreePage extends StatefulWidget {
  const BridgegameFreePage({super.key});

  @override
  State<BridgegameFreePage> createState() => _BridgegameFreePageState();
}

class _BridgegameFreePageState extends State<BridgegameFreePage> {
  // int _toolNum = 0;
  // final Camera _camera = Camera(1.0, Offset.zero, Offset.zero); // カメラ

  @override
  void initState() {
    super.initState();

    // _data = BridgegameFreeData();
    // loadImage('assets/images/background/brigegame3_02.png');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("準備中"),
      ),
    );
    // return MyScaffold (
    //   scaffoldKey: _scaffoldKey,

    //   drawer: CommonDrawer(
    //     onPressedHelpButton: () {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return Dialog.fullscreen(
    //             backgroundColor: MyColors.baseBackground,

    //             child: Column(
    //               children: [
    //                 ToolBar(
    //                   children: [
    //                     ToolIconButton(
    //                       onPressed: () {
    //                         Navigator.pop(context);
    //                       }, 
    //                       icon: const Icon(Icons.keyboard_arrow_left_sharp),
    //                       message: "戻る",
    //                     ),
    //                   ]
    //                 ),

    //                 const BaseDivider(),

    //                 Expanded(
    //                   child: SingleChildScrollView(
    //                     child: Center(
    //                       child: Container(
    //                         constraints: const BoxConstraints(maxWidth: 1080),
    //                         child: Column(
    //                           children: [
    //                             const SizedBox(height: 10),
    //                             Image.asset("assets/images/help/help_01.png"),
    //                             const SizedBox(height: 10),
    //                             Image.asset("assets/images/help/help_02.png"),
    //                             const SizedBox(height: 10),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           );
    //         },
    //       );
    //     },
    //   ),

    //   // ヘッダーメニュー
    //   header: MyHeader(
    //     isBorder: true,

    //     left: [
    //       //メニューボタン
    //       MyIconButton(
    //         icon: Icons.menu, 
    //         message: "メニュー",
    //         onPressed: (){
    //           _scaffoldKey.currentState!.openDrawer();
    //         },
    //       ),
    //       if(!_data.isCalculation)...{
    //         // ツールメニュー
    //         MyIconToggleButtons(
    //           icons: const [Icons.edit, Icons.auto_fix_normal], 
    //           messages: const ['ペン','消しゴム'],
    //           value: _toolNum, 
    //           onPressed: (value){
    //             setState(() {
    //               _toolNum = value;
    //             });
    //           }
    //         ),
    //         // 対称化ボタン
    //         MyIconButton(
    //           icon: Icons.switch_right,
    //           message: "対称化（左を右にコピー）",
    //           onPressed: () {
    //             setState(() {
    //               _data.symmetrical();
    //             });
    //           },
    //         ),
    //         // 問題条件
    //         MyMenuDropdown(
    //           items: const ["3点曲げ","4点曲げ", "自重"], 
    //           value: _data.powerType, 
    //           onPressed: (value){
    //             setState(() {
    //               _data.powerType = value;

    //             });
    //           }
    //         ),
    //       },
    //     ],

    //     right: [
    //       if(!_data.isCalculation)...{
    //         // 解析開始ボタン
    //         MyIconButton(
    //           icon: Icons.play_arrow,
    //           message: "計算",
    //           onPressed: (){
    //             // if(_data.elemCount <= 1000){
    //             //   setState(() {
    //             //     _data.calculation();
    //             //   });
    //             // }else{
    //             //   snacbar();
    //             // }
    //             setState(() {
    //               _data.calculation();
    //             });
    //           },
    //         ),
    //       }else...{
    //         // 再開ボタン
    //         MyIconButton(
    //           icon: Icons.restart_alt,
    //           message: "再編集",
    //           onPressed: (){
    //             setState(() {
    //               _data.resetCalculation();
    //             });
    //           },
    //         ),
    //       }
    //     ],
    //   ),

    //   // メインビュー
    //   body: Stack(
    //     children:[
    //       if(_image != null)...{
    //         // painter(),
    //       },
    //     ]
    //   )
    // );
  }

  // // カスタムペインター
  // Widget painter(){
  //   return MyCustomPaint(
  //     backgroundColor: const Color.fromARGB(0, 0, 0, 0),
  //     onTap: (position) {
  //       if(_data.isCalculation){
  //         setState(() {
  //           _data.selectElem(_camera.screenToWorld(position),0);
  //           if(_data.selectedNumber >= 0){
  //             _data.selectedNumber = _data.selectedNumber;
  //           }
  //         });
  //       }
  //     },
  //     onDrag: (position) {
  //       if(!_data.isCalculation){
  //         _data.selectElem(_camera.screenToWorld(position),0);
  //         if(_data.selectedNumber >= 0){
  //           if(_data.getElem(_data.selectedNumber).isCanPaint){
  //             if(_toolNum == 0 && _data.getElem(_data.selectedNumber).e < 1){
  //               _data.getElem(_data.selectedNumber).e = 1;
  //             }
  //             else if(_toolNum == 1 && _data.getElem(_data.selectedNumber).e > 0){
  //               _data.getElem(_data.selectedNumber).e = 0;
  //             }
  //           }
  //         }
  //         setState(() {
  //         });
  //       }
  //     },
  //     painter: BridgegameFreePainter(data: _data, camera: _camera), 
  //   );
  // }

  // // メッセージ
  // void snacbar(){
  //   final snackBar = SnackBar(
  //     content: const Text('体積は1000以下にしよう'),
  //     action: SnackBarAction(
  //       label: '閉じる', 
  //       onPressed: () {  },
  //     ),
  //   );

  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  // Future<void> loadImage(String asset) async {
  //   final ImageStream stream = AssetImage(asset).resolve(
  //     const ImageConfiguration(), // devicePixelRatioの指定を削除
  //   );
  //   final Completer<ui.Image> completer = Completer();
  //   stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
  //     completer.complete(info.image);
  //   }));
  //   final ui.Image image = await completer.future;

  
  //   // デバッグ情報を出力
  //   setState(() {
  //     _image = image;
  //   });
  // }
}