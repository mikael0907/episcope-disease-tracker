//lib/screens/onboarding_screens/sign_in_screen.dart

import 'package:disease_tracker/models/sign_in_model.dart';
import 'package:disease_tracker/providers/controllers/auth_provider.dart';
import 'package:disease_tracker/providers/controllers/signin_controller.dart';
import 'package:disease_tracker/screens/onboarding_screens/sign_up_screen.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final signInController = ref.read(signInControllerProvider.notifier);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const StyledText(
          text: 'Sign In',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      // This prevents overflow when keyboard appears
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          // This allows scrolling when keyboard appears
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo with constrained height
                Center(
                  child: Image.asset(
                    "assets/img/episcope_logo_cropped2.png",
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                // Welcome Text
                const StyledText(
                  text: "Welcome Back!",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const StyledText(
                  text: "Sign in to continue tracking disease outbreaks",
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: signInController.updateEmail,
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onChanged: signInController.updatePassword,
                  onFieldSubmitted: (_) => _handleSignIn(
                    context,
                    authController,
                    signInState,
                  ),
                ),
                const SizedBox(height: 12),

                // Forgot Password (optional)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Forgot password feature coming soon!',
                          ),
                        ),
                      );
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In Button
                authState == AuthStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator.adaptive(),
                      )
                    : StyledButton(
                        text: "Sign In",
                        icon: Icons.login,
                        onPressed: () => _handleSignIn(
                          context,
                          authController,
                          signInState,
                        ),
                      ),
                const SizedBox(height: 16),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn(
    BuildContext context,
    AuthController authController,
    SignInModel signInState,
  ) async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if fields are not empty
    if (signInState.email.isEmpty || signInState.password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Attempt sign in
      await authController.signIn(
        signInState.email.trim(),
        signInState.password,
      );

      // If successful, navigate to home
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        String errorMessage;
        
        // Handle specific Supabase auth errors
        if (e.message.contains('Invalid login credentials')) {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (e.message.contains('Email not confirmed')) {
          errorMessage = 'Please verify your email before signing in. Check your inbox for the verification code.';
        } else if (e.message.contains('Email not found')) {
          errorMessage = 'No account found with this email. Please sign up first.';
        } else {
          errorMessage = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
