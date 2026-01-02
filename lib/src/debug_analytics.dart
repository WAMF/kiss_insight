import 'dart:developer' as developer;

import 'package:kiss_insight/src/analytics.dart';

/// An analytics implementation that logs events to the debug console.
///
/// Useful for development and debugging to see analytics events in real-time.
///
/// Example:
/// ```dart
/// final analytics = DebugAnalytics();
/// await analytics.logAction('button_tap', info: {'screen': 'home'});
/// // Prints: [Analytics] button_tap_action {type: action, screen: home}
/// ```
class DebugAnalytics extends Analytics {
  /// Creates a DebugAnalytics instance.
  ///
  /// If [prefix] is provided, it will be used instead of the default
  /// "[Analytics]" prefix in log output.
  DebugAnalytics({String? prefix}) : _prefix = prefix ?? _defaultPrefix;

  static const _defaultPrefix = '[Analytics]';
  final String _prefix;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    developer.log('$_prefix $name $parameters');
  }
}
