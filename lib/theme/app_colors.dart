import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color lightBackground = Color(0xFFF5F3FF);
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF1F1F1F);

  // Gradient colors for header (light mode)
  static List<Color> headerGradientLight = [
    Colors.purple.shade600,
    Colors.blue.shade600,
  ];

  // Gradient colors for header (dark mode)
  static List<Color> headerGradientDark = [
    Colors.purple.shade900,
    Colors.blue.shade900,
  ];

  // Gradient colors for quick study button (light mode)
  static List<Color> quickStudyGradientLight = [
    Colors.purple.shade600,
    Colors.blue.shade600,
    Colors.pink.shade600,
  ];

  // Gradient colors for quick study button (dark mode)
  static List<Color> quickStudyGradientDark = [
    Colors.purple.shade700,
    Colors.blue.shade700,
    Colors.pink.shade700,
  ];

  // Gradient colors for AI Import button (light mode)
  static List<Color> aiImportGradientLight = [
    Colors.pink.shade600,
    Colors.purple.shade600,
  ];

  // Gradient colors for AI Import button (dark mode)
  static List<Color> aiImportGradientDark = [
    Colors.pink.shade700,
    Colors.purple.shade700,
  ];

  // Stat icon colors
  static Color streakIconColor = Colors.orange.shade300;
  static Color dueIconColor = Colors.blue.shade300;
  static Color decksIconColor = Colors.pink.shade300;
}
