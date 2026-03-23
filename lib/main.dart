import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/state/app_state.dart';
import 'core/supabase/supabase_config.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/expense/data/expense_repository.dart';
import 'features/account/data/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  final client = Supabase.instance.client;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(
        authRepo:    AuthRepository(client),
        expenseRepo: ExpenseRepository(client),
        userRepo:    UserRepository(client),
      ),
      child: const BachatKaroApp(),
    ),
  );
}

class BachatKaroApp extends StatelessWidget {
  const BachatKaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppState, ThemeMode>(
      (s) => s.themeMode,
    );

    // Update system UI overlay based on theme
    SystemChrome.setSystemUIOverlayStyle(
      themeMode == ThemeMode.dark
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
    );

    return MaterialApp(
      title: 'Bachat Karo',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const AuthGate(),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF0D3D35);
    const background = Color(0xFFF5F3EE);
    const surface = Color(0xFFFFFFFF);
    const surfaceVariant = Color(0xFFF0EEE9);
    const textPrimary = Color(0xFF1A1A1A);
    const border = Color(0xFFE2DED6);
    const divider = Color(0xFFEBE8E2);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: surface,
        onPrimary: Color(0xFFFFFFFF),
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  // Palette extracted from the in-app design screenshots:
  //   Background   #141920  deep navy-charcoal
  //   Surface      #1D2535  lifted card bg
  //   SurfaceVar   #252E42  inputs & chips
  //   Primary      #2DCAAA  teal (buttons, active nav, highlights)
  //   Accent       #39A7D6  sky blue
  //   TextPrimary  #E8EDF8  near-white
  //   TextSecondary #8594B0 muted blue-grey
  //   Border       #2C3550

  ThemeData _buildDarkTheme() {
    const primary = Color(0xFF2DCAAA);
    const background = Color(0xFF141920);
    const surface = Color(0xFF1D2535);
    const surfaceVariant = Color(0xFF252E42);
    const textPrimary = Color(0xFFE8EDF8);
    const textSecondary = Color(0xFF8594B0);
    const border = Color(0xFF2C3550);
    const divider = Color(0xFF242D42);
    const onPrimary = Color(0xFF0A1A18);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: Color(0xFF39A7D6),
        surface: surface,
        onPrimary: onPrimary,
        onSurface: textPrimary,
        onSecondary: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontFamily: 'Inter',
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontFamily: 'Inter',
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary.withAlpha(40),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontFamily: 'Inter',
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withAlpha(80)
              : surfaceVariant,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        displayMedium: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        displaySmall: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        headlineLarge: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        headlineMedium: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        headlineSmall: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        titleLarge: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        titleMedium: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        titleSmall: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        bodyLarge: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        bodyMedium: TextStyle(color: textPrimary, fontFamily: 'Inter'),
        bodySmall: TextStyle(color: textSecondary, fontFamily: 'Inter'),
        labelLarge: TextStyle(color: textSecondary, fontFamily: 'Inter'),
        labelMedium: TextStyle(color: textSecondary, fontFamily: 'Inter'),
        labelSmall: TextStyle(color: textSecondary, fontFamily: 'Inter'),
      ),
    );
  }
}
