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
import 'features/import/data/import_repository.dart';
import 'features/insights/data/insights_repository.dart';

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
        authRepo:     AuthRepository(client),
        expenseRepo:  ExpenseRepository(client),
        userRepo:     UserRepository(client),
        importRepo:   ImportRepository(client),
        insightsRepo: InsightsRepository(client),
      ),
      child: const BachatKaroApp(),
    ),
  );
}

class BachatKaroApp extends StatelessWidget {
  const BachatKaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    // App is light-mode only — system overlay always uses dark icons.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Bachat Karo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: _buildLightTheme(),
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

}
