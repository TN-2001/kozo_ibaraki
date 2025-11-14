import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kozo_ibaraki/app/pages/beam/beam_page.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/bridgegame_page.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame_free/bridgegame_free_page.dart';
import 'package:kozo_ibaraki/app/pages/fem/fem_page.dart';
import 'package:kozo_ibaraki/app/pages/frame/frame_page.dart';
import 'package:kozo_ibaraki/app/pages/home/home_page.dart';
import 'package:kozo_ibaraki/app/pages/privacy/privacy_page.dart';
import 'package:kozo_ibaraki/app/pages/truss/truss_page.dart';
import 'package:kozo_ibaraki/core/configs/configure_nonweb.dart' 
  if (dart.library.html) 'package:kozo_ibaraki/core/configs/configure_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kozo_ibaraki/firebase_options.dart';

void run() async {
  // FlutterフレームワークとFlutterエンジンを結びつける
  WidgetsFlutterBinding.ensureInitialized();

  // 各プラットフォームの設定
  if (kIsWeb) {
    configureWeb();
  }

  // Firebaseと接続
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // アプリを開いたらイベントを取得
  await FirebaseAnalytics.instance.logEvent(
    name: 'page_view',
  );

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
        '/': (context) => const HomePage(),
        '/beam': (context) => const BeamPage(),
        '/truss':(context) => const TrussPage(),
        '/frame':(context) => const FramePage(),
        '/fem':(context) => const FemPage(),
        '/bridgegame':(context) => const BridgegamePage(),
        '/bridgegamefree':(context) => const BridgegameFreePage(),
        '/privacy':(context) => const PrivacyPage(),
      },
    );
  }
}