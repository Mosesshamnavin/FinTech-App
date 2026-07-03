import 'package:flutter/material.dart';

/// Extension on BuildContext to easily access themed colors throughout the app.
/// Use these instead of hardcoded Colors.xxx to ensure the selected theme applies.
extension AppColors on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  // ── Primary ────────────────────────────────────────────────────────────────
  Color get primary => cs.primary;
  Color get onPrimary => cs.onPrimary;
  Color get primaryContainer => cs.primaryContainer;

  // ── Semantic: Success / Paid ───────────────────────────────────────────────
  /// Use for "paid", "success", "active" states
  Color get success => Colors.green.shade600;
  Color get successLight => Colors.green.shade100;
  Color get successDark => Colors.green.shade800;

  // ── Semantic: Error / Danger ───────────────────────────────────────────────
  /// Use for errors, "CLEAR" buttons, outstanding balances
  Color get danger => cs.error;
  Color get dangerLight => cs.errorContainer;

  // ── Semantic: Warning ──────────────────────────────────────────────────────
  /// Use for warnings, "Pending" states, overdue
  Color get warning => Colors.orange.shade700;
  Color get warningLight => Colors.orange.shade100;

  // ── Semantic: Info / Accent ────────────────────────────────────────────────
  /// Use for calendar icons, filters, tabs — replaces hardcoded lightBlue
  Color get accent => cs.primary;
  Color get accentLight => cs.primaryContainer;

  // ── Surface & Background ───────────────────────────────────────────────────
  Color get surface => cs.surface;
  Color get onSurface => cs.onSurface;
  Color get surfaceVariant => cs.surfaceContainerHighest;

  // ── Text ───────────────────────────────────────────────────────────────────
  Color get textPrimary => cs.onSurface;
  Color get textSecondary => cs.onSurface.withAlpha(153); // ~60% opacity
  Color get textMuted => cs.onSurface.withAlpha(102);    // ~40% opacity
}
