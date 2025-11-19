import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsServices {
  // Singleton化
  static final AnalyticsServices _instance = AnalyticsServices._internal();
  factory AnalyticsServices() => _instance;
  AnalyticsServices._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logPageView(String pageName) async {
    await _analytics.logEvent(
      name: '${pageName}_page_view',
      parameters: {'page': pageName},
    );
  }

  Future<void> logButtonClick(String pageName, String buttonName) async {
    await _analytics.logEvent(
      name: '${pageName}_button_click',
      parameters: {'button_name': buttonName},
    );
  }
}
