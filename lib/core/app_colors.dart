import 'package:flutter/material.dart';

class AppColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffold(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : const Color(0xFFF5F6FA);

  static Color card(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : Colors.black;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white70 : Colors.grey.shade600;

  static Color outline(BuildContext context) =>
      isDark(context) ? Colors.white24 : Colors.grey.shade300;

  static Color shadow(BuildContext context) =>
      isDark(context) ? Colors.black87 : Colors.black.withValues(alpha: 0.05);
}