import 'package:flutter/material.dart';

import 'design_system.dart';

class Breakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;
  static const double desktop = 1200;
}

class ResponsiveSpacing {
  static double getSpacing(
    BuildContext context, {
    double mobile = TodoDesignSystem.spacing16,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= Breakpoints.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  static EdgeInsets getPadding(
    BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(TodoDesignSystem.spacing16),
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= Breakpoints.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding:
            padding ??
            ResponsiveSpacing.getPadding(
              context,
              mobile: const EdgeInsets.all(TodoDesignSystem.spacing16),
              tablet: const EdgeInsets.all(TodoDesignSystem.spacing24),
              desktop: const EdgeInsets.all(TodoDesignSystem.spacing32),
            ),
        child: child,
      ),
    );
  }
}

class ResponsiveBottomSheet extends StatelessWidget {
  const ResponsiveBottomSheet({
    super.key,
    required this.child,
    this.maxWidth = 600,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= Breakpoints.tablet;

    if (isWideScreen) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TodoDesignSystem.radiusXLarge),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: child,
        ),
      );
    }

    return child;
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double maxWidth = 600,
    bool isScrollControlled = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= Breakpoints.tablet;

    if (isWideScreen) {
      return showDialog<T>(
        context: context,
        builder: (context) =>
            ResponsiveBottomSheet(maxWidth: maxWidth, child: child),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }
}
