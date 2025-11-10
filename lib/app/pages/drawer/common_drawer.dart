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
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

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
              padding: const EdgeInsets.all(BaseDimens.spacing),
              children: [                
                BaseListTile(
                  title: const Text("ホーム"),
                  leading: const Icon(Icons.home),
                  selected: currentRoute == '/',
                  onTap: () {
                    String targetRoute = '/';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                if (onPressedHelpButton != null)
                BaseListTile(
                  title: const Text("ヘルプ"),
                  leading: const Icon(Icons.help),
                  onTap: () {
                    Navigator.pop(context);
                    onPressedHelpButton!();
                  },
                ),

                BaseListTile(
                  title: const Text("アプリ"),
                  enabled: false,
                ),

                BaseListTile(
                  title: const Text("はりの構造解析"),
                  selected: currentRoute == '/beam',
                  onTap: () {
                    String targetRoute = '/beam';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseListTile(
                  title: const Text("トラスの構造解析"),
                  selected: currentRoute == '/truss',
                  onTap: () {
                    String targetRoute = '/truss';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseListTile(
                  title: const Text("ラーメンの構造解析"),
                  selected: currentRoute == '/frame',
                  onTap: () {
                    String targetRoute = '/frame';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseListTile(
                  title: const Text("有限要素解析"),
                  selected: currentRoute == '/fem',
                  onTap: () {
                    String targetRoute = '/fem';

                    Navigator.pop(context);
                    if (currentRoute != targetRoute) {
                      Navigator.pushNamed(context, targetRoute);
                    }
                  },
                ),

                BaseListTile(
                  title: const Text("橋づくりゲーム"),
                  selected: currentRoute == '/bridgegame',
                  onTap: () {
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

          BaseListTile(
            margin: const EdgeInsets.all(BaseDimens.spacing),
            title: const Text("設定"),
            leading: const Icon(Icons.settings),
            onTap: () {
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