import 'package:flutter/material.dart';

/// Modern design system for the todo module
class TodoDesignSystem {
  // Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color secondaryPurple = Color(0xFF7C3AED);

  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  static const Color neutralGray50 = Color(0xFFF9FAFB);
  static const Color neutralGray100 = Color(0xFFF3F4F6);
  static const Color neutralGray200 = Color(0xFFE5E7EB);
  static const Color neutralGray300 = Color(0xFFD1D5DB);
  static const Color neutralGray400 = Color(0xFF9CA3AF);
  static const Color neutralGray500 = Color(0xFF6B7280);
  static const Color neutralGray600 = Color(0xFF4B5563);
  static const Color neutralGray700 = Color(0xFF374151);
  static const Color neutralGray800 = Color(0xFF1F2937);
  static const Color neutralGray900 = Color(0xFF111827);

  // Priority Colors
  static const Color priorityHigh = errorRed;
  static const Color priorityMedium = warningOrange;
  static const Color priorityLow = successGreen;

  // Status Colors
  static const Color statusTodo = neutralGray400;
  static const Color statusInProgress = primaryBlue;
  static const Color statusDone = successGreen;

  // Spacing
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Shadows
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 25,
      offset: const Offset(0, 8),
    ),
  ];

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveBounce = Curves.bounceOut;

  // Typography
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static TextStyle get headingSmall =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get bodyLarge =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, height: 1.5);

  static TextStyle get bodyMedium =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, height: 1.5);

  static TextStyle get bodySmall =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, height: 1.4);

  static TextStyle get labelLarge =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelMedium =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelSmall =>
      const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, height: 1.4);

  // Helper methods for priority colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return neutralGray400;
    }
  }

  // Helper methods for status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return statusTodo;
      case 'inprogress':
      case 'in progress':
        return statusInProgress;
      case 'done':
        return statusDone;
      default:
        return neutralGray400;
    }
  }
}
