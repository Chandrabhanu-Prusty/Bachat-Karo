import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/state/app_state.dart';
import '../../../../features/home/presentation/screens/app_shell.dart';
import 'login_screen.dart';

/// Listens to Supabase's auth state stream.
/// - No session  → LoginScreen
/// - Has session → AppShell (hydrates data on first entry)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While waiting for the first auth event, show a splash
        if (!snapshot.hasData) return const _SplashScreen();

        final session = snapshot.data!.session;

        if (session == null) {
          // User signed out — clear in-memory data
          Future.microtask(
            () {
              if (context.mounted) {
                context.read<AppState>().clearSession();
              }
            },
          );
          return const LoginScreen();
        }

        // User signed in — hydrate from Supabase (guard: only if not already loading)
        final appState = context.read<AppState>();
        if (!appState.isLoading && appState.user == null) {
          Future.microtask(() {
            if (context.mounted) appState.hydrateFromBackend();
          });
        }

        return const AppShell();
      },
    );
  }
}

/// Simple loading screen shown while waiting for the first auth event.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: cs.primary),
      ),
    );
  }
}