import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/models/setting.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/colors.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, this.onChangeValue});

  final void Function()? onChangeValue;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late void Function()? onChangeValue;

  @override
  void initState() {
    super.initState();
    onChangeValue = widget.onChangeValue;
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: MyColors.baseBackground,
      child: page(),
    );
  }


  Widget page() {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 600,
        maxWidth: 700,
      ),

      child: Column(
        children: [

          ToolBar(
            color: Colors.transparent,
            children: [
              const BaseText(
                "設定",
                margin: EdgeInsets.only(left: 10),
                fontSize: 20,
              ),

              const Expanded(child: SizedBox()),

              ToolIconButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                icon: const Icon(Icons.close),
                message: "閉じる",
              ),
            ]
          ),

          const BaseDivider(
            margin: EdgeInsets.only(left: 10, right: 10),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: Setting.isNodeNumber, 
                        onChanged: (value) {
                          setState(() {
                            Setting.setIsNodeNumber(value);
                            if (onChangeValue != null) {
                              onChangeValue!();
                            }
                          });
                        }, 
                        title: const BaseText("節点番号の表示"),
                      ),
                      SwitchListTile(
                        value: Setting.isElemNumber, 
                        onChanged: (value) {
                          setState(() {
                            Setting.setIsElemNumber(value);
                            if (onChangeValue != null) {
                              onChangeValue!();
                            }
                          });
                        }, 
                        title: const BaseText("要素番号の表示"),
                      ),
                      SwitchListTile(
                        value: Setting.isResultValue, 
                        onChanged: (value) {
                          setState(() {
                            Setting.setIsResultValue(value);
                            if (onChangeValue != null) {
                              onChangeValue!();
                            }
                          });
                        }, 
                        title: const BaseText("要素の結果値の表示（FEM）"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}