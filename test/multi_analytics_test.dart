import 'package:flutter_test/flutter_test.dart';
import 'package:kiss_insight/kiss_insight.dart';

void main() {
  group('MultiAnalytics', () {
    test('should forward events to all providers', () async {
      final provider1 = InMemoryAnalytics();
      final provider2 = InMemoryAnalytics();
      final multi = MultiAnalytics([provider1, provider2]);

      await multi.logEvent('test_event', const {'key': 'value'});

      expect(provider1.eventCount, equals(1));
      expect(provider2.eventCount, equals(1));
      expect(provider1.events.first.name, equals('test_event'));
      expect(provider2.events.first.name, equals('test_event'));
    });

    test('should forward impression events to all providers', () async {
      final provider1 = InMemoryAnalytics();
      final provider2 = InMemoryAnalytics();
      final multi = MultiAnalytics([provider1, provider2]);

      await multi.logImpression('banner', visibleFraction: 0.5);

      expect(provider1.eventCount, equals(1));
      expect(provider2.eventCount, equals(1));
      expect(provider1.events.first.name, equals('banner_impression'));
      expect(provider2.events.first.name, equals('banner_impression'));
    });

    test('should forward intent events to all providers', () async {
      final provider1 = InMemoryAnalytics();
      final provider2 = InMemoryAnalytics();
      final multi = MultiAnalytics([provider1, provider2]);

      await multi.logIntent('purchase');

      expect(provider1.eventCount, equals(1));
      expect(provider2.eventCount, equals(1));
      expect(provider1.events.first.name, equals('purchase_intent'));
    });

    test('should forward action events to all providers', () async {
      final provider1 = InMemoryAnalytics();
      final provider2 = InMemoryAnalytics();
      final multi = MultiAnalytics([provider1, provider2]);

      await multi.logAction('click', info: const {'button': 'submit'});

      expect(provider1.eventCount, equals(1));
      expect(provider2.eventCount, equals(1));
      expect(provider1.events.first.name, equals('click_action'));
      expect(provider1.events.first.parameters['button'], equals('submit'));
    });

    test('should work with empty provider list', () async {
      final multi = MultiAnalytics([]);

      await multi.logEvent('test_event', const {});
    });

    test('should work with single provider', () async {
      final provider = InMemoryAnalytics();
      final multi = MultiAnalytics([provider]);

      await multi.logEvent('test_event', const {'key': 'value'});

      expect(provider.eventCount, equals(1));
    });

    test('should forward multiple events to all providers', () async {
      final provider1 = InMemoryAnalytics();
      final provider2 = InMemoryAnalytics();
      final multi = MultiAnalytics([provider1, provider2]);

      await multi.logAction('action1');
      await multi.logAction('action2');
      await multi.logAction('action3');

      expect(provider1.eventCount, equals(3));
      expect(provider2.eventCount, equals(3));
    });
  });
}
