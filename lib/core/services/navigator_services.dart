import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigatorServices extends NavigatorObserver {
  final List<Route<dynamic>> _stack = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    _stack.add(route);
    _printStack();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _stack.remove(route);
    _printStack();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _stack.remove(route);
    _printStack();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _stack.remove(oldRoute);
    if (newRoute != null) _stack.add(newRoute);
    _printStack();
  }

  void _printStack() {
    debugPrint('--- Navigator Stack ---');
    for (var r in _stack) {
      debugPrint(' • ${r.settings.name}');
    }
    debugPrint('------------------------');
  }

  static void handleNavigation(BuildContext context, String targetRoute) {
    context.go(targetRoute);
  }
}
