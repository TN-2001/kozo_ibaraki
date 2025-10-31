import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/drawer/setting_page.dart';
import 'package:kozo_ibaraki/core/components/component.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key, this.onPressedHelpButton, this.onChangeValue});

  final void Function()? onPressedHelpButton;
  final void Function()? onChangeValue;


  @override
  Widget build(BuildContext context) {
    return BaseDrawer(
      children: [
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: const Text("Kozo App", style: TextStyle(fontSize: 20),),
          ),
        ),
        
        const BaseDivider(),

        ListTile(
          title: const Text("ホーム"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/';

            Navigator.pop(context);
            if (currentRoute != targetRoute) {
              Navigator.pushNamed(context, targetRoute);
            }
          },
        ),

        if (onPressedHelpButton != null)
        ListTile(
          title: const Text("ヘルプ"),
          onTap: () {
            Navigator.pop(context);
            onPressedHelpButton!();
          },
        ),

        const BaseDivider(),

        ListTile(
          title: const Text("はりの構造解析"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/beam';

            Navigator.pop(context);
            if (currentRoute != targetRoute) {
              Navigator.pushNamed(context, targetRoute);
            }
          },
        ),

        ListTile(
          title: const Text("トラスの構造解析"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/truss';

            Navigator.pop(context);
            if (currentRoute != targetRoute) {
              Navigator.pushNamed(context, targetRoute);
            }
          },
        ),

        ListTile(
          title: const Text("ラーメンの構造解析"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/frame';

            Navigator.pop(context);
            if (currentRoute != targetRoute) {
              Navigator.pushNamed(context, targetRoute);
            }
          },
        ),

        ListTile(
          title: const Text("有限要素解析"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/fem';

            Navigator.pop(context);
            if (currentRoute != targetRoute) {
              Navigator.pushNamed(context, targetRoute);
            }
          },
        ),

        ListTile(
          title: const Text("橋づくりゲーム"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/bridgegame';

            Navigator.pop(context);
            if (currentRoute != targetRoute) {
              Navigator.pushNamed(context, targetRoute);
            }
          },
        ),
        
        const BaseDivider(),

        ListTile(
          title: const Text("設定"),
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
    );
  }
}