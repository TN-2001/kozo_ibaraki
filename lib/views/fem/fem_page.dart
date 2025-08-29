import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/views/common/common_drawer.dart';
import '../../components/component.dart';
import '../../utils/status_bar.dart';
import 'canvas/fem_canvas.dart';
import 'models/fem_data.dart';
import 'ui/fem_bar.dart';
import 'ui/fem_setting_window.dart';

class FemPage extends StatefulWidget {
  const FemPage({super.key});

  @override
  State<FemPage> createState() => _FemPageState();
}

class _FemPageState extends State<FemPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // メニュー用キー
  late FemData _controller;
  bool isSumaho = false;



  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }


  @override
  void initState() {
    super.initState();

    _controller = FemData();
    _controller.node = Node();
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
              FemBar(controller: _controller, scaffoldKey: _scaffoldKey),

              const BaseDivider(),

              Expanded(
                child: Stack(
                  children: [
                    FemCanvas(controller: _controller),

                    // TrussCanvasUi(controller: _controller),

                    FemSettingWindow(controller: _controller),
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