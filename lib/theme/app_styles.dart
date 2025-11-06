import 'package:flutter/material.dart';

class AppStyles {
  // Text styles
  static const TextStyle headerTitle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headerSubtitle = TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: 14,
  );

  static TextStyle sectionTitle(bool isDark) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      );

  static const TextStyle quickStudyTitle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle quickStudySubtitle = TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: 12,
  );

  static TextStyle emptyStateTitle(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      );

  static TextStyle emptyStateSubtitle(bool isDark) => TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      );

  // Spacing
  static const double defaultPadding = 24.0;
  static const double sectionSpacing = 12.0;
  static const double cardSpacing = 12.0;
  static const double borderRadius = 12.0;
  static const double headerBorderRadius = 24.0;

  // Button styles
  static ButtonStyle purpleButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.purple,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}
