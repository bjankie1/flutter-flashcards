import 'package:flutter/material.dart';

/// Data class containing layout constraints and responsive properties
class LayoutConstraintsData {
  final BoxConstraints constraints;
  final bool isMobile;

  const LayoutConstraintsData({
    required this.constraints,
    required this.isMobile,
  });

  /// Get the maximum width available
  double get maxWidth => constraints.maxWidth;

  /// Get the maximum height available
  double get maxHeight => constraints.maxHeight;

  /// Check if the screen is wide (desktop/tablet)
  bool get isWide => !isMobile;

  /// Check if the screen is narrow (mobile)
  bool get isNarrow => isMobile;

  /// Get responsive breakpoint for mobile (600px)
  static const double mobileBreakpoint = 600.0;

  /// Get responsive breakpoint for tablet (900px)
  static const double tabletBreakpoint = 900.0;

  /// Check if width is above a specific breakpoint
  bool isAboveBreakpoint(double breakpoint) => maxWidth > breakpoint;

  /// Check if width is below a specific breakpoint
  bool isBelowBreakpoint(double breakpoint) => maxWidth <= breakpoint;
}

/// InheritedWidget that provides layout constraints and responsive properties
/// to all child widgets in the widget tree.
class LayoutConstraints extends InheritedWidget {
  final LayoutConstraintsData data;

  const LayoutConstraints({
    super.key,
    required this.data,
    required super.child,
  });

  /// Get the layout constraints data from the nearest LayoutConstraints widget
  static LayoutConstraintsData of(BuildContext context) {
    final LayoutConstraints? result = context
        .dependOnInheritedWidgetOfExactType<LayoutConstraints>();
    assert(result != null, 'No LayoutConstraints found in context');
    return result!.data;
  }

  /// Get the layout constraints data from the nearest LayoutConstraints widget
  /// without registering a dependency
  static LayoutConstraintsData? maybeOf(BuildContext context) {
    final LayoutConstraints? result = context
        .getInheritedWidgetOfExactType<LayoutConstraints>();
    return result?.data;
  }

  @override
  bool updateShouldNotify(LayoutConstraints oldWidget) {
    return data.constraints != oldWidget.data.constraints ||
        data.isMobile != oldWidget.data.isMobile;
  }
}

/// Extension methods for easier access to layout constraints
extension LayoutConstraintsExtension on BuildContext {
  /// Get the layout constraints data
  LayoutConstraintsData get layoutConstraints => LayoutConstraints.of(this);

  /// Check if the current screen is mobile (from layout constraints)
  bool get isMobileLayout => layoutConstraints.isMobile;

  /// Check if the current screen is wide (desktop/tablet)
  bool get isWideLayout => layoutConstraints.isWide;

  /// Get the maximum width available
  double get layoutMaxWidth => layoutConstraints.maxWidth;

  /// Get the maximum height available
  double get layoutMaxHeight => layoutConstraints.maxHeight;

  /// Check if width is above mobile breakpoint (600px)
  bool get isAboveMobileBreakpoint => layoutConstraints.isAboveBreakpoint(
    LayoutConstraintsData.mobileBreakpoint,
  );

  /// Check if width is above tablet breakpoint (900px)
  bool get isAboveTabletBreakpoint => layoutConstraints.isAboveBreakpoint(
    LayoutConstraintsData.tabletBreakpoint,
  );
}
