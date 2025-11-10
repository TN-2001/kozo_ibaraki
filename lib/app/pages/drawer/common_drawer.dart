import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/drawer/setting_page.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key, this.onPressedHelpButton, this.onChangeValue});

  final void Function()? onPressedHelpButton;
  final void Function()? onChangeValue;


  @override
  Widget build(BuildContext context) {
    return BaseDrawer(
      child: Column(
        children: [
          BaseRow(
            margin: BaseDimens.padding,
            children: [
              BaseIconButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                icon: const Icon(Icons.menu),
              ),
              const BaseText(
                "Kozo App", 
                margin: EdgeInsets.only(left: 16),
                fontSize: 20,
              ),
            ]
          ),
          
          Expanded(
            child: ListView(
              padding: BaseDimens.padding,
              children: [
                BaseOutlineButton(
                  label: const Text("ホーム"),
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
                    String targetRoute = '/';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                if (onPressedHelpButton != null)
                BaseOutlineButton(
                  label: const Text("ヘルプ"),
                  icon: const Icon(Icons.help),
                  onPressed: () {
                    Navigator.pop(context);
                    onPressedHelpButton!();
                  },
                ),

                Container(
                  height: BaseDimens.buttonHeight,
                  padding: BaseDimens.buttonTextPadding,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "アプリ",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                BaseOutlineButton(
                  label: const Text("はりの構造解析"),
                  onPressed: () {
                    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
                    String targetRoute = '/beam';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseOutlineButton(
                  label: const Text("トラスの構造解析"),
                  onPressed: () {
                    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
                    String targetRoute = '/truss';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseOutlineButton(
                  label: const Text("ラーメンの構造解析"),
                  onPressed: () {
                    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
                    String targetRoute = '/frame';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseOutlineButton(
                  label: const Text("有限要素解析"),
                  onPressed: () {
                    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
                    String targetRoute = '/fem';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseOutlineButton(
                  label: const Text("橋づくりゲーム"),
                  onPressed: () {
                    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
                    String targetRoute = '/bridgegame';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),
              ],
            ),
          ),

          const BaseDivider(),

          BaseOutlineButton(
            margin: BaseDimens.padding,
            label: const Text("設定"),
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return SettingPage(onChangeValue: onChangeValue,);
                },
              );
            },
          ),
        ]
      ),
    );
  }
}