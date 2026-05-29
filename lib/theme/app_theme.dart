import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'app_theme_2.dart';

// ============================================================
// CRM App Theme
// ============================================================

class AppColors {
  // Primary — Sky blue
  static const primary = Color(0xFF0284C7); // sky-600
  static const primaryLight = Color(0xFF0EA5E9); // sky-500
  static const primaryDark = Color(0xFF0369A1); // sky-700
  static const primarySurface = Color(0xFFE0F2FE); // sky-100

  // Slate scale
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  // Semantic colors
  static const success = Color(0xFF10B981); // emerald-500
  static const successLight = Color(0xFFD1FAE5); // emerald-100
  static const warning = Color(0xFFF59E0B); // amber-500
  static const warningLight = Color(0xFFFEF3C7); // amber-100
  static const error = Color(0xFFEF4444); // red-500
  static const errorLight = Color(0xFFFEE2E2); // red-100
  static const info = Color(0xFF3B82F6); // blue-500
  static const infoLight = Color(0xFFDBEAFE); // blue-100

  // Background
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceBorder = Color(0xFFE2E8F0);

  // Dark sidebar
  static const sidebarBg = Color(0xFF0F172A);
  static const sidebarBorder = Color(0xFF1E293B);
  static const sidebarText = Color(0xFF94A3B8);
  static const sidebarActiveText = Color(0xFFFFFFFF);
}

// Status color helpers
Color statusColor(String status) {
  switch (status) {
    case 'Active':
    case 'Done':
    case 'Completed':
    case 'Resolved':
    case 'On Track':
      return AppColors.success;
    case 'At Risk':
    case 'Review':
    case 'Waiting':
    case 'Waiting for Client':
      return AppColors.warning;
    case 'Critical':
    case 'Breached':
      return AppColors.error;
    case 'In Progress':
    case 'Assigned':
    case 'Open':
    case 'High':
      return AppColors.info;
    default:
      return AppColors.slate400;
  }
}

Color statusBgColor(String status) {
  switch (status) {
    case 'Active':
    case 'Done':
    case 'Completed':
    case 'Resolved':
    case 'On Track':
      return AppColors.successLight;
    case 'At Risk':
    case 'Review':
    case 'Waiting':
    case 'Waiting for Client':
      return AppColors.warningLight;
    case 'Critical':
    case 'Breached':
      return AppColors.errorLight;
    case 'In Progress':
    case 'Assigned':
    case 'Open':
    case 'High':
      return AppColors.infoLight;
    default:
      return AppColors.slate100;
  }
}

Color priorityColor(String priority) {
  switch (priority) {
    case 'Critical':
      return AppColors.error;
    case 'High':
      return AppColors.warning;
    case 'Medium':
      return AppColors.info;
    default:
      return AppColors.slate400;
  }
}
