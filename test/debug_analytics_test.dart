import 'package:flutter_test/flutter_test.dart';
import 'package:kiss_insight/kiss_insight.dart';

void main() {
  group('DebugAnalytics', () {
    test('should create with default prefix', () async {
      final analytics = DebugAnalytics();

      await analytics.logEvent('test_event', const {'key': 'value'});
    });

    test('should create with custom prefix', () async {
      final analytics = DebugAnalytics(prefix: '[Custom]');

      await analytics.logEvent('test_event', const {'key': 'value'});
    });

    test('should log impression events', () async {
      final analytics = DebugAnalytics();

      await analytics.logImpression(
        'banner',
        visibleFraction: 0.8,
        info: const {'campaign': 'summer'},
      );
    });

    test('should log intent events', () async {
      final analytics = DebugAnalytics();

      await analytics.logIntent('purchase', info: const {'product': 'premium'});
    });

    test('should log action events', () async {
      final analytics = DebugAnalytics();

      await analytics.logAction('click', info: const {'button': 'submit'});
    });

    test('should log action events with error', () async {
      final analytics = DebugAnalytics();

      await analytics.logAction(
        'submit_form',
        error: 'Validation failed',
        info: const {'form': 'login'},
      );
    });
  });
}
