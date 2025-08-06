import 'package:flutter/material.dart';
import '../../components/component.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key, required this.onPressedHelpButton});

  final void Function() onPressedHelpButton;

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
          title: const Text("はりの構造解析"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/';

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

        const BaseDivider(),

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

        ListTile(
          title: const Text("橋づくりゲーム（難しい）"),
          onTap: () {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
            String targetRoute = '/bridgegamefree';

            Navigator.pop(context);
            if (currentRoute != targetRoute) {
              Navigator.pushNamed(context, targetRoute);
            }
          },
        ),

        const BaseDivider(),

        ListTile(
          title: const Text("ヘルプ"),
          onTap: () {
            Navigator.pop(context);
            onPressedHelpButton();
          },
        ),
      ]
    );
  }
}