import 'package:flutter/material.dart';
import 'package:kiss_insight/kiss_insight.dart';

void main() {
  final analytics = DebugAnalytics();

  runApp(
    AnalyticsScope(
      analytics: analytics,
      child: const ExampleApp(),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('kiss_insight Example')),
        body: const ExampleScreen(),
      ),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsScope.of(context).analytics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TrackImpression(
          name: 'welcome_banner',
          info: {'variant': 'A'},
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Welcome! This impression is tracked.'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            analytics.logIntent(
              'purchase_button',
              info: const {'product': 'premium'},
            );

            Future.delayed(const Duration(seconds: 1), () {
              analytics.logAction(
                'purchase',
                info: const {'product': 'premium'},
              );
            });
          },
          child: const Text('Purchase (Intent + Action)'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            analytics.logIntent(
              'purchase_button',
              info: const {'product': 'basic'},
            );

            Future.delayed(const Duration(seconds: 1), () {
              analytics.logAction(
                'purchase',
                error: 'Payment declined',
                info: const {'product': 'basic'},
              );
            });
          },
          child: const Text('Purchase (Intent + Failed Action)'),
        ),
      ],
    );
  }
}
