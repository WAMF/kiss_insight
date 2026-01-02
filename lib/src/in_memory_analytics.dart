import 'package:flutter/foundation.dart';
import 'package:kiss_insight/src/analytics.dart';

/// Represents a single analytics event with its metadata.
@immutable
class AnalyticsEvent {
  /// Creates an analytics event with the given name, parameters, and timestamp.
  const AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });

  /// The name of the event.
  final String name;

  /// The parameters associated with the event.
  final Map<String, Object> parameters;

  /// When the event was logged.
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsEvent &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          _mapsEqual(parameters, other.parameters);

  @override
  int get hashCode => name.hashCode ^ parameters.hashCode;

  static bool _mapsEqual(Map<String, Object> a, Map<String, Object> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// An in-memory implementation of Analytics for testing purposes.
class InMemoryAnalytics extends Analytics {
  final List<AnalyticsEvent> _events = [];

  /// Returns an unmodifiable list of all logged events.
  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    _events.add(
      AnalyticsEvent(
        name: name,
        parameters: Map.unmodifiable(parameters),
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Clears all logged events.
  void clear() {
    _events.clear();
  }

  /// Returns all events matching the given name.
  List<AnalyticsEvent> getEventsByName(String name) {
    return _events.where((event) => event.name == name).toList();
  }

  /// Returns all events matching the given type.
  List<AnalyticsEvent> getEventsByType(AnalyticsEventType type) {
    return _events
        .where(
          (event) => event.parameters[AnalyticsFields.type.name] == type.name,
        )
        .toList();
  }

  /// Returns true if an event with the given name exists.
  bool hasEvent(String name) {
    return _events.any((event) => event.name == name);
  }

  /// Returns true if an event with the given name and parameters exists.
  bool hasEventWithParameters(String name, Map<String, Object> parameters) {
    return _events.any(
      (event) =>
          event.name == name &&
          AnalyticsEvent._mapsEqual(event.parameters, parameters),
    );
  }

  /// Returns the total number of logged events.
  int get eventCount => _events.length;
}
