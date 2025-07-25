import 'package:flutter/material.dart';
import '../../../components/tool_ui/tool_bar.dart';
import '../../../components/tool_ui/tool_bar_divider.dart';
import '../../../components/tool_ui/tool_dropdown_button.dart';
import '../../../components/tool_ui/tool_icon_button.dart';
import '../../../components/tool_ui/tool_toggle_buttons.dart';
import '../models/beam_data.dart';

class BeamBar extends StatefulWidget {
  const BeamBar({super.key, required this.controller, required this.scaffoldKey});

  final BeamData controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<BeamBar> createState() => _BeamBarState();
}

class _BeamBarState extends State<BeamBar> {
  late BeamData _controller;
  late GlobalKey<ScaffoldState> _scaffoldKey;

  int _selectedTypeIndex = 0; // 選択されているツールのインデックス（0:節点、1:要素）
  int _selectedToolIndex = 0; // 選択されているツールのインデックス（0:新規、1:修正）
  int _selectedResultIndex = 0; // 選択されている結果のインデックス（0:変形図、1:反力、2:せん断力図、3:曲げモーメント図） 


  void _onPressedMenuButton() {
    _scaffoldKey.currentState!.openDrawer();
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
    if (_controller.getState == BeamState.editor || 
        _controller.getState == BeamState.calculation) {
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
            items: const ["変形図", "反力", "せん断力図","曲げモーメント図",],
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