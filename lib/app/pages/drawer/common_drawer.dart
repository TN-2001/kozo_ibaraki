import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/drawer/setting_page.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';
import 'package:kozo_ibaraki/core/services/navigator_services.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key, this.onPressedHelpButton, this.onChangeValue});

  final void Function()? onPressedHelpButton;
  final void Function()? onChangeValue;

  @override
  Widget build(BuildContext context) {
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return BaseDrawer(
      child: Column(children: [
        BaseRow(margin: BaseDimens.padding, children: [
          BaseIconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.menu),
          ),
          BaseText.title(
            "Kozo App",
            margin: BaseDimens.contentPadding,
          ),
        ]),
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
                  NavigatorServices.handleNavigation(context, targetRoute);
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
                onTap: () async {
                  String targetRoute = '/beam';
                  NavigatorServices.handleNavigation(context, targetRoute);
                },
              ),
              BaseListTile(
                title: const Text("トラスの構造解析"),
                selected: currentRoute == '/truss',
                onTap: () async {
                  String targetRoute = '/truss';
                  NavigatorServices.handleNavigation(context, targetRoute);
                },
              ),
              BaseListTile(
                title: const Text("ラーメンの構造解析"),
                selected: currentRoute == '/frame',
                onTap: () async {
                  String targetRoute = '/frame';

                  NavigatorServices.handleNavigation(context, targetRoute);
                },
              ),
              BaseListTile(
                title: const Text("有限要素解析"),
                selected: currentRoute == '/fem',
                onTap: () async {
                  String targetRoute = '/fem';

                  NavigatorServices.handleNavigation(context, targetRoute);
                },
              ),
              BaseListTile(
                title: const Text("橋づくりゲーム"),
                selected: currentRoute == '/bridgegame',
                onTap: () async {
                  String targetRoute = '/bridgegame';

                  NavigatorServices.handleNavigation(context, targetRoute);
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
                return SettingPage(
                  onChangeValue: onChangeValue,
                );
              },
            );
          },
        ),
      ]),
    );
  }
}
