import 'package:flutter/material.dart';
import '../models/bridgegame_controller.dart';

class BridgegameCanvasUi extends StatefulWidget {
  const BridgegameCanvasUi({super.key, required this.controller});

  final BridgegameController controller;

  @override
  State<BridgegameCanvasUi> createState() => _BridgegameCanvasUiState();
}

class _BridgegameCanvasUiState extends State<BridgegameCanvasUi> {
  late BridgegameController _controller;


  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Text(
          "体積：${_controller.onElemListLength}",
          style: const TextStyle(
            fontSize: 16, 
          ),
        ),
      ),
    );
  }
}