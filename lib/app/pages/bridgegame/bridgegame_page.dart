import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/ui/bridgegame_help.dart';
import 'package:kozo_ibaraki/app/pages/drawer/common_drawer.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/canvas/bridgegame_canvas.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/models/bridgegame_controller.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/ui/bridgegame_bar.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/ui/bridgegame_canvas_ui.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/services/analytics_services.dart';
import 'package:kozo_ibaraki/core/utils/status_bar.dart';

class BridgegamePage extends StatefulWidget {
  const BridgegamePage({super.key});

  @override
  State<BridgegamePage> createState() => _BridgegamePageState();
}

class _BridgegamePageState extends State<BridgegamePage> {
  late BridgegameController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();

    controller = BridgegameController();
    controller.addListener(_update);

    StatusBar.setStyle(isDarkBackground: true);
    AnalyticsServices().logPageView("bridgegame");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    StatusBar.setModeByOrientation(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      drawer: CommonDrawer(
        onPressedHelpButton: () {
          showDialog(
            context: context,
            builder: (context) {
              return const BridgegameHelp();
            },
          );
        },
      ),
      body: SafeArea(
        child: ClipRect(
          child: Column(
            children: [
              BridgegameBar(
                controller: controller,
                scaffoldKey: _scaffoldKey,
              ),
              const BaseDivider(),
              Expanded(
                child: Stack(
                  children: [
                    BridgegameCanvas(
                      controller: controller,
                    ),
                    BridgegameCanvasUi(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
