import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import '../base/base_divider.dart';

class ToolBarDivider extends StatelessWidget {
  const ToolBarDivider({
    super.key, 
    this.isVertivcal = false,
  });

  final bool isVertivcal;

  @override
  Widget build(BuildContext context) {
    return BaseDivider(
      color: ToolColors.divider,
      width: ToolDimens.dividerWidth,
      margin: ToolDimens.dividerMargin,
      isVertivcal: isVertivcal,
    );
  }
}