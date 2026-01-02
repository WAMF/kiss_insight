import 'package:flutter/widgets.dart';
import 'package:kiss_insight/kiss_insight.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A widget that tracks visibility impressions for analytics.
///
/// Wraps a child widget and automatically logs an impression event
/// when the widget becomes visible on screen.
///
/// Requires an [AnalyticsScope] ancestor in the widget tree.
class TrackImpression extends StatelessWidget {
  /// Creates a TrackImpression widget.
  const TrackImpression({
    required this.child,
    required this.name,
    this.info,
    super.key,
  });

  /// The child widget to track impressions for.
  final Widget child;

  /// The name of the impression event.
  final String name;

  /// Additional information to include with the event.
  final Map<String, String>? info;

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsScope.maybeOf(context)?.analytics;
    assert(analytics != null, 'AnalyticsScope not found in context');
    if (analytics == null) {
      return child;
    }
    return VisibilityDetector(
      key: ValueKey(name),
      onVisibilityChanged: (visibilityInfo) =>
          _onVisibilityChanged(visibilityInfo, analytics),
      child: child,
    );
  }

  void _onVisibilityChanged(
    VisibilityInfo visibilityInfo,
    Analytics analytics,
  ) {
    if (visibilityInfo.visibleFraction > 0) {
      analytics.logImpression(
        name,
        visibleFraction: visibilityInfo.visibleFraction,
        info: info,
      );
    }
  }
}
