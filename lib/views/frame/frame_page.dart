import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/views/frame/models/frame_controller.dart';

import '../../components/component.dart';
import '../../utils/status_bar.dart';
import '../common/common_drawer.dart';
import 'canvas/frame_canvas.dart';
import 'ui/frame_bar.dart';
import 'ui/frame_canvas_ui.dart';
import 'ui/frame_setting_window.dart';


class FramePage extends StatefulWidget {
  const FramePage({super.key});

  @override
  State<FramePage> createState() => _FramePageState();
}

class _FramePageState extends State<FramePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // メニュー用キー
  late FrameController _controller; // データ
  bool isSumaho = false;


  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }


  @override
  void initState() {
    super.initState();

    _controller = FrameController();
    _controller.addListener(_onUpdate);

    StatusBar.setStyle(isDarkBackground: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    StatusBar.setModeByOrientation(context);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size; // 画面サイズ取得
    if(size.height > size.width && isSumaho == false) {
      setState(() {
        isSumaho = true;
      });
    }else if (size.height < size.width && isSumaho == true) {
      setState(() {
        isSumaho = false;
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,

      drawer: CommonDrawer(
        onPressedHelpButton: () {
          
        },
      ),


      body: SafeArea(
        child: ClipRect(
          child: Column(
            children: [
              FrameBar(controller: _controller, scaffoldKey: _scaffoldKey,),

              const BaseDivider(),

              Expanded(
                child: Stack(
                  children: [
                    FrameCanvas(controller: _controller),

                    FrameCanvasUi(controller: _controller),

                    FrameSettingWindow(controller: _controller),
                  ]
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}