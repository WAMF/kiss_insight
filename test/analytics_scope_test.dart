import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiss_insight/src/analytics.dart';
import 'package:kiss_insight/src/in_memory_analytics.dart';

void main() {
  group('AnalyticsScope', () {
    late InMemoryAnalytics analytics;

    setUp(() {
      analytics = InMemoryAnalytics();
    });

    testWidgets('should provide analytics through context', (tester) async {
      Analytics? capturedAnalytics;

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScope(
            analytics: analytics,
            child: Builder(
              builder: (context) {
                capturedAnalytics = AnalyticsScope.of(context).analytics;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedAnalytics, equals(analytics));
    });

    testWidgets('should provide analytics through maybeOf', (tester) async {
      AnalyticsScope? capturedScope;

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScope(
            analytics: analytics,
            child: Builder(
              builder: (context) {
                capturedScope = AnalyticsScope.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedScope, isNotNull);
      expect(capturedScope!.analytics, equals(analytics));
    });

    testWidgets('maybeOf should return null when no scope', (tester) async {
      AnalyticsScope? capturedScope;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedScope = AnalyticsScope.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedScope, isNull);
    });

    testWidgets('of should throw when no scope', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => AnalyticsScope.of(context),
                throwsA(isA<TypeError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should notify when analytics changes', (tester) async {
      final analytics1 = InMemoryAnalytics();
      final analytics2 = InMemoryAnalytics();
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScope(
            analytics: analytics1,
            child: Builder(
              builder: (context) {
                AnalyticsScope.of(context);
                buildCount++;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(buildCount, equals(1));

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScope(
            analytics: analytics2,
            child: Builder(
              builder: (context) {
                AnalyticsScope.of(context);
                buildCount++;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(buildCount, equals(2));
    });

    testWidgets('should not notify when analytics stays same', (tester) async {
      var buildCount = 0;

      final widget = MaterialApp(
        home: AnalyticsScope(
          analytics: analytics,
          child: Builder(
            builder: (context) {
              AnalyticsScope.of(context);
              buildCount++;
              return Container(key: ValueKey(buildCount));
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(buildCount, equals(1));

      await tester.pumpWidget(widget);
      expect(buildCount, equals(1));
    });

    testWidgets('should allow logging through scope', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScope(
            analytics: analytics,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await AnalyticsScope.of(context)
                        .analytics
                        .logAction('button_tap');
                  },
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(analytics.eventCount, equals(1));
      expect(analytics.events.first.name, equals('button_tap_action'));
    });

    testWidgets('nested scopes should use closest scope', (tester) async {
      final outerAnalytics = InMemoryAnalytics();
      final innerAnalytics = InMemoryAnalytics();
      Analytics? capturedAnalytics;

      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScope(
            analytics: outerAnalytics,
            child: AnalyticsScope(
              analytics: innerAnalytics,
              child: Builder(
                builder: (context) {
                  capturedAnalytics = AnalyticsScope.of(context).analytics;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedAnalytics, equals(innerAnalytics));
      expect(capturedAnalytics, isNot(equals(outerAnalytics)));
    });
  });
}
