import 'package:flutter/material.dart';

import '../../../components/component.dart';
import '../../../constants/constant.dart';
import '../models/frame_controller.dart';

class FrameSettingWindow extends StatefulWidget {
  const FrameSettingWindow({super.key, required this.controller});

  final FrameController controller;

  @override
  State<FrameSettingWindow> createState() => _FrameSettingWindowState();
}

class _FrameSettingWindowState extends State<FrameSettingWindow> {
  late FrameController _controller;
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
    if (_controller.isCalculated) {
      return const SizedBox();
    }

    if (_controller.typeIndex == 0) {
      Node node;
      if (_controller.selectedNumber != -1) {
        node = _controller.data.getNode(_controller.selectedNumber);
      } else {
        return const SizedBox();
      }

      return _settingWindow([
        if (_controller.toolIndex == 0)...{
          SettingItem(
            label: "No. ${node.number + 1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: () {
                  setState(() {
                    _controller.data.addNode();
                    _controller.initSelect();
                  });
                }, 
                text: "追加",
              ),
            ),
          ),
        } else...{
          SettingItem(
            label: "No. ${node.number + 1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: () {
                  setState(() {
                    _controller.data.removeNode(_controller.selectedNumber);
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
                        node.changePos(Offset(double.parse(text), node.pos.dy));
                      } else {
                        node.changePos(Offset(0, node.pos.dy));
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
                        node.changePos(Offset(node.pos.dx, double.parse(text)));
                      } else {
                        node.changePos(Offset(node.pos.dx, 0));
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
                value: node.getConst(0), 
                onChanged: (value){
                  setState(() {
                    node.changeConst(0, value!);
                  });
                },
              ),
              _textBox("鉛直"),
              Checkbox(
                value: node.getConst(1), 
                onChanged: (value){
                  setState(() {
                    node.changeConst(1, value!);
                  });
                },
              ),
              _textBox("回転"),
              Checkbox(
                value: node.getConst(2), 
                onChanged: (value){
                  setState(() {
                    node.changeConst(2, value!);
                  });
                },
              ),
              _textBox("ヒンジ"),
              Checkbox(
                value: node.getConst(3), 
                onChanged: (value){
                  setState(() {
                    node.changeConst(3, value!);
                  });
                },
              ),
            ],
          ),
        ),
      
        SettingItem(
          label: "集中荷重",
          child: _textFieldsSettingItemField([
            Row(
              children: [
                _textBox("水平"),
                Expanded(
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.changeLoad(0, double.parse(text));
                      } else {
                        node.changeLoad(0, 0.0);
                      }
                    }, 
                    text: node.getLoad(0) != 0 ? "${node.getLoad(0)}" : "",
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
                        node.changeLoad(1, double.parse(text));
                      } else {
                        node.changeLoad(1, 0);
                      }
                    }, 
                    text: node.getLoad(1) != 0 ? "${node.getLoad(1)}" : "",
                  ),
                ),
              ],
            ),

            Row(
              children: [
                _textBox("モーメント"),
                Expanded(
                  child: BaseTextField(
                    width: 100,
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.changeLoad(2, double.parse(text));
                      } else {
                        node.changeLoad(2, 0);
                      }
                    }, 
                    text: node.getLoad(2) != 0 ? "${node.getLoad(2)}" : "",
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
      if (_controller.selectedNumber != -1) {
        elem = _controller.data.getElem(_controller.selectedNumber);
      } else {
        return const SizedBox();
      }

      return _settingWindow([
        if (_controller.toolIndex == 0)...{
          SettingItem(
            label: "No. ${elem.number + 1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: (){
                  setState(() {
                    _controller.data.addElem();
                    _controller.initSelect();
                  });
                }, 
                text: "追加",
              ),
            ),
          ),
        } else...{
          SettingItem(
            label: "No. ${elem.number + 1}",
            child: _buttonSettingItemField(
              BaseTextButton(
                onPressed: (){
                  setState(() {
                    _controller.data.removeElem(_controller.selectedNumber);
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
                  if(0 <= value - 1 && value - 1 < _controller.data.nodeCount){
                    elem.changeNode(0, _controller.data.getNode(value - 1));
                  } else {
                    elem.changeNode(0, null);
                  }
                }
              }, 
              text: elem.getNode(0) != null ? "${elem.getNode(0)!.number + 1}" : "",
            ),
            BaseTextField(
              onChanged: (String text) {
                if (int.tryParse(text) != null) {
                  int value = int.parse(text);
                  if(0 <= value - 1 && value - 1 < _controller.data.nodeCount){
                    elem.changeNode(1, _controller.data.getNode(value - 1));
                  } else {
                    elem.changeNode(1, null);
                  }
                }
              }, 
              text: elem.getNode(1) != null ? "${elem.getNode(1)!.number + 1}" : "",
            ),
          ],),
        ),

        SettingItem(
          label: "ヤング率",
          child: BaseTextField(
            width: 200,
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.changeLigid(0, double.parse(text));
              } else {
                elem.changeLigid(0, 0.0);
              }
            }, 
            text: "${elem.getRigid(0)}"
          ),
        ),

        SettingItem(
          label: "断面二次モーメント",
          child: BaseTextField(
            width: 200,
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.changeLigid(1, double.parse(text));
              } else {
                elem.changeLigid(1, 0.0);
              }
            }, 
            text: "${elem.getRigid(1)}"
          ),
        ),

        SettingItem(
          label: "断面積",
          child: BaseTextField(
            width: 200,
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.changeLigid(2, double.parse(text));
              } else {
                elem.changeLigid(2, 0.0);
              }
            }, 
            text: "${elem.getRigid(2)}"
          ),
        ),

        SettingItem(
          label: "分布荷重",
          child: BaseTextField(
            width: 200,
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.changeLoad(double.parse(text));
              } else {
                elem.changeLoad(0.0);
              }
            }, 
            text: "${elem.load}"
          ),
        ),
      ]);
    }
  }
}