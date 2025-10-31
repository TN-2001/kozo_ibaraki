import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({
    super.key, 
    required this.children, 
    this.color = MyColors.toolBarBackground,
  });

  final List<Widget> children;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MyDimens.toolBarHeight,
      color: color,
      child: Row(
        children: [
          const SizedBox(width: MyDimens.toolBarSpacing,),
          
          for(int i = 0; i < children.length; i++)...{
            children[i],
          },

          const SizedBox(width: MyDimens.toolBarSpacing,),
        ],
      )
    );
  }
}