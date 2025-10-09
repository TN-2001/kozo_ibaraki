import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/components/tool/tool_bar.dart';

class HomeBar extends StatefulWidget {
  const HomeBar({super.key});

  @override
  State<HomeBar> createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> {
  @override
  Widget build(BuildContext context) {
    return const ToolBar(
      children: [
        Expanded(
          child: Center(
            child: Text(
              "Kozo App : 茨城大学 車谷研究室",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]
    );
  }
}