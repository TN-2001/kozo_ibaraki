import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/component.dart';
import '../../utils/status_bar.dart';
import '../common/common_drawer.dart';
import 'canvas/beam_canvas.dart';
import 'models/beam_data.dart';
import 'ui/beam_bar.dart';
import 'ui/beam_canvas_ui.dart';
import 'ui/beam_setting_window.dart';


class BeamPage extends StatefulWidget {
  const BeamPage({super.key});

  @override
  State<BeamPage> createState() => _BeamPageState();
}

class _BeamPageState extends State<BeamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BeamData controller;
  bool isSumaho = false;
  Elem currentElem = Elem();


  void _onUpdate() {
    setState(() {
      // 画面更新
    });
  }


  @override
  void initState() {
    super.initState();

    controller = BeamData(onDebug: (value){},);
    controller.node = Node();
    controller.addListener(_onUpdate);

    StatusBar.setStyle(isDarkBackground: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    StatusBar.setModeByOrientation(context);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size; // 画面サイズ取得
    if(size.height > size.width && isSumaho == false) {
      setState(() {
        isSumaho = true;
        if(controller.resultIndex > 1){
          controller.changeResultIndex(0);
        }
      });
    }else if (size.height < size.width && isSumaho == true) {
      setState(() {
        isSumaho = false;
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,

      drawer: CommonDrawer(
        onPressedHelpButton: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("使い方（動画リンク）"),
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width / 1.5,
                  height: MediaQuery.sizeOf(context).width / 1.5 /16*9,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: (){
                        final url = Uri.parse('https://youtu.be/44JrBWd-lS4');
                        launchUrl(url);
                      },
                      child: Image.asset(
                        "assets/images/youtube/1.jpg",
                      )
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("閉じる"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            },
          );
        },
      ),

      body: SafeArea(
        child: ClipRect(
          child: Column(
            children: [
              BeamBar(controller: controller, scaffoldKey: _scaffoldKey),
              
              const BaseDivider(),

              Expanded(
                child: Stack(
                  children: [
                    BeamCanvas(controller: controller, devTypeNum: controller.resultIndex, isSumaho: isSumaho),

                    const BeamCanvasUi(),

                    BeamSettingWindow(controller: controller),
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}