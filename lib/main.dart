//lib/main.dart

import 'package:disease_tracker/providers/controllers/auth_provider.dart';
import 'package:disease_tracker/screens/case_reports.dart';
import 'package:disease_tracker/screens/case_statistics_trend_screen.dart';
import 'package:disease_tracker/screens/home.dart';
import 'package:disease_tracker/screens/onboarding_screens/logo_screen.dart';
import 'package:disease_tracker/screens/onboarding_screens/sign_in_screen.dart';
import 'package:disease_tracker/screens/onboarding_screens/sign_up_screen.dart';
import 'package:disease_tracker/screens/profile_screens/user_profile_settings_screen.dart';
import 'package:disease_tracker/screens/report_case.dart';
import 'package:disease_tracker/screens/research_access_screen.dart';
import 'package:disease_tracker/screens/symptom_checker_screen.dart';
import 'package:disease_tracker/shared/admin_route_guard.dart';
import 'package:disease_tracker/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disease_tracker/constants/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status on app start
    _checkAuthStatus();
    // Listen to auth state changes
    _setupAuthListener();
  }

  Future<void> _checkAuthStatus() async {
    await ref.read(authControllerProvider.notifier).checkAuthStatus();
  }

  void _setupAuthListener() {
    // Listen to Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      if (event == AuthChangeEvent.signedIn) {
        // User signed in - update provider
        ref.read(authControllerProvider.notifier).checkAuthStatus();
      } else if (event == AuthChangeEvent.signedOut) {
        // User signed out - clear state using proper method
        final authController = ref.read(authControllerProvider.notifier);
        // Use signOut method instead of directly accessing state
        authController.signOut();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        // Token refreshed - maintain authenticated state
        ref.read(authControllerProvider.notifier).checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EpiScope',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: ThemeMode.system,
      
      // Use initialRoute
      initialRoute: '/',
      
      routes: {
        '/': (context) => const AuthCheckScreen(),
        '/logo': (context) => const LogoScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/home': (context) => Home(),
        '/report': (context) => const ReportCaseScreen(),
        '/cases': (context) => const CaseReportsScreen(),
        '/case-statistics': (context) => CaseStatisticsAndTrendsScreen(),
        '/profile': (context) => const UserProfileAndSettingsScreen(),
        '/research-access': (context) => ResearchAccessScreen(),
        '/symptom-checker': (context) => SymptomCheckerScreen(),
        '/admin-dashboard': (context) => const AdminRouteGuard(),
      },
    );
  }
}

// Auth check screen that determines where to navigate
class AuthCheckScreen extends ConsumerWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authControllerProvider);

    // Show loading while checking auth
    if (authStatus == AuthStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate based on auth status using WidgetsBinding to avoid build-time navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authStatus == AuthStatus.authenticated) {
        // User is authenticated, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User is not authenticated, show logo/onboarding
        Navigator.of(context).pushReplacementNamed('/logo');
      }
    });

    // Show loading indicator while navigation happens
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

final supabase = Supabase.instance.client;