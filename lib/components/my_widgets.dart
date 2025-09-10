import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/components/my_decorations.dart';

class MyAlign extends StatelessWidget {
  const MyAlign({
    super.key, 
    this.alignment = Alignment.center, 
    this.child = const SizedBox(), 
    this.isIntrinsicHeight = false, this.isIntrinsicWidth = false
  });

  final Alignment alignment;
  final Widget child;
  final bool isIntrinsicHeight, isIntrinsicWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Stack(
        children: [
          if(isIntrinsicHeight && isIntrinsicWidth)...{
            heightwidth(),
          }else if(isIntrinsicHeight)...{
            heigh(),
          }else if(isIntrinsicWidth)...{
            width(),
          }else...{
            child,
          }
        ],
      ),
    );
  }

  Widget heightwidth(){
    return IntrinsicHeight(
      child: IntrinsicWidth(
        child: child,
      ),
    );
  }

  Widget heigh(){
    return IntrinsicHeight(
      child: child,
    );
  }

  Widget width(){
    return IntrinsicWidth(
      child: child,
    );
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, this.header, this.body, this.drawer, this.scaffoldKey});

  final Widget? header;
  final Widget? body;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey; // Drawer表示用のキー

  @override
  Widget build(BuildContext context) {
    Widget bo(){
      return SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              if(header != null)...{
                header!,
                const Divider(height: 1, color: MyColors.border,),
              },
              Expanded(
                child: body ?? const SizedBox(),
              )
            ],
          ),
        )
      );
    }

    if(drawer != null){
      return Scaffold(
        key: scaffoldKey,

        backgroundColor: const Color.fromARGB(255, 0, 0, 0),

        drawer: SafeArea(child: drawer!),

        body: bo(),
      );
    }else{
      return Scaffold(
        key: scaffoldKey,

        backgroundColor: const Color.fromARGB(255, 0, 0, 0),

        body: bo(),
      );
    }
  }
}

class MyHeader extends StatelessWidget {
  const MyHeader({super.key, this.center, this.left, this.right, 
    this.isBorder = false});

  final List<Widget>? center;
  final List<Widget>? left;
  final List<Widget>? right;
  final bool isBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MySize.headerHeight,
      width: double.infinity,
      color: Colors.white,
      // 要素
      child: Row(
        children: [
          const SizedBox(width: 5,),

          if(left != null)...{
            for(int i = 0; i < left!.length; i++)...{
              // 要素
              left![i],
              // 要素間のライン
              Container(
                margin: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                child: isBorder ? const VerticalDivider(width: 1, color: MyColors.border,) : null,
              ),
            },
          },
          
          const Expanded(child: SizedBox(),),
          if(center != null)...{
            for(int i = 0; i < center!.length; i++)...{
              // 要素
              center![i],
              // 要素間のライン
              if(i < center!.length-1)...{
                Container(
                  margin: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  child: isBorder ? const VerticalDivider(width: 1, color: MyColors.border,) : null,
                ),
              },
            },
          },
          const Expanded(child: SizedBox(),),

          if(right != null)...{
            Align(
              alignment: Alignment.centerRight,
              child: Row(children: [
                for(int i = 0; i < right!.length; i++)...{
                  // 要素間のライン
                  Container(
                    margin: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    child: isBorder ? const VerticalDivider(width: 1, color: MyColors.border,) : null,
                  ),
                  // 要素
                  right![i],
                },
              ],)
            )
          },

          const SizedBox(width: 5,),
        ],
      ),
    );
  }
}

class MyDrawer extends Drawer {
  const MyDrawer({super.key, this.title, required this.itemList, required this.onTap});

  final String? title; 
  final List<String> itemList;
  final void Function(int number) onTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      // ウィジェットの形
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      
      // 要素
      child: ListView(
        children: <Widget>[
          if(title != null)...{
            SizedBox(
              height: 50,
              width: double.infinity,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(title!, style: const TextStyle(fontSize: 20),),
              ),
            ),
            const Divider(height: 0, color: MyColors.border,),
          },

          for(int i = 0; i < itemList.length; i++)...{
            ListTile(
              title: Text(itemList[i]),
              onTap: () {
                onTap(i);
              },
            ),
          },
        ],
      ),
    );
  }
}

class MyIconButton extends StatelessWidget {
  const MyIconButton({super.key, required this.icon, this.message, required this.onPressed});

  final IconData icon;
  final void Function() onPressed;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message ?? "",
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
      )
    );
  }
}

class MyIconToggleButtons extends StatelessWidget {
  const MyIconToggleButtons({super.key, required this.icons, this.messages, required this.value, required this.onPressed,});

  final int value;
  final List<IconData> icons;
  final void Function(int value) onPressed;
  final List<String>? messages;

  @override
  Widget build(BuildContext context) {
    List<bool> isSelected = List.generate(icons.length, (index) => false);
    isSelected[value] = true;

    return ToggleButtons(
      constraints: const BoxConstraints(
        minWidth: MySize.iconButton,
        minHeight: MySize.iconButton,
        maxWidth: MySize.iconButton,
        maxHeight: MySize.iconButton,
      ),
      borderColor: Colors.transparent,
      isSelected: isSelected,
      onPressed: onPressed,
      children: [
        for(int i = 0; i < icons.length; i++)...{
          Tooltip(
            message: messages != null ? messages![i] : "",
            child: Icon(icons[i]),
          )
        }
      ],
    );
  }
}

class MyMenuDropdown extends StatelessWidget {
  const MyMenuDropdown({super.key, required this.value, required this.items, required this.onPressed});

  final int value;
  final List<String> items;
  final void Function(int value) onPressed;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: items[value],
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      underline: Container(color: Colors.transparent),
      onChanged: (String? newValue) {
        for(int i = 0; i < items.length; i++){
          if(newValue == items[i]){
            onPressed(i);
            break;
          }
        }
      },
    );
  }
}


class MyCustomPaint extends StatelessWidget {
  const MyCustomPaint({super.key, required this.painter, this.onTap, this.onDrag, required this.backgroundColor});

  final void Function(Offset position)? onTap, onDrag;
  final CustomPainter painter;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          onTap!(details.localPosition);
          if(onDrag != null){
            onDrag!(details.localPosition);
          }
        },
        onHorizontalDragUpdate: (details) {
          if(onDrag != null){
            onDrag!(details.localPosition);
          }
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // 利用可能な最大幅と高さを取得
            final double maxWidth = constraints.maxWidth;
            final double maxHeight = constraints.maxHeight;

            return ClipRect( // 指定範囲外の描画を防ぐ
              child: CustomPaint(
                size: Size(maxWidth, maxHeight), // ここで動的にサイズを指定
                painter: painter,
              ),
            );
          },
        ),
      ),
    );
  }
}
