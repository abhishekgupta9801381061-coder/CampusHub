import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Primaries
  static const Color primary = Color(0xFF0F172A); // Midnight Slate
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color accent = Color(0xFF4F46E5); // Indigo
  static const Color accentBlue = Color(0xFF2563EB); // Royal Blue

  // Neutrals (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate-50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0); // Slate-200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate-900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate-500
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate-400
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Neutrals (Dark Mode)
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF131B2E);
  static const Color cardBorderDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color dividerDark = Color(0xFF1E293B);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Feature Tints
  static const Color securityCardBg = Color(0xFFF0F7FF);
  static const Color securityCardBorder = Color(0xFFBAE6FD);
  static const Color ghostMode = Color(0xFF8B5CF6);
  static const Color ghostModeBg = Color(0xFFF5F3FF);
  static const Color tagBgLight = Color(0xFFEEF2F6);
  static const Color tagTextLight = Color(0xFF334155);
}
