import 'package:flutter/material.dart';

/// Central color palette for Bachat Karo.
/// All UI elements must reference these — no hardcoded hex values elsewhere.
abstract class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0D3D35);
  static const Color primaryLight = Color(0xFF1A5C4F);
  static const Color primarySurface = Color(0xFFE8F5F2);

  // ── Accent ─────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF7B2D2D);
  static const Color accentLight = Color(0xFFF5EDEB);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color spendLow = Color(0xFF0D3D35);
  static const Color spendHigh = Color(0xFFB94040);
  static const Color spendNone = Color(0xFFCCCCCC);

  static const Color success = Color(0xFF2D7A5E);
  static const Color warning = Color(0xFFE07B39);
  static const Color error = Color(0xFFB94040);

  // ── Neutral ────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F3EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EEE9);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFFAAAAAA);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2DED6);
  static const Color divider = Color(0xFFEBE8E2);

  // ── Category backgrounds ───────────────────────────────────────────────────
  static const Color catFood = Color(0xFFD6EDE8);
  static const Color catTravel = Color(0xFF0D3D35);
  static const Color catShopping = Color(0xFF7B2D2D);
  static const Color catBills = Color(0xFFE8E0D5);
  static const Color catOthers = Color(0xFFF0EEE9);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME  — inspired by the in-app design screenshots
  //
  // Background:    #141920  (deep navy-charcoal — app bg in all screens)
  // Surface:       #1D2535  (card bg — slightly lifted from bg)
  // SurfaceVariant:#252E42  (input fields, chip backgrounds)
  // Primary:       #2DCAAA  (teal — buttons, active nav, spend dots, highlights)
  // PrimaryHero:   #1A4A4A  (dark teal — "Daily Summary" style card bg)
  // Accent:        #39A7D6  (sky blue — secondary highlights)
  // TextPrimary:   #E8EDF8  (near-white)
  // TextSecondary: #8594B0  (muted blue-grey)
  // Border:        #2C3550
  // Divider:       #242D42
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFF2DCAAA);       // Teal
  static const Color darkPrimaryLight = Color(0xFF3AD9B8);
  static const Color darkPrimarySurface = Color(0xFF1A4A4A); // Dark teal (hero cards)

  // ── Accent ─────────────────────────────────────────────────────────────────
  static const Color darkAccent = Color(0xFF39A7D6);        // Sky blue
  static const Color darkAccentLight = Color(0xFF152636);   // Dark blue tint bg

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color darkSpendLow = Color(0xFF2DCAAA);      // Teal dot (essentials)
  static const Color darkSpendMid = Color(0xFF39A7D6);      // Blue dot (wealth)
  static const Color darkSpendHigh = Color(0xFFE05C5C);     // Red dot (excess)
  static const Color darkSpendNone = Color(0xFF3A4560);     // Muted dot

  static const Color darkSuccess = Color(0xFF2DCAAA);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkError = Color(0xFFE05C5C);

  // ── Neutral ────────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF141920);    // Deep navy-charcoal
  static const Color darkSurface = Color(0xFF1D2535);       // Card surface
  static const Color darkSurfaceVariant = Color(0xFF252E42); // Input/chip bg

  static const Color darkTextPrimary = Color(0xFFE8EDF8);   // Near-white
  static const Color darkTextSecondary = Color(0xFF8594B0); // Muted blue-grey
  static const Color darkTextDisabled = Color(0xFF4A5570);
  static const Color darkTextOnPrimary = Color(0xFF0A1A18); // Text ON teal button

  static const Color darkBorder = Color(0xFF2C3550);
  static const Color darkDivider = Color(0xFF242D42);

  // ── Category backgrounds (dark) ────────────────────────────────────────────
  static const Color darkCatFood = Color(0xFF1E3528);
  static const Color darkCatTravel = Color(0xFF1A4A4A);
  static const Color darkCatShopping = Color(0xFF3A2035);
  static const Color darkCatBills = Color(0xFF252B3A);
  static const Color darkCatOthers = Color(0xFF252E42);
}
