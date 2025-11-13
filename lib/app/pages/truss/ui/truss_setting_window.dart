import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/truss/models/truss_data.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class TrussSettingWindow extends StatefulWidget {
  const TrussSettingWindow({super.key, required this.controller});

  final TrussData controller;

  @override
  State<TrussSettingWindow> createState() => _TrussSettingWindowState();
}

class _TrussSettingWindowState extends State<TrussSettingWindow> {
  late TrussData _controller;
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
      } else if (_controller.selectedNumber != -1) {
        node = _controller.nodeList[_controller.selectedNumber];
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
            label: "No. ${_controller.nodeList[_controller.selectedNumber].number+1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: () {
                  setState(() {
                    _controller.removeNode(_controller.selectedNumber);
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
          label: "節点座標",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelNotFit(
                  label: "X",
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.pos = Offset(double.parse(text), node.pos.dy);
                      } else if (text == "") {
                        node.pos = Offset(0, node.pos.dy);
                      }
                    }, 
                    text: '${node.pos.dx}',
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelNotFit(
                  label: "Y",
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.pos = Offset(node.pos.dx, double.parse(text));
                      } else if (text == "") {
                        node.pos = Offset(node.pos.dx, 0);
                      }
                    }, 
                    text: '${node.pos.dy}',
                  ),
                ),
              ),
            ],
          ),
        ),

        SettingItem(
          label: "拘束条件",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelFit(
                  label: "X",
                  child: BaseCheckbox(
                    value: node.constXY[0], 
                    onChanged: (value){
                      setState(() {
                        node.constXY[0] = value!;
                      });
                    },
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelFit(
                  label: "Y",
                  child: BaseCheckbox(
                    value: node.constXY[1], 
                    onChanged: (value){
                      setState(() {
                        node.constXY[1] = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      
        SettingItem(
          label: "集中荷重",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelNotFit(
                  label: "X",
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.loadXY[0] = double.parse(text);
                      } else if (text == "") {
                        node.loadXY[0] = 0;
                      }
                    }, 
                    text: node.loadXY[0] != 0 ? "${node.loadXY[0]}" : "",
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelNotFit(
                  label: "Y",
                  child: BaseTextField(
                    width: 100,
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.loadXY[1] = double.parse(text);
                      } else if (text == "") {
                        node.loadXY[1] = 0;
                      }
                    }, 
                    text: node.loadXY[1] != 0 ? "${node.loadXY[1]}" : "",
                  ),
                ),
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
            label: "No. ${_controller.elemList[_controller.selectedNumber].number+1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: (){
                  setState(() {
                    _controller.removeElem(_controller.selectedNumber);
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
                        } else if (text == "") {
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
                        } else if (text == "") {
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
              } else if (text == "") {
                elem.e = 0;
              }
            }, 
            text: "${elem.e}"
          ),
        ),

        SettingItem(
          label: "断面積",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.v = double.parse(text);
              } else if (text == "") {
                elem.v = 0;
              }
            }, 
            text: "${elem.v}"
          ),
        ),
      ]);
    }
  }
}