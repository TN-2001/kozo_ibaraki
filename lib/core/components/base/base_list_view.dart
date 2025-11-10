import 'package:flutter/material.dart';

class BaseListView extends StatelessWidget {
  const BaseListView({
    super.key,
    required this.children,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final EdgeInsets margin;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ListView(
        padding: padding,
        children: children,
      ),
    );
  }
}