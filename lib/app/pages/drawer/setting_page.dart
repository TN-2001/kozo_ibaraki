import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/models/setting.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

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
    return BaseDialog(
      child: Column(
        children: [
          BaseRow(
            padding: const EdgeInsets.all(BaseDimens.spacing),
            children: [
              const BaseText(
                "設定",
                margin: EdgeInsets.only(left: BaseDimens.spacing),
                fontSize: BaseDimens.titleFontSize,
              ),

              const Expanded(child: SizedBox()),

              BaseIconButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                icon: const Icon(Icons.close),
                tooltip: "閉じる",
              ),
            ]
          ),

          const BaseDivider(margin: EdgeInsets.symmetric(horizontal: BaseDimens.spacing),),

          Expanded(
            child: BaseListView(
              margin: const EdgeInsets.symmetric(vertical: BaseDimens.spacing),
              padding: const EdgeInsets.symmetric(horizontal: BaseDimens.spacing),
              children: [
                SwitchListTile(
                  value: Setting.isNodeNumber, 
                  contentPadding: EdgeInsets.only(
                    left: BaseDimens.padding.left,
                    right: BaseDimens.padding.right,
                  ),
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
                  contentPadding: EdgeInsets.only(
                    left: BaseDimens.padding.left,
                    right: BaseDimens.padding.right,
                  ),
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
                  contentPadding: EdgeInsets.only(
                    left: BaseDimens.padding.left,
                    right: BaseDimens.padding.right,
                  ),
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
        ],
      ),
    );
  }
}