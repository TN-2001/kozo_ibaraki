import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/components/component.dart';

class PrivacyBar extends StatefulWidget {
  const PrivacyBar({super.key, required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<PrivacyBar> createState() => _PrivacyBarState();
}

class _PrivacyBarState extends State<PrivacyBar> {
  late GlobalKey<ScaffoldState> _scaffoldKey;


  void _onPressedMenuButton() {
    _scaffoldKey.currentState!.openDrawer();
  }


  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey;
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      children: [
        ToolIconButton(
          onPressed: _onPressedMenuButton, 
          icon: const Icon(Icons.menu),
          message: "メニュー",
        ),

        const ToolBarDivider(isVertivcal: true,),
      ],
    );
  }
}