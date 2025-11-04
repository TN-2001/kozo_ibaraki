import 'package:flutter/material.dart';

class BaseRow extends StatelessWidget {
  const BaseRow({
    super.key,
    required this.children,
    this.margin = EdgeInsets.zero,
  });

  final List<Widget> children;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: children,
      ),
    );
  }
}