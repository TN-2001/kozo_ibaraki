import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kozo_ibaraki/app/pages/drawer/common_drawer.dart';
import 'package:kozo_ibaraki/app/pages/privacy/ui/privacy_bar.dart';
import 'package:kozo_ibaraki/core/components/component.dart';

Future<String> _loadHtmlFromAssets() async {
  return await rootBundle.loadString('assets/privacy.html');
}

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>(); // Drawer表示用のキー

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      drawer: CommonDrawer(
        onPressedHelpButton: () {
          
        },
      ),

      body: SafeArea(
        child: ClipRect(
          child: Column(
            children: [
              PrivacyBar(scaffoldKey: scaffoldKey),

              const BaseDivider(),

              Expanded(
                child: 
              FutureBuilder<String>(
                future: _loadHtmlFromAssets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView( // スクロールが必要な場合に備えて
                        child: SizedBox(
                          width: double.infinity,
                          child:Align(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 1000,
                              ),
                              child: Html(data: snapshot.data!),
                            ),
                          )
                        )
                      );
                    } else {
                      return const Center(child: Text('Error loading HTML'));
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}