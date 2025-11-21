import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kozo_ibaraki/app/pages/beam/beam_page.dart';
import 'package:kozo_ibaraki/app/pages/bridgegame/bridgegame_page.dart';
import 'package:kozo_ibaraki/app/pages/fem/fem_page.dart';
import 'package:kozo_ibaraki/app/pages/frame/frame_page.dart';
import 'package:kozo_ibaraki/app/pages/home/home_page.dart';
import 'package:kozo_ibaraki/app/pages/privacy/privacy_page.dart';
import 'package:kozo_ibaraki/app/pages/truss/truss_page.dart';
import 'package:kozo_ibaraki/core/configs/configure_nonweb.dart'
    if (dart.library.html) 'package:kozo_ibaraki/core/configs/configure_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kozo_ibaraki/core/services/analytics_services.dart';
import 'package:kozo_ibaraki/core/services/navigator_services.dart';
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
  AnalyticsServices().logPageView("app");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final navDebug = NavigatorServices();

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/beam',
          builder: (context, state) => const BeamPage(),
        ),
        GoRoute(
          path: '/truss',
          builder: (context, state) => const TrussPage(),
        ),
        GoRoute(
          path: '/frame',
          builder: (context, state) => const FramePage(),
        ),
        GoRoute(
          path: '/fem',
          builder: (context, state) => const FemPage(),
        ),
        GoRoute(
          path: '/bridgegame',
          builder: (context, state) => const BridgegamePage(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyPage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: "Kozo App: 茨城大学 車谷研究室",
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
