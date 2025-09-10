import 'package:flutter/material.dart';

import '../../../components/component.dart';
import '../../../constants/constant.dart';
import '../models/beam_data.dart';

class BeamSettingWindow extends StatefulWidget {
  const BeamSettingWindow({super.key, required this.controller});

  final BeamData controller;

  @override
  State<BeamSettingWindow> createState() => _BeamSettingWindowState();
}

class _BeamSettingWindowState extends State<BeamSettingWindow> {
  late BeamData _controller;
  final double _windowMaxWidth = 500;

  bool isCheck = false;


  Widget _settingWindow(List<Widget> children) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.all(MyDimens.baseSpacing * 2),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SettingWindow(
          maxWidth: _windowMaxWidth,
          children: children,
        )
      )
    );
  }

  Widget _buttonSettingItemField(Widget child) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        child,
      ]
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
      } else if (_controller.selectNodeNumber != -1) {
        node = _controller.nodeList[_controller.selectNodeNumber];
      } else {
        return const SizedBox();
      }

      return _settingWindow([
        if (_controller.toolIndex == 0)...{
          SettingItem(
            label: "No. ${_controller.nodeList.length + 1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: () {
                  setState(() {
                    _controller.addNode();
                    _controller.initSelect();
                  });
                }, 
                text: "追加",
              ),
            ),
          ),
        } else...{
          SettingItem(
            label: "No. ${_controller.nodeList[_controller.selectNodeNumber].number+1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: () {
                  setState(() {
                    _controller.removeNode(_controller.selectNodeNumber);
                    _controller.initSelect();
                  });
                },
                text: "削除",
              ),
            ),
          ),
        },

        const BaseDivider(),
        
        SettingItem(
          label: "節点座標（X方向）",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                node.pos = Offset(double.parse(text), node.pos.dy);
              } else {
                node.pos = Offset(0, node.pos.dy);
              }
            }, 
            text: '${node.pos.dx}',
          ),
        ),

        SettingItem(
          label: "拘束条件",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelFit(
                  label: "X",
                  child: Checkbox(
                    value: node.constXYR[0], 
                    onChanged: (value){
                      setState(() {
                        node.constXYR[0] = value!;
                      });
                    },
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelFit(
                  label: "Y",
                  child: Checkbox(
                    value: node.constXYR[1], 
                    onChanged: (value){
                      setState(() {
                        node.constXYR[1] = value!;
                      });
                    },
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelFit(
                  label: "回転",
                  child: Checkbox(
                    value: node.constXYR[2], 
                    onChanged: (value){
                      setState(() {
                        node.constXYR[2] = value!;
                      });
                    },
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelFit(
                  label: "ヒンジ",
                  child: Checkbox(
                    value: node.constXYR[3], 
                    onChanged: (value){
                      setState(() {
                        node.constXYR[3] = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      
        SettingItem(
          label: "集中荷重（Y方向）",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                node.loadXY[1] = double.parse(text);
              } else {
                node.loadXY[1] = 0;
              }
            }, 
            text: node.loadXY[1] != 0 ? "${node.loadXY[1]}" : "",
          ),
        ),

        SettingItem(
          label: "モーメント荷重",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                node.loadXY[2] = double.parse(text);
              } else {
                node.loadXY[2] = 0;
              }
            }, 
            text: node.loadXY[2] != 0 ? "${node.loadXY[2]}" : "",
          ),
        )
      ]);
    }
    else {
      Elem elem;
      if (_controller.toolIndex == 0) {
        elem = _controller.elem!;
      } else if (_controller.selectElemNumber != -1) {
        elem = _controller.elemList[_controller.selectElemNumber];
      } else {
        return const SizedBox();
      }

      return _settingWindow([
        if (_controller.toolIndex == 0)...{
          SettingItem(
            label: "No. ${_controller.elemList.length + 1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: (){
                  setState(() {
                    _controller.addElem();
                    _controller.initSelect();
                  });
                }, 
                text: "追加",
              ),
            ),
          ),
        } else...{
          SettingItem(
            label: "No. ${_controller.elemList[_controller.selectElemNumber].number+1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: (){
                  setState(() {
                    _controller.removeElem(_controller.selectElemNumber);
                    _controller.initSelect();
                  });
                }, 
                text: "削除",
              ),
            ),
          ),
        },

        const BaseDivider(),

        SettingItem(
          label: "節点番号",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelNotFit(
                  label: "a",
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (int.tryParse(text) != null) {
                        int value = int.parse(text);
                        if(0 <= value-1 && value-1 < _controller.nodeList.length){
                          elem.nodeList[0] = _controller.nodeList[value-1];
                        } else {
                          elem.nodeList[0] = null;
                        }
                      }
                    }, 
                    text: elem.nodeList[0] != null ? "${elem.nodeList[0]!.number+1}" : "",
                  ),
                )
              ),

              Expanded(
                child: SettingItem.labelNotFit(
                  label: "b",
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (int.tryParse(text) != null) {
                        int value = int.parse(text);
                        if(0 <= value-1 && value-1 < _controller.nodeList.length){
                          elem.nodeList[1] = _controller.nodeList[value-1];
                        } else {
                          elem.nodeList[1] = null;
                        }
                      }
                    }, 
                    text: elem.nodeList[1] != null ? "${elem.nodeList[1]!.number+1}" : "",
                  ),
                ),
              ),
            ],
          ),
        ),

        SettingItem(
          label: "ヤング率",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.e = double.parse(text);
              } else {
                elem.e = 0;
              }
            }, 
            text: "${elem.e}"
          ),
        ),

        SettingItem(
          label: "断面二次モーメント",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.v = double.parse(text);
              } else {
                elem.v = 0;
              }
            }, 
            text: "${elem.v}"
          ),
        ),

        SettingItem(
          label: "等分布荷重（Y方向）",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.load = double.parse(text);
              } else {
                elem.load = 0;
              }
            }, 
            text: "${elem.load != 0 ? elem.load : ""}"
          ),
        ),
      ]);
    }
  }
}