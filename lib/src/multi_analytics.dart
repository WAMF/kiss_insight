import 'package:kiss_insight/src/analytics.dart';

/// An analytics implementation that forwards events to multiple providers.
///
/// Useful for sending analytics to multiple destinations simultaneously,
/// such as Firebase Analytics and a custom backend.
///
/// Example:
/// ```dart
/// final analytics = MultiAnalytics([
///   FirebaseAnalyticsProvider(),
///   CustomBackendAnalytics(),
/// ]);
/// ```
class MultiAnalytics extends Analytics {
  /// Creates a MultiAnalytics instance with the given providers.
  MultiAnalytics(this._providers);

  final List<Analytics> _providers;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    await Future.wait(
      _providers.map((provider) => provider.logEvent(name, parameters)),
    );
  }
}
