import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_data.dart';
import 'package:kozo_ibaraki/core/components/component.dart';

class FemBar extends StatefulWidget {
  const FemBar({super.key, required this.controller, required this.scaffoldKey});

  final FemData controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<FemBar> createState() => _FemBarState();
}

class _FemBarState extends State<FemBar> {
  late FemData _controller;
  late GlobalKey<ScaffoldState> _scaffoldKey;

  int _selectedTypeIndex = 0; // 選択されているツールのインデックス（0:節点、1:要素）
  int _selectedToolIndex = 0; // 選択されているツールのインデックス（0:新規、1:修正）
  int _selectedResultIndex = 0; // 選択されている結果のインデックス（0:変形図、1:反力、2:せん断力図、3:曲げモーメント図） 


  void _onPressedMenuButton() {
    _scaffoldKey.currentState!.openDrawer();
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       backgroundColor: MyColors.baseBackground,
    //       title: const Text("使い方（動画リンク）"),
    //       content: SizedBox(
    //         width: MediaQuery.sizeOf(context).width / 1.5,
    //         height: MediaQuery.sizeOf(context).width / 1.5 /16*9,
    //         child: MouseRegion(
    //           cursor: SystemMouseCursors.click,
    //           child: GestureDetector(
    //             onTap: (){
    //               final url = Uri.parse('https://youtu.be/44JrBWd-lS4');
    //               launchUrl(url);
    //             },
    //             child: Image.asset(
    //               "assets/images/youtube/1.jpg",
    //             )
    //           ),
    //         ),
    //       ),
    //       actions: [
    //         TextButton(
    //           child: const Text("閉じる"),
    //           onPressed: () => Navigator.pop(context),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void _onPressedTypeToggle(int index) {
    setState(() {
      _selectedTypeIndex = index;
    });
    _controller.changeTypeIndex(_selectedTypeIndex);
  }

  void _onPressedToolToggle(int index) {
    setState(() {
      _selectedToolIndex = index;
    });
    _controller.changeToolIndex(_selectedToolIndex);
  }

  Future<void> _onPressedAnalysisButton() async {
    String errorMessage = _controller.checkCalculation();
    if (errorMessage.isNotEmpty) {
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // 解析を実行
    setState(() {
      _controller.calculation();
    });
  }

  void _onPressedResultDropdown(int index) {
    setState(() {
      _selectedResultIndex = index;
    });
    _controller.changeResultIndex(_selectedResultIndex);
  }

  void _onPressedEditButton() {
    setState(() {
      _controller.resetCalculation();
    });
  }


  // メニューボタンのウィジェット
  Widget _menuButton() {
    return ToolIconButton(
      onPressed: _onPressedMenuButton, 
      icon: const Icon(Icons.menu),
      message: "メニュー",
    );
  }


  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _scaffoldKey = widget.scaffoldKey;
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isCalculation) {
      // 編集モードのUIを表示
      return ToolBar(
        children: [
          _menuButton(),
          
          const ToolBarDivider(isVertivcal: true,),

          ToolToggleButtons(
            selectedIndex: _selectedTypeIndex,
            onPressed: _onPressedTypeToggle,
            icons: const [
              Icon(Icons.circle),
              Icon(Icons.square),
            ], 
            messages: const ["節点", "要素"],
          ),

          const ToolBarDivider(isVertivcal: true,),

          ToolToggleButtons(
            selectedIndex: _selectedToolIndex,
            onPressed: _onPressedToolToggle,
            icons: const [
              Icon(Icons.add),
              Icon(Icons.touch_app),
            ], 
            messages: const ["新規","修正"],
          ),

          const ToolBarDivider(isVertivcal: true,),
          const Expanded(child: SizedBox()),
          const ToolBarDivider(isVertivcal: true,),

          ToolIconButton(
            onPressed: _onPressedAnalysisButton,
            icon: const Icon(Icons.play_arrow),
            message: "解析",
          ), 
        ],
      );
    } 
    else {
      // 解析モードのUIを表示
      return ToolBar(
        children: [
          _menuButton(),
           
          const ToolBarDivider(isVertivcal: true,),
          const Expanded(child: SizedBox()),
          const ToolBarDivider(isVertivcal: true,),

          ToolDropdownButton(
            selectedIndex: _selectedResultIndex, 
            onPressed: _onPressedResultDropdown, 
            items: const ["軸力", "応力", "ひずみ", "変位", "反力"],
          ),

          const ToolBarDivider(isVertivcal: true,),

          ToolIconButton(
            onPressed: _onPressedEditButton,
            icon: const Icon(Icons.restart_alt),
            message: "再編集",
          ),
        ],
      );
    } 
  }
}