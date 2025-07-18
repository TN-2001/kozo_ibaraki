import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/views/bridgegame/ui/bridgegame_tool_bar.dart';
import '../../../components/tool_ui/tool_bar_divider.dart';
import '../../../components/tool_ui/tool_dropdown_button.dart';
import '../../../components/tool_ui/tool_icon_button.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimens.dart';
import '../models/bridgegame_controller.dart';

class BridgegameUI extends StatefulWidget {
  const BridgegameUI({super.key, required this.controller, required this.scaffoldKey});

  final BridgegameController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<BridgegameUI> createState() => _BridgegameUIState();
}

class _BridgegameUIState extends State<BridgegameUI> {
  late GlobalKey<ScaffoldState> _scaffoldKey;
  int state = 0;
  int _powerIndex = 0;


  void _onPressedMenuButton() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onPressedPowerDropdown(int indent) {
    setState(() {
      _powerIndex = indent;
    });
    widget.controller.changePowerIndex(_powerIndex);
  }

  Future<void> _onPressedAnalysisButton() async{    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54, // 背景を暗く
      builder: (BuildContext context) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // インジケーターを白く
            ),
            SizedBox(height: 20), // インジケーターとテキストの間にスペースを追加
            Text("解析中", 
              style: TextStyle(
                color: Colors.white, // テキストを白く
                fontSize: 20,
              ),
            ),
          ]
        );
      },
    );

    // 3秒間の処理時間をシミュレート
    await widget.controller.calculation();

    // ダイアログを閉じる
    if (!mounted) return;
    Navigator.of(context).pop();
    
    if (widget.controller.isCalculation) {
      setState(() {
        state = 1;
      });
    }

    // 完了メッセージを表示
    // if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('処理が完了しました')),
    // );
  }

  void _onPressedEditButton() {
    setState(() {
      state = 0;
    });
    widget.controller.resetCalculation();
  }


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
    _scaffoldKey = widget.scaffoldKey;
  }

  @override
  Widget build(BuildContext context) {
    if (state == 0) {
      return Container(
        width: double.infinity,
        height: ToolBarDimens.height,
        color: BaseColors.baseColor,
        child: Row(
          children: [
            SizedBox(width: ToolUIDimens.gapWidth,),

            _menuButton(),

            SizedBox(width: ToolUIDimens.gapWidth,),
            const ToolBarDivider(isVertivcal: true,),

            BridgegameToolBar(controller: widget.controller),

            const ToolBarDivider(isVertivcal: true,),
            const Expanded(child: SizedBox()),
            const ToolBarDivider(isVertivcal: true,),
            SizedBox(width: ToolUIDimens.gapWidth,),

            ToolDropdownButton(
              selectedIndex: _powerIndex,
              onPressed: _onPressedPowerDropdown,
              items: const ["荷重1", "荷重2", "自重"], 
            ),

            SizedBox(width: ToolUIDimens.gapWidth,),
            const ToolBarDivider(isVertivcal: true,),
            SizedBox(width: ToolUIDimens.gapWidth,),

            ToolIconButton(
              onPressed: _onPressedAnalysisButton,
              icon: const Icon(Icons.play_arrow),
              message: "解析",
            ),

            SizedBox(width: ToolUIDimens.gapWidth,),
          ],
        ),
      );
    }
    else {
      return Container(
        width: double.infinity,
        color: BaseColors.baseColor,
        child: Row(
          children: [
            SizedBox(width: ToolUIDimens.gapWidth,),

            _menuButton(),

            SizedBox(width: ToolUIDimens.gapWidth,),
            const ToolBarDivider(isVertivcal: true,),
            const Expanded(child: SizedBox()),
            const ToolBarDivider(isVertivcal: true,),
            SizedBox(width: ToolUIDimens.gapWidth,),

            ToolIconButton(
              onPressed: _onPressedEditButton,
              icon: const Icon(Icons.restart_alt),
              message: "再編集",
            ),

            SizedBox(width: ToolUIDimens.gapWidth,),
          ],
        ),
      );
    }
  }
}