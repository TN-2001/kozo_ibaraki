import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_data.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class FemSettingWindow extends StatefulWidget {
  const FemSettingWindow({super.key, required this.controller});

  final FemData controller;

  @override
  State<FemSettingWindow> createState() => _FemSettingWindowState();
}

class _FemSettingWindowState extends State<FemSettingWindow> {
  late FemData _controller;
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

  Widget _textFieldsSettingItemField(List<Widget> children) {
    return Row(
      children: [
        for (final child in children)...{
          Expanded(
            flex: 1,
            child: child,
          ),
        },
      ],
    );
  }

  Widget _textBox(String text) {
    return Container(
      padding: const EdgeInsets.only(
        left: MyDimens.baseSpacing,
        right: MyDimens.baseSpacing,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: MyDimens.baseFontSize,
        ),
      ),
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
          child: _textFieldsSettingItemField([
            Row(
              children: [
                _textBox("水平"),
                Expanded(
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
              ],
            ),

            Row(
              children: [
                _textBox("鉛直"),
                Expanded(
                  child: 
                  BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.pos = Offset(node.pos.dx, double.parse(text));
                      } else {
                        node.pos = Offset(node.pos.dx, 0);
                      }
                    }, 
                    text: '${node.pos.dy}',
                  ),
                ),
              ]
            )
          ]),
        ),

        SettingItem(
          label: "拘束条件",
          child: Row(
            children: [
              _textBox("水平"),
              Checkbox(
                value: node.constXY[0], 
                onChanged: (value){
                  setState(() {
                    node.constXY[0] = value!;
                  });
                },
              ),
              _textBox("鉛直"),
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
          label: "強制変位",
          child: _textFieldsSettingItemField([
            Row(
              children: [
                _textBox("水平"),
                Expanded(
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.loadXY[0] = double.parse(text);
                      } else {
                        node.loadXY[0] = 0;
                      }
                    }, 
                    text: node.loadXY[0] != 0 ? "${node.loadXY[0]}" : "",
                  ),
                ),
              ],
            ),

            
            Row(
              children: [
                _textBox("鉛直"),
                Expanded(
                  child: BaseTextField(
                    width: 100,
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
              ],
            ),
          ],),
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
          child: _textFieldsSettingItemField([
            BaseTextField(
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
            BaseTextField(
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
            BaseTextField(
              onChanged: (String text) {
                if (int.tryParse(text) != null) {
                  int value = int.parse(text);
                  if(0 <= value-1 && value-1 < _controller.nodeList.length){
                    elem.nodeList[2] = _controller.nodeList[value-1];
                  } else {
                    elem.nodeList[2] = null;
                  }
                }
              }, 
              text: elem.nodeList[2] != null ? "${elem.nodeList[2]!.number+1}" : "",
            ),
          ],),
        ),

        SettingItem(
          label: "ヤング率",
          child: BaseTextField(
            width: 200,
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
          label: "ポアソン比",
          child: BaseTextField(
            width: 200,
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
      ]);
    }
  }
}