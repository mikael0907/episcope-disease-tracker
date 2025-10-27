// providers/controllers/auth_controller.dart
import 'package:disease_tracker/constants/config.dart';
import 'package:disease_tracker/models/user_model.dart';
import 'package:disease_tracker/providers/controllers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { unauthenticated, authenticated, loading, error }

class AuthController extends StateNotifier<AuthStatus> {
  AuthController(this.ref) : super(AuthStatus.unauthenticated);
  final Ref ref;

  /// Signs up a new user with all required information
  Future<void> signUp(
    String firstName,
    String lastName,
    String userName,
    String phoneNumber,
    String email,
    String role,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      throw ArgumentError('Passwords do not match');
    }

    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }

    state = AuthStatus.loading;

    try {
      final supabase = Supabase.instance.client;
      
      debugPrint('📝 Starting signup for: $email');
      
      // Step 1: Create auth user
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: kSupabaseRedirectUrl,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      final userId = authResponse.user!.id;

      debugPrint('✅ Auth user created with ID: $userId');

      // Step 2: Insert user profile with EXACT data from signup
      await supabase.from('users').insert({
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'username': userName,
        'phone_number': phoneNumber,
        'email': email,
        'role': role,
        'consent': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ User profile created in public.users');
      debugPrint('📧 OTP sent to: $email');

      state = AuthStatus.unauthenticated;
      
    } catch (e) {
      state = AuthStatus.error;
      debugPrint('❌ Signup error: $e');
      
      if (e is AuthException) {
        if (e.message.contains('already registered') || 
            e.message.contains('User already registered')) {
          throw Exception('This email is already registered');
        }
        throw Exception('Signup failed: ${e.message}');
      }
      
      if (e is PostgrestException) {
        if (e.code == '23505') {
          if (e.message.contains('username')) {
            throw Exception('This username is already taken');
          } else if (e.message.contains('email')) {
            throw Exception('This email is already registered');
          }
          throw Exception('This account already exists');
        } else if (e.code == '23502') {
          throw Exception('All fields are required');
        }
        throw Exception('Database error: ${e.message}');
      }
      
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  /// Verifies the OTP code sent to user's email
  Future<void> verifyOtp(String email, String otp) async {
    state = AuthStatus.loading;

    try {
      final supabase = Supabase.instance.client;
      
      debugPrint('🔍 Verifying OTP for: $email');
      
      final response = await supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      final userData = response.user;
      if (userData == null) {
        throw Exception('No user returned from verification');
      }

      debugPrint('✅ OTP verified for user: ${userData.id}');

      // Fetch the user's profile
      final profile = await supabase
          .from('users')
          .select()
          .eq('id', userData.id)
          .maybeSingle();

      if (profile == null) {
        throw Exception('User profile not found. Please contact support.');
      }

      debugPrint('✅ Profile fetched: ${profile['username']}');

      // Update current user state with EXACT data from database
      ref.read(currentUserProvider.notifier).state = AppUser(
        id: userData.id,
        firstName: profile["first_name"],
        lastName: profile['last_name'],
        userName: profile["username"],
        email: profile['email'],
        role: profile['role'],
      );

      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthStatus.authenticated;
      
      debugPrint('✅ User authenticated successfully');
      
    } catch (e) {
      state = AuthStatus.error;
      debugPrint('❌ OTP verification failed: $e');
      
      if (e is AuthException) {
        if (e.message.contains('expired') || e.message.contains('Token has expired')) {
          throw Exception('OTP code has expired. Please request a new one.');
        } else if (e.message.contains('invalid') || e.message.contains('Invalid token')) {
          throw Exception('Invalid OTP code. Please check and try again.');
        }
        throw Exception('Verification failed: ${e.message}');
      }
      
      if (e is PostgrestException) {
        throw Exception('Failed to fetch user profile: ${e.message}');
      }
      
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }

  /// Signs in existing user with email and password
  Future<void> signIn(String email, String password) async {
    state = AuthStatus.loading;

    try {
      final supabase = Supabase.instance.client;
      
      debugPrint('🔐 Attempting sign in for: $email');
      
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      final userData = response.user;
      if (userData == null) {
        throw Exception('No user returned from sign in');
      }

      debugPrint('✅ Auth successful for user: ${userData.id}');

      if (userData.emailConfirmedAt == null) {
        throw Exception('Please verify your email before signing in. Check your inbox for the verification code.');
      }

      debugPrint('📧 Email confirmed, fetching profile...');

      final profile = await supabase
          .from('users')
          .select()
          .eq('id', userData.id)
          .maybeSingle();

      if (profile == null) {
        throw Exception('User profile not found. Please contact support.');
      }

      debugPrint('✅ Profile fetched: ${profile['username']}');

      // Update current user state with EXACT data from database
      ref.read(currentUserProvider.notifier).state = AppUser(
        id: userData.id,
        firstName: profile["first_name"],
        lastName: profile['last_name'],
        userName: profile["username"],
        email: profile['email'],
        role: profile['role'],
      );

      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthStatus.authenticated;
      
      debugPrint('✅ Sign in complete!');
      
    } catch (e) {
      state = AuthStatus.error;
      debugPrint('❌ Sign in failed: $e');
      
      if (e is AuthException) {
        if (e.message.contains('Invalid login credentials')) {
          throw Exception('Incorrect email or password');
        } else if (e.message.contains('Email not confirmed')) {
          throw Exception('Please verify your email first');
        }
        throw Exception('Sign in failed: ${e.message}');
      }
      
      if (e is PostgrestException) {
        throw Exception('Database error: ${e.message}');
      }
      
      if (e is ArgumentError) {
        rethrow;
      }
      
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  /// Sends OTP to email for passwordless login
  Future<void> signInWithOtp(String email) async {
    state = AuthStatus.loading;

    try {
      final supabase = Supabase.instance.client;
      
      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kSupabaseRedirectUrl,
      );
      
      state = AuthStatus.unauthenticated;
    } catch (e) {
      state = AuthStatus.error;
      
      if (e is AuthException) {
        throw Exception('Failed to send OTP: ${e.message}');
      }
      
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      state = AuthStatus.loading;
      
      await Supabase.instance.client.auth.signOut();
      
      ref.read(currentUserProvider.notifier).state = null;
      
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthStatus.unauthenticated;
    } catch (e) {
      state = AuthStatus.error;
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Checks if user is currently authenticated
  Future<void> checkAuthStatus() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      if (session != null) {
        final userData = session.user;
        
        final profile = await supabase
            .from('users')
            .select()
            .eq('id', userData.id)
            .maybeSingle();

        if (profile != null) {
          ref.read(currentUserProvider.notifier).state = AppUser(
            id: userData.id,
            firstName: profile["first_name"],
            lastName: profile['last_name'],
            userName: profile["username"],
            email: profile['email'],
            role: profile['role'],
          );
          
          state = AuthStatus.authenticated;
        } else {
          state = AuthStatus.unauthenticated;
        }
      } else {
        state = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('❌ Check auth status error: $e');
      state = AuthStatus.unauthenticated;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStatus>(
  (ref) => AuthController(ref),
);