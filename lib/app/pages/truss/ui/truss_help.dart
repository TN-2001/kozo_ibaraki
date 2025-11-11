import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class TrussHelp extends StatefulWidget {
  const TrussHelp({super.key});

  @override
  State<TrussHelp> createState() => _TrussHelpState();
}

class _TrussHelpState extends State<TrussHelp> {
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
                margin: const EdgeInsets.only(left: BaseDimens.spacing),
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

          const BaseDivider(margin: EdgeInsets.symmetric(horizontal: BaseDimens.spacing),),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(BaseDimens.spacing),
              alignment: Alignment.center,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    final url = Uri.parse('https://youtu.be/heslu9QKW1E');
                    launchUrl(url);
                  },
                  child: Image.asset(
                    "assets/images/youtube/2.jpg",
                  )
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}