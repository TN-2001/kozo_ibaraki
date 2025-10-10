import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class HomeAppList extends StatefulWidget {
  const HomeAppList({super.key});

  @override
  State<HomeAppList> createState() => _HomeAppListState();
}

class _HomeAppListState extends State<HomeAppList> {
  
  Widget titleText(String text) {
    return Text(
      text, 
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget button(String label, String targetRoute) {
    return TextButton(
      onPressed: () {
        String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

        Navigator.pop(context);
        if (currentRoute != targetRoute) {
          Navigator.pushNamed(context, targetRoute);
        }
      },
      style: TextButton.styleFrom(
        side: const BorderSide(color: MyColors.baseBorder),
        backgroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buttonGrid(List<Widget> children) {
    const double itemHeight = 50;
    const double itemSpacing = 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double width = constraints.maxWidth;

        if (width > 900) {
          crossAxisCount = 4;
        } else if (width > 600) {
          crossAxisCount = 3;
        }

        // ボタンの高さを固定するために、childAspectRatio を計算
        // 幅 / 高さ = childAspectRatio
        double itemWidth = width / crossAxisCount - itemSpacing * (crossAxisCount - 1) / crossAxisCount;
        double aspectRatio = itemWidth / itemHeight;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: itemSpacing,
          mainAxisSpacing: itemSpacing,
          childAspectRatio: aspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText("構造解析アプリ"),
        const SizedBox(height: 10),

        buttonGrid([
          button("はり", "/beam"),
          button("トラス", "/truss"),
          button("ラーメン", "/frame"),
          // button("有限要素解析", "/fem"),
        ]),

        const SizedBox(height: 30),

        titleText("ゲームアプリ"),
        const SizedBox(height: 10),

        buttonGrid([
          button("橋づくりゲーム", "/bridgegame"),
        ]),
      ],
    );
  }
}