//lib/screens/onboarding_screens/sign_up_screen.dart

import 'package:disease_tracker/models/sign_up_model.dart';
import 'package:disease_tracker/providers/controllers/auth_provider.dart';
import 'package:disease_tracker/providers/controllers/signup_controller.dart';
import 'package:disease_tracker/screens/onboarding_screens/otp_screen.dart';
import 'package:disease_tracker/screens/onboarding_screens/sign_in_screen.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef UserRoleEntry = DropdownMenuEntry<UserRole>;

enum UserRole {
  specify('Specify Role', Icons.question_mark_outlined, ''),
  researcher('Academic Researcher', Icons.library_books, 'academic_researcher'),
  organization('Organization', Icons.groups, 'organization'),
  regularUser('Regular User', Icons.person, 'regular_user'),
  hospital('Hospital', Icons.local_hospital, 'hospital'),
  government('Government', Icons.assured_workload, 'government');

  const UserRole(this.label, this.icon, this.dbValue);
  final String label;
  final IconData icon;
  final String dbValue; // This is the value that matches your database enum

  static final List<UserRoleEntry> entries =
      UnmodifiableListView<UserRoleEntry>(
    values
        .where((role) => role != UserRole.specify)
        .map<UserRoleEntry>(
          (UserRole role) => UserRoleEntry(
            value: role,
            label: role.label,
            leadingIcon: Icon(role.icon),
          ),
        )
        .toList(),
  );
}

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final signUpController = ref.read(signUpControllerProvider.notifier);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const StyledText(
          text: "Sign Up",
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/img/episcope_logo.png',
                  height: 120,
                ),
                const SizedBox(height: 24),
                
                // First Name Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onChanged: signUpController.updateFirstName,
                ),
                const SizedBox(height: 16),
                
                // Last Name Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  onChanged: signUpController.updateLastName,
                ),
                const SizedBox(height: 16),
                
                // Username Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                  onChanged: signUpController.updateUserName,
                ),
                const SizedBox(height: 16),
                
                // Phone Number Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+234XXXXXXXXXX',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  onChanged: signUpController.updatePhoneNumber,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Email Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: signUpController.updateEmail,
                ),
                const SizedBox(height: 16),
                
                // Role Dropdown
                DropdownButtonFormField<UserRole>(
                  decoration: const InputDecoration(
                    labelText: "Select Your Role",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: UserRole.values
                      .where((role) => role != UserRole.specify)
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Row(
                              children: [
                                Icon(role.icon, size: 20),
                                const SizedBox(width: 8),
                                Text(role.label),
                              ],
                            ),
                          ))
                      .toList(),
                  validator: (value) {
                    if (value == null || value == UserRole.specify) {
                      return 'Please select your role';
                    }
                    return null;
                  },
                  onChanged: (UserRole? role) {
                    if (role != null && role != UserRole.specify) {
                      // IMPORTANT: Pass the dbValue, not the label
                      signUpController.updateRole(role.dbValue);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Minimum 8 characters',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  onChanged: signUpController.updatePassword,
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != signUpState.password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onChanged: signUpController.updateConfirmPassword,
                ),
                const SizedBox(height: 16),
                
                // Consent Checkbox
                _buildCheckBox(signUpController),
                const SizedBox(height: 24),
                
                // Sign Up Button
                authState == AuthStatus.loading
                    ? const CircularProgressIndicator.adaptive()
                    : StyledButton(
                        text: "Sign Up",
                        onPressed: () => _handleSignUp(
                          context,
                          ref,
                          authController,
                          signUpState,
                        ),
                      ),
                const SizedBox(height: 16),
                
                // Sign In Link
                TextButton(
                  child: const Text("Already have an account? Sign In"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckBox(SignUpController signUpController) {
    return Row(
      children: [
        Checkbox.adaptive(
          value: ref.watch(signUpControllerProvider).signUpConsent,
          onChanged: signUpController.updateSignUpConsent,
        ),
        const Expanded(
          child: StyledText(
            text:
                "I consent to my anonymized data being used for public health research",
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp(
    BuildContext context,
    WidgetRef ref,
    AuthController authController,
    SignUpModel signUpState,
  ) async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check consent
    if (!signUpState.signUpConsent) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please consent to data usage to continue'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Attempt to sign up
      await authController.signUp(
        signUpState.firstName,
        signUpState.lastName,
        signUpState.userName,
        signUpState.phoneNumber,
        signUpState.email,
        signUpState.role,
        signUpState.password,
        signUpState.confirmPassword,
      );

      if (context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created! Please check your email for verification code.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        // Navigate to OTP screen after a brief delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                email: signUpState.email,
                isSignUp: true,
              ),
            ),
          );
        }
      }
    } on PostgrestException catch (e) {
      if (context.mounted) {
        String errorMessage;
        switch (e.code) {
          case '23505': // Unique violation
            if (e.message.contains('username')) {
              errorMessage = 'This username is already taken';
            } else if (e.message.contains('email')) {
              errorMessage = 'This email is already registered';
            } else {
              errorMessage = 'This account already exists';
            }
            break;
          case '42501':
            errorMessage = "Unauthorized access";
            break;
          default:
            errorMessage = "Database error: ${e.message}";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}