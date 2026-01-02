import 'package:flutter_test/flutter_test.dart';
import 'package:kiss_insight/src/analytics.dart';
import 'package:kiss_insight/src/in_memory_analytics.dart';

void main() {
  group('InMemoryAnalytics', () {
    late InMemoryAnalytics analytics;

    setUp(() {
      analytics = InMemoryAnalytics();
    });

    test('should start with no events', () {
      expect(analytics.events, isEmpty);
      expect(analytics.eventCount, equals(0));
    });

    test('should log events', () async {
      const eventName = 'test_event';
      const parameters = {'key': 'value', 'count': 42};

      await analytics.logEvent(eventName, parameters);

      expect(analytics.eventCount, equals(1));
      expect(analytics.events.first.name, equals(eventName));
      expect(analytics.events.first.parameters, equals(parameters));
    });

    test('should log multiple events', () async {
      await analytics.logEvent('event1', {'a': '1'});
      await analytics.logEvent('event2', {'b': '2'});
      await analytics.logEvent('event3', {'c': '3'});

      expect(analytics.eventCount, equals(3));
      expect(analytics.events[0].name, equals('event1'));
      expect(analytics.events[1].name, equals('event2'));
      expect(analytics.events[2].name, equals('event3'));
    });

    test('should clear events', () async {
      await analytics.logEvent('event1', {});
      await analytics.logEvent('event2', {});

      expect(analytics.eventCount, equals(2));

      analytics.clear();

      expect(analytics.eventCount, equals(0));
      expect(analytics.events, isEmpty);
    });

    test('should get events by name', () async {
      await analytics.logEvent('event_a', {'type': 'a'});
      await analytics.logEvent('event_b', {'type': 'b'});
      await analytics.logEvent('event_a', {'type': 'a2'});

      final eventsA = analytics.getEventsByName('event_a');

      expect(eventsA.length, equals(2));
      expect(eventsA[0].name, equals('event_a'));
      expect(eventsA[1].name, equals('event_a'));
    });

    test('should check if event exists', () async {
      await analytics.logEvent('existing_event', {});

      expect(analytics.hasEvent('existing_event'), isTrue);
      expect(analytics.hasEvent('non_existing_event'), isFalse);
    });

    test('should check if event with parameters exists', () async {
      const parameters = {'key': 'value', 'number': 123};
      await analytics.logEvent('test_event', parameters);

      expect(
        analytics.hasEventWithParameters('test_event', parameters),
        isTrue,
      );
      expect(
        analytics.hasEventWithParameters('test_event', {'key': 'value'}),
        isFalse,
      );
      expect(
        analytics.hasEventWithParameters('other_event', parameters),
        isFalse,
      );
    });

    test('should return unmodifiable list of events', () {
      expect(
        () => analytics.events.add(
          AnalyticsEvent(
            name: 'test',
            parameters: const {},
            timestamp: DateTime(2024),
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('should store event timestamp', () async {
      final before = DateTime.now();
      await analytics.logEvent('test_event', {});
      final after = DateTime.now();

      final event = analytics.events.first;
      final isAfterOrAt =
          event.timestamp.isAfter(before) ||
          event.timestamp.isAtSameMomentAs(before);
      final isBeforeOrAt =
          event.timestamp.isBefore(after) ||
          event.timestamp.isAtSameMomentAs(after);
      expect(isAfterOrAt, isTrue);
      expect(isBeforeOrAt, isTrue);
    });

    group('logImpression', () {
      test('should log impression event', () async {
        const name = 'button';
        const visibleFraction = 0.75;
        const info = {'screen': 'home', 'position': 'top'};

        await analytics.logImpression(
          name,
          visibleFraction: visibleFraction,
          info: info,
        );

        expect(analytics.eventCount, equals(1));
        final event = analytics.events.first;
        expect(event.name, equals('button_impression'));
        expect(
          event.parameters[AnalyticsFields.type.name],
          equals('impression'),
        );
        expect(
          event.parameters[AnalyticsFields.visibleFraction.name],
          equals(visibleFraction),
        );
        expect(event.parameters['screen'], equals('home'));
        expect(event.parameters['position'], equals('top'));
      });

      test('should log impression without optional parameters', () async {
        await analytics.logImpression('widget');

        expect(analytics.eventCount, equals(1));
        final event = analytics.events.first;
        expect(event.name, equals('widget_impression'));
        expect(
          event.parameters[AnalyticsFields.type.name],
          equals('impression'),
        );
        expect(
          event.parameters.containsKey(AnalyticsFields.visibleFraction.name),
          isFalse,
        );
      });
    });

    group('logIntent', () {
      test('should log intent event', () async {
        const name = 'purchase';
        const info = {'product': 'premium', 'source': 'banner'};

        await analytics.logIntent(name, info: info);

        expect(analytics.eventCount, equals(1));
        final event = analytics.events.first;
        expect(event.name, equals('purchase_intent'));
        expect(event.parameters[AnalyticsFields.type.name], equals('intent'));
        expect(event.parameters['product'], equals('premium'));
        expect(event.parameters['source'], equals('banner'));
      });

      test('should log intent without info', () async {
        await analytics.logIntent('subscribe');

        expect(analytics.eventCount, equals(1));
        final event = analytics.events.first;
        expect(event.name, equals('subscribe_intent'));
        expect(event.parameters[AnalyticsFields.type.name], equals('intent'));
        expect(event.parameters.length, equals(1));
      });
    });

    group('logAction', () {
      test('should log action event', () async {
        const name = 'payment';
        const info = {'method': 'card', 'amount': '9.99'};

        await analytics.logAction(name, info: info);

        expect(analytics.eventCount, equals(1));
        final event = analytics.events.first;
        expect(event.name, equals('payment_action'));
        expect(event.parameters[AnalyticsFields.type.name], equals('action'));
        expect(event.parameters['method'], equals('card'));
        expect(event.parameters['amount'], equals('9.99'));
        expect(
          event.parameters.containsKey(AnalyticsFields.error.name),
          isFalse,
        );
      });

      test('should log action with error', () async {
        const name = 'payment';
        const error = 'Card declined';

        await analytics.logAction(name, error: error);

        expect(analytics.eventCount, equals(1));
        final event = analytics.events.first;
        expect(event.name, equals('payment_action'));
        expect(event.parameters[AnalyticsFields.type.name], equals('action'));
        expect(event.parameters[AnalyticsFields.error.name], equals(error));
      });

      test('should log action with both info and error', () async {
        await analytics.logAction(
          'checkout',
          info: {'cart_size': '3'},
          error: 'Network timeout',
        );

        final event = analytics.events.first;
        expect(event.parameters['cart_size'], equals('3'));
        expect(
          event.parameters[AnalyticsFields.error.name],
          equals('Network timeout'),
        );
      });
    });

    group('getEventsByType', () {
      test('should filter events by type', () async {
        await analytics.logImpression('banner');
        await analytics.logIntent('purchase');
        await analytics.logAction('click');
        await analytics.logImpression('footer');

        final impressions =
            analytics.getEventsByType(AnalyticsEventType.impression);
        final intents = analytics.getEventsByType(AnalyticsEventType.intent);
        final actions = analytics.getEventsByType(AnalyticsEventType.action);

        expect(impressions.length, equals(2));
        expect(intents.length, equals(1));
        expect(actions.length, equals(1));

        expect(impressions[0].name, equals('banner_impression'));
        expect(impressions[1].name, equals('footer_impression'));
        expect(intents[0].name, equals('purchase_intent'));
        expect(actions[0].name, equals('click_action'));
      });
    });

    group('AnalyticsEvent equality', () {
      test('should be equal for same name and parameters', () {
        final timestamp = DateTime(2024);
        final event1 = AnalyticsEvent(
          name: 'test',
          parameters: const {'a': '1', 'b': 2},
          timestamp: timestamp,
        );
        final event2 = AnalyticsEvent(
          name: 'test',
          parameters: const {'a': '1', 'b': 2},
          timestamp: timestamp,
        );

        expect(event1, equals(event2));
      });

      test('should not be equal for different names', () {
        final timestamp = DateTime(2024);
        final event1 = AnalyticsEvent(
          name: 'test1',
          parameters: const {'a': '1'},
          timestamp: timestamp,
        );
        final event2 = AnalyticsEvent(
          name: 'test2',
          parameters: const {'a': '1'},
          timestamp: timestamp,
        );

        expect(event1, isNot(equals(event2)));
      });

      test('should not be equal for different parameters', () {
        final timestamp = DateTime(2024);
        final event1 = AnalyticsEvent(
          name: 'test',
          parameters: const {'a': '1'},
          timestamp: timestamp,
        );
        final event2 = AnalyticsEvent(
          name: 'test',
          parameters: const {'a': '2'},
          timestamp: timestamp,
        );

        expect(event1, isNot(equals(event2)));
      });
    });
  });
}
