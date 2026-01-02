# kiss_insight

A lightweight, provider-agnostic analytics interface for Flutter. Easily track impressions, intents, and actions with pluggable backends.

## Features

- **Provider-agnostic**: Define your analytics once, swap implementations easily
- **Semantic event types**: Built-in support for impressions, intents, and actions
- **Widget integration**: `AnalyticsScope` and `TrackImpression` for easy widget tree integration
- **Multiple backends**: `MultiAnalytics` to send events to multiple providers simultaneously
- **Debug support**: `DebugAnalytics` for development logging
- **Testing support**: `InMemoryAnalytics` for unit testing

## Installation

```yaml
dependencies:
  kiss_insight: ^0.0.1
```

## Usage

### Basic Setup

Wrap your app with `AnalyticsScope` to provide analytics throughout the widget tree:

```dart
import 'package:kiss_insight/kiss_insight.dart';

void main() {
  final analytics = DebugAnalytics();

  runApp(
    AnalyticsScope(
      analytics: analytics,
      child: MyApp(),
    ),
  );
}
```

### Logging Events

Access analytics from anywhere in the widget tree:

```dart
// Log an intent (user tapped a button)
AnalyticsScope.of(context).analytics.logIntent(
  'add_to_cart',
  info: {'product_id': '123'},
);

// Log an action (operation completed successfully)
AnalyticsScope.of(context).analytics.logAction(
  'purchase',
  info: {'product_id': '123', 'price': '9.99'},
);

// Log an action with error (operation failed)
AnalyticsScope.of(context).analytics.logAction(
  'purchase',
  error: 'Payment declined',
  info: {'product_id': '123'},
);

// Log an impression (user saw something)
AnalyticsScope.of(context).analytics.logImpression(
  'banner',
  visibleFraction: 0.8,
  info: {'campaign': 'summer_sale'},
);
```

### Automatic Impression Tracking

Use `TrackImpression` to automatically log when a widget becomes visible:

```dart
TrackImpression(
  name: 'product_card',
  info: {'product_id': '123'},
  child: ProductCard(product: product),
)
```

### Multiple Analytics Providers

Send events to multiple backends simultaneously:

```dart
final analytics = MultiAnalytics([
  FirebaseAnalyticsProvider(),  // Your Firebase implementation
  CustomBackendAnalytics(),     // Your custom backend
  DebugAnalytics(),             // Console logging in debug mode
]);
```

### Custom Implementation

Implement the `Analytics` interface for your preferred backend:

```dart
class MyAnalytics extends Analytics {
  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    // Send to your analytics backend
  }
}
```

### Testing

Use `InMemoryAnalytics` to capture and verify events in tests:

```dart
testWidgets('logs purchase action', (tester) async {
  final analytics = InMemoryAnalytics();

  await tester.pumpWidget(
    AnalyticsScope(
      analytics: analytics,
      child: MyPurchaseButton(),
    ),
  );

  await tester.tap(find.byType(MyPurchaseButton));

  expect(analytics.hasEvent('purchase_action'), isTrue);
  expect(analytics.eventCount, equals(1));
});
```

## Event Types

| Type | Method | Use Case |
|------|--------|----------|
| Impression | `logImpression()` | User viewed a component |
| Intent | `logIntent()` | User initiated an interaction (button tap, form submit) |
| Action | `logAction()` | Operation completed (success or failure with error) |

## Related Packages

- `kiss_insight_firebase` - Firebase Analytics implementation (coming soon)

## License

MIT License - see [LICENSE](LICENSE) for details.
