import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/views/beam/beam_page.dart';
import 'package:kozo_ibaraki/views/bridge/bridge_page.dart';
import 'package:kozo_ibaraki/views/bridgegame/bridgegame_page.dart';
import 'package:kozo_ibaraki/views/bridgegame_free/bridgegame_free_page.dart';
import 'package:kozo_ibaraki/views/fem/fem_page.dart';
import 'package:kozo_ibaraki/views/privacy/privacy_page.dart';
import 'package:kozo_ibaraki/views/truss/truss_page.dart';
import 'configs/configure_nonweb.dart' if (dart.library.html) 'configs/configure_web.dart';

void main() {
  // FlutterフレームワークとFlutterエンジンを結びつける
  WidgetsFlutterBinding.ensureInitialized();

  // 各プラットフォームの設定
  if (kIsWeb) {
    configureWeb();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "Kozo App: 茨城大学 車谷研究室",
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const BeamPage(),
        '/truss':(context) => const TrussPage(),
        '/bridge':(context) => const BridgePage(),
        '/bridgegame':(context) => const BridgegamePage(),
        '/bridgegamefree':(context) => const BridgegameFreePage(),
        '/fem':(context) => const FemPage(),
        '/privacy':(context) => const PrivacyPage(),
      },
    );
  }
}