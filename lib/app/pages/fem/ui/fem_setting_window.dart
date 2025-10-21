import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/fem/models/fem_controller.dart';
import 'package:kozo_ibaraki/core/components/component.dart';
import 'package:kozo_ibaraki/core/constants/constant.dart';

class FemSettingWindow extends StatefulWidget {
  const FemSettingWindow({super.key, required this.controller});

  final FemController controller;

  @override
  State<FemSettingWindow> createState() => _FemSettingWindowState();
}

class _FemSettingWindowState extends State<FemSettingWindow> {
  late FemController _controller;
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
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelNotFit(
                  label: 'X',
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.setPos(Offset(double.parse(text), node.pos.dy));
                      } else {
                        node.setPos(Offset(0, node.pos.dy));
                      }
                    }, 
                    text: '${node.pos.dx}',
                  ),
                ),
              ),
              Expanded(
                child: SettingItem.labelNotFit(
                  label: 'Y',
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.setPos(Offset(node.pos.dx, double.parse(text)));
                      } else {
                        node.setPos(Offset(node.pos.dx, 0));
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
                  label: 'X',
                  child: BaseCheckbox(
                    value: node.getConst(0), 
                    onChanged: (value){
                      setState(() {
                        node.setConst(0, value!);
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: SettingItem.labelFit(
                  label: 'Y',
                  child: BaseCheckbox(
                    value: node.getConst(1),  
                    onChanged: (value){
                      setState(() {
                        node.setConst(1, value!);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      
        SettingItem(
          label: "強制変位",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelNotFit(
                  enabled: node.getConst(0),
                  label: 'X',
                  child: BaseTextField(
                    enabled: node.getConst(0),
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.setLoad(0, double.parse(text));
                      } else {
                        node.setLoad(0, 0);
                      }
                    }, 
                    text: node.getLoad(0) != 0 ? "${node.getLoad(0)}" : "",
                  ),
                ),
              ),
              
              Expanded(
                child: SettingItem.labelNotFit(
                  enabled: node.getConst(1),
                  label: 'Y',
                  child: BaseTextField(
                    enabled: node.getConst(1),
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.setLoad(1, double.parse(text));
                      } else {
                        node.setLoad(1, 0);
                      }
                    }, 
                    text: node.getLoad(1) != 0 ? "${node.getLoad(1)}" : "",
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
                  enabled: !node.getConst(0),
                  label: 'X',
                  child: BaseTextField(
                    enabled: !node.getConst(0),
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.setLoad(2, double.parse(text));
                      } else {
                        node.setLoad(2, 0);
                      }
                    }, 
                    text: node.getLoad(2) != 0 ? "${node.getLoad(2)}" : "",
                  ),
                ),
              ),
              
              Expanded(
                child: SettingItem.labelNotFit(
                  enabled: !node.getConst(1),
                  label: 'Y',
                  child: BaseTextField(
                    enabled: !node.getConst(1),
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        node.setLoad(3, double.parse(text));
                      } else {
                        node.setLoad(3, 0);
                      }
                    }, 
                    text: node.getLoad(3) != 0 ? "${node.getLoad(3)}" : "",
                  ),
                ),
              ),
            ],
          ),
        ),
      ]);
    }
    else if (_controller.typeIndex == 1) {
      Elem elem;
      if (_controller.selectedNumber != -1) {
        elem = _controller.data.getElem(_controller.selectedNumber);
      } else {
        return const SizedBox();
      }

      Elem matElem = _controller.data.matElem;

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
          label: "要素の形",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelFit(
                  enabled: _controller.toolIndex == 0,
                  label: "三角形",
                  child: BaseCheckbox(
                    enabled: _controller.toolIndex == 0,
                    onChanged: (value) {
                      setState(() {
                        if (value! == true) {
                          _controller.data.matElem.setNodeCount(3);
                          elem.setNodeCount(3);
                          elem.setNode(3, null);
                        } else {
                          _controller.data.matElem.setNodeCount(4);
                          elem.setNodeCount(4);
                        }
                      });
                    }, 
                    value: elem.nodeCount == 3,
                  ),
                ),
              ),
              Expanded(
                child: SettingItem.labelFit(
                  enabled: _controller.toolIndex == 0,
                  label: "四角形",
                  child: BaseCheckbox(
                    enabled: _controller.toolIndex == 0,
                    onChanged: (value) {
                      setState(() {
                        if (value! == true) {
                          _controller.data.matElem.setNodeCount(4);
                          elem.setNodeCount(4);
                        } else {
                          _controller.data.matElem.setNodeCount(3);
                          elem.setNodeCount(3);
                          elem.setNode(3, null);
                        }
                      });
                    }, 
                    value: elem.nodeCount == 4,
                  ),
                ),
              ),
            ],
          ),
        ),

        SettingItem(
          label: "節点番号",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelNotFit(
                  enabled: _controller.toolIndex == 0,
                  label: "a",
                  child: BaseTextField(
                    enabled: _controller.toolIndex == 0,
                    onChanged: (String text) {
                      if (int.tryParse(text) != null) {
                        int value = int.parse(text);
                        if(0 <= value - 1 && value - 1 < _controller.data.nodeCount){
                          elem.setNode(0, _controller.data.getNode(value - 1));
                        } else {
                          elem.setNode(0, null);
                        }
                      }
                    }, 
                    text: elem.getNode(0) != null ? "${elem.getNode(0)!.number + 1}" : "",
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelNotFit(
                  enabled: _controller.toolIndex == 0,
                  label: "b",
                  child: BaseTextField(
                    enabled: _controller.toolIndex == 0,
                    onChanged: (String text) {
                      if (int.tryParse(text) != null) {
                        int value = int.parse(text);
                        if(0 <= value - 1 && value - 1 < _controller.data.nodeCount){
                          elem.setNode(1, _controller.data.getNode(value - 1));
                        } else {
                          elem.setNode(1, null);
                        }
                      }
                    }, 
                    text: elem.getNode(1) != null ? "${elem.getNode(1)!.number + 1}" : "",
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelNotFit(
                  enabled: _controller.toolIndex == 0,
                  label: "c",
                  child: BaseTextField(
                    enabled: _controller.toolIndex == 0,
                    onChanged: (String text) {
                      if (int.tryParse(text) != null) {
                        int value = int.parse(text);
                        if(0 <= value - 1 && value - 1 < _controller.data.nodeCount){
                          elem.setNode(2, _controller.data.getNode(value - 1));
                        } else {
                          elem.setNode(2, null);
                        }
                      }
                    }, 
                    text: elem.getNode(2) != null ? "${elem.getNode(2)!.number + 1}" : "",
                  ),
                ),
              ),

              if (elem.nodeCount == 4)
              Expanded(
                child: SettingItem.labelNotFit(
                  enabled: _controller.toolIndex == 0,
                  label: "d",
                  child: BaseTextField(
                    enabled: _controller.toolIndex == 0,
                    onChanged: (String text) {
                      if (int.tryParse(text) != null) {
                        int value = int.parse(text);
                        if(0 <= value - 1 && value - 1 < _controller.data.nodeCount){
                          elem.setNode(3, _controller.data.getNode(value - 1));
                        } else {
                          elem.setNode(3, null);
                        }
                      }
                    }, 
                    text: elem.getNode(3) != null ? "${elem.getNode(3)!.number + 1}" : "",
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
                matElem.setRigid(0, double.parse(text));
                elem.setRigid(0, double.parse(text));
              } else {
                matElem.setRigid(0, 0);
                elem.setRigid(0, 0);
              }
            }, 
            text: elem.getRigid(0).toString(),
          ),
        ),

        SettingItem(
          label: "ポアソン比",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                matElem.setRigid(1, double.parse(text));
                elem.setRigid(1, double.parse(text));
              } else {
                matElem.setRigid(1, 0);
                elem.setRigid(1, 0);
              }
            }, 
            text: elem.getRigid(1).toString(),
          ),
        ),

        SettingItem(
          label: "物体力",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelNotFit(
                  label: 'bx',
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        matElem.setRigid(2, double.parse(text));
                        elem.setRigid(2, double.parse(text));
                      } else {
                        matElem.setRigid(2, 0);
                        elem.setRigid(2, 0);
                      }
                    }, 
                    text: elem.getRigid(2) != 0 ? elem.getRigid(2).toString() : "",
                  ),
                ),
              ),

              Expanded(
                child: SettingItem.labelNotFit(
                  label: 'by',
                  child: BaseTextField(
                    onChanged: (String text) {
                      if (double.tryParse(text) != null) {
                        matElem.setRigid(3, double.parse(text));
                        elem.setRigid(3, double.parse(text));
                      } else {
                        matElem.setRigid(3, 0);
                        elem.setRigid(3, 0);
                      }
                    }, 
                    text: elem.getRigid(3) != 0 ? elem.getRigid(3).toString() : "",
                  ),
                ),
              ),
            ],
          )
        ),
      ]);
    }
    else if (_controller.typeIndex == 2) {
      Elem elem = _controller.data.matElem; 
      return _settingWindow([
        const SettingItem(
          label: "要素のマテリアル",
        ),

        const BaseDivider(),

        SettingItem(
          label: "要素の厚さ",
          child: BaseTextField(
            onChanged: (String text) {
              if (double.tryParse(text) != null) {
                elem.setRigid(4, double.parse(text));
              } else {
                elem.setRigid(4, 0);
              }
            }, 
            text: elem.getRigid(4).toString(),
          ),
        ),

        SettingItem(
          label: "平面",
          child: Row(
            children: [
              Expanded(
                child: SettingItem.labelFit(
                  label: "平面応力",
                  child: BaseCheckbox(
                    onChanged: (value) {
                      setState(() {
                        if (value! == true) {
                          elem.setPlane(0);
                        } else {
                          elem.setPlane(1);
                        }
                      });
                    }, 
                    value: elem.plane == 0,
                  ),
                ),
              ),
              Expanded(
                child: SettingItem.labelFit(
                  label: "平面ひずみ",
                  child: BaseCheckbox(
                    onChanged: (value) {
                      setState(() {
                        if (value! == true) {
                          elem.setPlane(1);
                        } else {
                          elem.setPlane(0);
                        }
                      });
                    }, 
                    value: elem.plane == 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]);
    }
    else {
      return const SizedBox();
    }
  }
}