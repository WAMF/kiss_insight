import 'package:flutter/widgets.dart';

/// Types of analytics events that can be tracked.
enum AnalyticsEventType {
  /// User viewed a component.
  impression,

  /// User initiated an interaction (e.g. button tap, form submission attempt).
  intent,

  /// An operation completed with a result (success or failure).
  action,
}

/// Field keys used in analytics event parameters.
enum AnalyticsFields {
  /// Fraction of component visible on screen.
  visibleFraction,

  /// Additional information about the event.
  info,

  /// Error message if the action failed.
  error,

  /// Type of the analytics event.
  type,
}

/// Abstract class for logging analytics events.
abstract class Analytics {
  /// Logs a generic event with the given name and parameters.
  Future<void> logEvent(String name, Map<String, Object> parameters);

  /// Logs an impression event when a component becomes visible.
  Future<void> logImpression(
    String name, {
    double? visibleFraction,
    Map<String, String>? info,
  }) {
    return logEvent('${name}_${AnalyticsEventType.impression.name}', {
      AnalyticsFields.type.name: AnalyticsEventType.impression.name,
      if (visibleFraction != null)
        AnalyticsFields.visibleFraction.name: visibleFraction,
      ...?info,
    });
  }

  /// Logs an intent event when a user initiates an interaction.
  ///
  /// Use this for user-triggered actions like button taps or form submissions.
  Future<void> logIntent(String name, {Map<String, String>? info}) {
    return logEvent('${name}_${AnalyticsEventType.intent.name}', {
      AnalyticsFields.type.name: AnalyticsEventType.intent.name,
      ...?info,
    });
  }

  /// Logs an action event when an operation completes.
  ///
  /// Use this for results of operations, with optional [error] for failures.
  Future<void> logAction(
    String name, {
    Map<String, String>? info,
    String? error,
  }) {
    return logEvent('${name}_${AnalyticsEventType.action.name}', {
      AnalyticsFields.type.name: AnalyticsEventType.action.name,
      if (error != null) AnalyticsFields.error.name: error,
      ...?info,
    });
  }
}

/// Provides analytics instance to descendant widgets.
class AnalyticsScope extends InheritedWidget {
  /// Creates an analytics scope with the given analytics instance.
  const AnalyticsScope({
    required this.analytics,
    required super.child,
    super.key,
  });

  /// The analytics instance provided to descendants.
  final Analytics analytics;

  @override
  bool updateShouldNotify(AnalyticsScope oldWidget) {
    return oldWidget.analytics != analytics;
  }

  /// Returns the nearest AnalyticsScope ancestor.
  static AnalyticsScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnalyticsScope>()!;
  }

  /// Returns the nearest AnalyticsScope ancestor, or null if none exists.
  static AnalyticsScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnalyticsScope>();
  }
}
