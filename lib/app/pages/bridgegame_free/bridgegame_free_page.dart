import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/canvas/bridgegame_canvas.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/ui/bridgegame_bar.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/ui/bridgegame_canvas_ui.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/ui/bridgegame_help.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame_free/models/bridgegame_free_controller.dart';
import 'package:kozo_ibaraki/app/pages/drawer/common_drawer.dart';
import 'package:kozo_ibaraki/core/components/base/base_divider.dart';
import 'package:kozo_ibaraki/core/services/analytics_services.dart';
import 'package:kozo_ibaraki/core/utils/status_bar.dart';

class BridgegameFreePage extends StatefulWidget {
  const BridgegameFreePage({super.key});

  @override
  State<BridgegameFreePage> createState() => _BridgegameFreePageState();
}

class _BridgegameFreePageState extends State<BridgegameFreePage> {
  late BridgegameFreeController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();

    controller = BridgegameFreeController();
    controller.addListener(_update);

    StatusBar.setStyle(isDarkBackground: true);
    AnalyticsServices().logPageView("bridgegame");
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
