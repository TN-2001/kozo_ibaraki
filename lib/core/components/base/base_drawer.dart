import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BaseDrawer extends StatelessWidget {
  const BaseDrawer({
    super.key, 
    required this.child,
    this.backgroundColor = BaseColors.drawerBackground
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: backgroundColor,
        // ウィジェットの形
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        
        // 要素
        child: child,
      ),
    );
  }
}