import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/home/ui/home_app_list.dart';
import 'package:kozo_ibaraki/app/pages/home/ui/home_bar.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/services/analytics_services.dart';
import 'package:kozo_ibaraki/core/utils/status_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSumaho = false;

  @override
  void initState() {
    super.initState();

    StatusBar.setStyle(isDarkBackground: true);
    AnalyticsServices().logPageView("home");
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

    double width = size.width;
    if (width > 1000) {
      width = 1000;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      body: SafeArea(
          child: ClipRect(
              child: Column(children: [
        const HomeBar(),
        const BaseDivider(),
        Expanded(
          child: Container(
            color: const Color.fromARGB(255, 250, 250, 250),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Container(
                width: width,
                height: double.infinity,
                padding: const EdgeInsets.all(20),
                child: const HomeAppList(),
              ),
            ),
          ),
        ),
      ]))),
    );
  }
}
