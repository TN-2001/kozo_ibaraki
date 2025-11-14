import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/drawer/common_drawer.dart';
import 'package:kozo_ibaraki/app/pages/fem/canvas/fem_canvas.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_controller.dart';
import 'package:kozo_ibaraki/app/pages/fem/ui/fem_bar.dart';
import 'package:kozo_ibaraki/app/pages/fem/ui/fem_canvas_ui.dart';
import 'package:kozo_ibaraki/app/pages/fem/ui/fem_setting_window.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/services/analytics_services.dart';
import 'package:kozo_ibaraki/core/utils/status_bar.dart';

class FemPage extends StatefulWidget {
  const FemPage({super.key});

  @override
  State<FemPage> createState() => _FemPageState();
}

class _FemPageState extends State<FemPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // メニュー用キー
  late FemController _controller;
  bool isSumaho = false;

  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = FemController();
    _controller.addListener(_onUpdate);

    StatusBar.setStyle(isDarkBackground: true);
    AnalyticsServices().logPageView("fem");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    StatusBar.setModeByOrientation(context);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size; // 画面サイズ取得
    if (size.height > size.width && isSumaho == false) {
      setState(() {
        isSumaho = true;
      });
    } else if (size.height < size.width && isSumaho == true) {
      setState(() {
        isSumaho = false;
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      drawer: CommonDrawer(
        onChangeValue: _onUpdate,
      ),
      body: SafeArea(
        child: ClipRect(
          child: Column(children: [
            FemBar(controller: _controller, scaffoldKey: _scaffoldKey),
            const BaseDivider(),
            Expanded(
              child: Stack(children: [
                FemCanvas(controller: _controller),
                FemCanvasUi(controller: _controller),
                FemSettingWindow(controller: _controller),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
