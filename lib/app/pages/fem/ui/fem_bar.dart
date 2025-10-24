import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_controller.dart';
import 'package:kozo_ibaraki/core/components/component.dart';

class FemBar extends StatefulWidget {
  const FemBar({super.key, required this.controller, required this.scaffoldKey});

  final FemController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<FemBar> createState() => _FemBarState();
}

class _FemBarState extends State<FemBar> {
  late FemController _controller;
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
    // String errorMessage = _controller.checkCalculation();
    // if (errorMessage.isNotEmpty) {
    //   // エラーメッセージを表示
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(errorMessage)),
    //   );
    //   return;
    // }

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

  Widget _displayButton() {
    return MenuAnchor(
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return ToolTextButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          text: "表示",
          iconData: Icons.arrow_drop_down,
        );
      },
      menuChildren: [
        ToolCheckboxMenuButton(
          value: _controller.getIsDisplay(0), 
          onChanged: (value) {
            setState(() {
              _controller.setIsDisplay(0, value);
            });
          }, 
          text: "節点番号"
        ),
        ToolCheckboxMenuButton(
          value: _controller.getIsDisplay(1), 
          onChanged: (value) {
            setState(() {
              _controller.setIsDisplay(1, value);
            });
          },  
          text: "要素番号",
        ),
        ToolCheckboxMenuButton(
          value: _controller.getIsDisplay(2), 
          onChanged: (value) {
            setState(() {
              _controller.setIsDisplay(2, value);
            });
          },  
          text: "結果の値",
        ),
      ],
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
    if (!_controller.isCalculated) {
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
              Icon(Icons.texture),
            ], 
            messages: const ["節点", "要素", "Z方向"],
          ),

          if (_selectedTypeIndex == 0 || _selectedTypeIndex == 1)...{
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
          },

          const ToolBarDivider(isVertivcal: true,),
          const Expanded(child: SizedBox()),
          const ToolBarDivider(isVertivcal: true,),

          _displayButton(),

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

          _displayButton(),

          const ToolBarDivider(isVertivcal: true,),

          ToolDropdownButton(
            selectedIndex: _selectedResultIndex, 
            onPressed: _onPressedResultDropdown, 
            items: const [
              "X方向応力", "Y方向応力", "せん断応力", "Z方向応力", "最大主応力", "最小主応力", "von-Miss相当応力",
              "X方向ひずみ", "Y方向ひずみ", "工学せん断ひずみ", "Z方向ひずみ"],
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