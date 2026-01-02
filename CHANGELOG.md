## 0.0.1

- Initial release
- `Analytics` abstract class with `logEvent`, `logImpression`, `logIntent`, `logAction`
- `AnalyticsScope` InheritedWidget for widget tree integration
- `TrackImpression` widget for automatic visibility tracking
- `InMemoryAnalytics` for testing
- `DebugAnalytics` for console logging during development
- `MultiAnalytics` for sending events to multiple providers
