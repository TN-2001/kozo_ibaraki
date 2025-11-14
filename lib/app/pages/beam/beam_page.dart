import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/beam/ui/beam_help.dart';
import 'package:kozo_ibaraki/app/pages/drawer/common_drawer.dart';
import 'package:kozo_ibaraki/app/pages/beam/canvas/beam_canvas.dart';
import 'package:kozo_ibaraki/app/pages/beam/models/beam_data.dart';
import 'package:kozo_ibaraki/app/pages/beam/ui/beam_bar.dart';
import 'package:kozo_ibaraki/app/pages/beam/ui/beam_canvas_ui.dart';
import 'package:kozo_ibaraki/app/pages/beam/ui/beam_setting_window.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/services/analytics_services.dart';
import 'package:kozo_ibaraki/core/utils/status_bar.dart';

class BeamPage extends StatefulWidget {
  const BeamPage({super.key});

  @override
  State<BeamPage> createState() => _BeamPageState();
}

class _BeamPageState extends State<BeamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BeamData controller;
  bool isSumaho = false;
  Elem currentElem = Elem();

  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }

  @override
  void initState() {
    super.initState();

    controller = BeamData(
      onDebug: (value) {},
    );
    controller.node = Node();
    controller.addListener(_onUpdate);

    StatusBar.setStyle(isDarkBackground: true);
    AnalyticsServices().logPageView("beam");
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
        if (controller.resultIndex > 1) {
          controller.changeResultIndex(0);
        }
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
        onPressedHelpButton: () {
          showDialog(
            context: context,
            builder: (context) {
              return const BeamHelp();
            },
          );
        },
        onChangeValue: _onUpdate,
      ),
      body: SafeArea(
        child: ClipRect(
          child: Column(
            children: [
              BeamBar(controller: controller, scaffoldKey: _scaffoldKey),
              const BaseDivider(),
              Expanded(
                child: Stack(children: [
                  BeamCanvas(
                      controller: controller,
                      devTypeNum: controller.resultIndex,
                      isSumaho: isSumaho),
                  const BeamCanvasUi(),
                  BeamSettingWindow(controller: controller),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
