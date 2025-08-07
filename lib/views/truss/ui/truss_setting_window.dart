import 'package:flutter/material.dart';

import '../../../components/component.dart';
import '../../../constants/constant.dart';
import '../models/truss_data.dart';


class TrussSettingWindow extends StatefulWidget {
  const TrussSettingWindow({super.key, required this.controller});

  final TrussData controller;

  @override
  State<TrussSettingWindow> createState() => _TrussSettingWindowState();
}

class _TrussSettingWindowState extends State<TrussSettingWindow> {
  late TrussData _controller;

  bool isCheck = false;


  Widget _settingWindow(List<Widget> children) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.all(MyDimens.baseSpacing * 2),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SettingWindow(
          children: children,
        )
      )
    );
  }

  Widget _textBox(String text) {
    return Container(
      padding: const EdgeInsets.only(
        left: MyDimens.baseSpacing,
        right: MyDimens.baseSpacing,
      ),
      child: Text(text),
    );
  }


  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isCalculation) {
      return const SizedBox();
    }

    if (_controller.typeIndex == 0) {
      Node node;
      if (_controller.toolIndex == 0) {
        node = _controller.node!;
      } else if (_controller.selectedNumber != -1) {
        node = _controller.nodeList[_controller.selectedNumber];
      } else {
        return const SizedBox();
      }

      return _settingWindow([
        if (_controller.toolIndex == 0)...{
          SettingItem(
            label: "No. ${_controller.nodeList.length + 1}",
            child: BaseTextButton(
              onPressed: () {
                setState(() {
                  _controller.addNode();
                  _controller.initSelect();
                });
              }, 
              text: "追加",
            ),
          ),
        } else...{
          SettingItem(
            label: "No. ${_controller.nodeList[_controller.selectedNumber].number+1}",
            child: BaseTextButton(
              onPressed: () {
                setState(() {
                  _controller.removeNode(_controller.selectedNumber);
                  _controller.initSelect();
                });
              },
              text: "追加",
            ),
          ),
        },

        const BaseDivider(),
        
        SettingItem(
          label: "節点座標",
          child: Row(
            children: [
              _textBox("水平"),
              BaseTextField(
                width: 100, 
                onChanged: (String text) {
                  if (double.tryParse(text) != null) {
                    node.pos = Offset(double.parse(text), node.pos.dy);
                  }
                }, 
                text: '${node.pos.dx}',
              ),
              _textBox("鉛直"),
              BaseTextField(
                width: 100,
                onChanged: (String text) {
                  if (double.tryParse(text) != null) {
                    node.pos = Offset(node.pos.dx, double.parse(text));
                  }
                }, 
                text: '${node.pos.dy}',
              ),
            ],
          ),
        ),

        SettingItem(
          label: "拘束条件",
          child: Row(
            children: [
              const Text("水平"),
              Checkbox(
                value: node.constXY[0], 
                onChanged: (value){
                  setState(() {
                    node.constXY[0] = value!;
                  });
                },
              ),
              const Text("鉛直"),
              Checkbox(
                value: node.constXY[1], 
                onChanged: (value){
                  setState(() {
                    node.constXY[1] = value!;
                  });
                },
              ),
            ],
          ),
        ),
      
        SettingItem(
          label: "集中荷重",
          child: Row(
            children: [
              _textBox("水平"),
              BaseTextField(
                width: 100,
                onChanged: (String text) {
                  if (double.tryParse(text) != null) {
                    node.loadXY[0] = double.parse(text);
                  }
                }, 
                text: node.loadXY[0] != 0 ? "${node.loadXY[0]}" : "",
              ),
              _textBox("鉛直"),
              BaseTextField(
                width: 100,
                onChanged: (String text) {
                  if (double.tryParse(text) != null) {
                    node.loadXY[1] = double.parse(text);
                  }
                }, 
                text: node.loadXY[1] != 0 ? "${node.loadXY[1]}" : "",
              ),
            ],
          ),
        ),
      ]);
    }
    else {
      Elem elem;
      if (_controller.toolIndex == 0) {
        elem = _controller.elem!;
      } else if (_controller.selectedNumber != -1) {
        elem = _controller.elemList[_controller.selectedNumber];
      } else {
        return const SizedBox();
      }

      return _settingWindow([
        if (_controller.toolIndex == 0)...{
          SettingItem(
            label: "No. ${_controller.elemList.length + 1}",
            child: BaseTextButton(
              onPressed: (){
                setState(() {
                  _controller.addElem();
                  _controller.initSelect();
                });
              }, 
              text: "追加",
            ),
          ),
        } else...{
          SettingItem(
            label: "No. ${_controller.elemList[_controller.selectedNumber].number+1}",
            child: BaseTextButton(
              onPressed: (){
                setState(() {
                  _controller.removeElem(_controller.selectedNumber);
                  _controller.initSelect();
                });
              }, 
              text: "追加",
            ),
          ),
        },

        const BaseDivider(),

        SettingItem(
          label: "節点番号",
          child: Row(
            children: [
              BaseTextField(
                width: 100,
                onChanged: (String text) {
                  if (int.tryParse(text) != null) {
                    int value = int.parse(text);
                    if(0 <= value-1 && value-1 < _controller.nodeList.length){
                      elem.nodeList[0] = _controller.nodeList[value-1];
                    }
                  }
                }, 
                text: elem.nodeList[0] != null ? "${elem.nodeList[0]!.number+1}" : "",
              ),
              BaseTextField(
                width: 100,
                onChanged: (String text) {
                  if (int.tryParse(text) != null) {
                    int value = int.parse(text);
                    if(0 <= value-1 && value-1 < _controller.nodeList.length){
                      elem.nodeList[1] = _controller.nodeList[value-1];
                    }
                  }
                }, 
                text: elem.nodeList[1] != null ? "${elem.nodeList[1]!.number+1}" : "",
              ),
            ],
          ),
        ),

        SettingItem(
          label: "ヤング率",
          child: BaseTextField(
            width: 200,
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.e = double.parse(text);
              }
            }, 
            text: "${elem.e}"
          ),
        ),

        SettingItem(
          label: "断面積",
          child: BaseTextField(
            width: 200,
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.v = double.parse(text);
              }
            }, 
            text: "${elem.v}"
          ),
        ),
      ]);
    }
  }
}