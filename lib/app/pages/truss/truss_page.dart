import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/drawer/common_drawer.dart';
import 'package:kozo_ibaraki/app/pages/truss/canvas/truss_canvas.dart';
import 'package:kozo_ibaraki/app/pages/truss/models/truss_data.dart';
import 'package:kozo_ibaraki/app/pages/truss/ui/truss_bar.dart';
import 'package:kozo_ibaraki/app/pages/truss/ui/truss_canvas_ui.dart';
import 'package:kozo_ibaraki/app/pages/truss/ui/truss_help.dart';
import 'package:kozo_ibaraki/app/pages/truss/ui/truss_setting_window.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/utils/status_bar.dart';


class TrussPage extends StatefulWidget {
  const TrussPage({super.key});

  @override
  State<TrussPage> createState() => _TrussPageState();
}

class _TrussPageState extends State<TrussPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // メニュー用キー
  late TrussData _controller; // データ
  bool isSumaho = false;


  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }


  @override
  void initState() {
    super.initState();

    _controller = TrussData();
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
          showDialog(
            context: context,
            builder: (context) {
              return const TrussHelp();
            },
          );
        },

        onChangeValue: _onUpdate,
      ),


      body: SafeArea(
        child: ClipRect(
          child: Column(
            children: [
              TrussBar(controller: _controller, scaffoldKey: _scaffoldKey,),

              const BaseDivider(),

              Expanded(
                child: Stack(
                  children: [
                    TrussCanvas(controller: _controller),

                    TrussCanvasUi(controller: _controller),

                    TrussSettingWindow(controller: _controller),
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

