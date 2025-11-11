import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class BridgegameHelp extends StatefulWidget {
  const BridgegameHelp({super.key});

  @override
  State<BridgegameHelp> createState() => _BridgegameHelpState();
}

class _BridgegameHelpState extends State<BridgegameHelp> {
  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      child: Column(
        children: [
          BaseRow(
            padding: const EdgeInsets.all(BaseDimens.spacing),
            children: [
              BaseText.title(
                "使い方",
                margin: const EdgeInsets.only(left: BaseDimens.contentSpacing),
              ),

              const Expanded(child: SizedBox()),

              BaseIconButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                icon: const Icon(Icons.close),
                tooltip: "閉じる",
              ),
            ],
          ),

          const BaseDivider(margin: EdgeInsets.symmetric(horizontal: BaseDimens.spacing + BaseDimens.contentSpacing),),

          Expanded(
            child: BaseListView(
              margin: const EdgeInsets.symmetric(vertical: BaseDimens.spacing),
              padding: const EdgeInsets.symmetric(horizontal: BaseDimens.spacing + BaseDimens.contentSpacing),
              children: [
                Image.asset("assets/images/help/help_01.png"),
                const SizedBox(height: BaseDimens.spacing),
                Image.asset("assets/images/help/help_02.png"),
              ],
            ),
          ),
          
        ]
      ),
    );
  }
}