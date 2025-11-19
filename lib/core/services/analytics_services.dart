import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io' show Platform; // webではdart:ioは使えないから、webから優先してコードを書く

class AnalyticsServices {
  static final AnalyticsServices _instance = AnalyticsServices._internal();
  factory AnalyticsServices() => _instance;
  AnalyticsServices._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logPageView(String pageName) async {
    if (kIsWeb) {
      Future.microtask(() async {
        await _analytics.logEvent(
          name: '${pageName}_page_view',
          parameters: {'page': pageName},
        );
      });
      return;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // デスクトップでは何もしない
      return;
    }
    await _analytics.logEvent(
      name: '${pageName}_page_view',
      parameters: {'page': pageName},
    );
  }

  Future<void> logButtonClick(String pageName, String buttonName) async {
    if (kIsWeb) {
      Future.microtask(() async {
        await _analytics.logEvent(
          name: '${pageName}_button_click',
          parameters: {'button_name': buttonName},
        );
      });
      return;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // デスクトップでは何もしない
      return;
    }
    await _analytics.logEvent(
      name: '${pageName}_button_click',
      parameters: {'button_name': buttonName},
    );
  }
}
