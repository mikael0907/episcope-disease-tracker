//lib/screens/onboarding_screens/otp_screen.dart

import 'dart:async';

import 'package:disease_tracker/constants/config.dart';
import 'package:disease_tracker/providers/controllers/auth_provider.dart';
import 'package:disease_tracker/shared/custom_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool isSignUp; // To distinguish between sign-up and sign-in flows

  const OtpScreen({super.key, required this.email, this.isSignUp = false});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  final formKey = GlobalKey<FormState>();
  String currentText = '';
  bool hasError = false;
  late Timer _timer;
  int _start = 60;
  bool isLoading = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> resendOtp() async {
    setState(() {
      _start = 60;
      isLoading = true;
    });
    startTimer();

    try {
      final supabase = Supabase.instance.client;
      
      debugPrint('📧 Resending OTP for: ${widget.email}');
      debugPrint('📧 Is signup: ${widget.isSignUp}');
      
      if (widget.isSignUp) {
        // For signup, resend the signup confirmation email
        await supabase.auth.resend(
          type: OtpType.signup,
          email: widget.email,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Verification code resent! Check your email.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For sign-in, send magic link OTP
        await supabase.auth.signInWithOtp(
          email: widget.email,
          emailRedirectTo: kSupabaseRedirectUrl,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Sign-in code resent! Check your email.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      debugPrint('✅ OTP resent successfully');
      
    } catch (e) {
      debugPrint('❌ Resend OTP error: $e');
      
      if (mounted) {
        String errorMessage = 'Failed to resend OTP';
        
        if (e is AuthException) {
          if (e.message.contains('rate limit')) {
            errorMessage = 'Too many attempts. Please wait a few minutes.';
          } else if (e.message.contains('Email rate limit exceeded')) {
            errorMessage = 'Please wait before requesting another code.';
          } else {
            errorMessage = e.message;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    errorController?.close();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StyledText(
          text: "Verify OTP",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          return SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    StyledText(
                      text: widget.isSignUp 
                          ? "Verify Your Email"
                          : "Enter Verification Code",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "We've sent a 6-digit verification code to:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          pastedTextStyle: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                          obscureText: false,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 55,
                            fieldWidth: 45,
                            activeFillColor: Colors.white,
                            disabledColor: Colors.grey.shade300,
                            inactiveColor: Colors.grey.shade300,
                            inactiveFillColor: Colors.grey.shade100,
                            selectedColor: Theme.of(context).colorScheme.primary,
                            selectedFillColor: Colors.white,
                            activeColor: Theme.of(context).colorScheme.primary,
                            errorBorderColor: Colors.red,
                          ),
                          cursorColor: Theme.of(context).colorScheme.primary,
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          boxShadows: const [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: Colors.black12,
                              blurRadius: 5,
                            ),
                          ],
                          onCompleted: (v) async {
                            debugPrint('🔢 OTP entered: $v');
                            await _verifyOtp(ref);
                          },
                          onChanged: (value) {
                            setState(() {
                              currentText = value;
                              hasError = false;
                            });
                          },
                          beforeTextPaste: (text) {
                            debugPrint('📋 Pasted text: $text');
                            return true;
                          },
                        ),
                      ),
                    ),
                    if (hasError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Invalid OTP. Please check and try again.",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 30),
                    _start != 0
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              "Resend code in $_start seconds",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code?",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: isLoading ? null : resendOtp,
                              child: Text(
                                "Resend",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isLoading 
                                      ? Colors.grey 
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    const SizedBox(height: 30),
                    isLoading
                        ? const CircularProgressIndicator()
                        : CustomButton(
                          minWidth: MediaQuery.of(context).size.width * 0.9,
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                          minHeight: 56,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (currentText.length != 6) {
                                errorController!.add(ErrorAnimationType.shake);
                                setState(() => hasError = true);
                              } else {
                                await _verifyOtp(ref);
                              }
                            }
                          },
                          color: Theme.of(context).colorScheme.primary,
                          title: "VERIFY & CONTINUE",
                        ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        otpController.clear();
                        setState(() {
                          currentText = '';
                          hasError = false;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Clear Code"),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Check your spam folder if you don't see the email",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _verifyOtp(WidgetRef ref) async {
    if (isLoading) return;
    
    setState(() => isLoading = true);
    
    try {
      debugPrint('🔐 Verifying OTP: ${otpController.text}');
      debugPrint('📧 Email: ${widget.email}');
      debugPrint('📝 Is signup: ${widget.isSignUp}');
      
      await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(widget.email, otpController.text);

      debugPrint('✅ OTP verified successfully');

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Email verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Small delay to show success message
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      if (widget.isSignUp) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint('❌ OTP verification error: $e');
      
      if (!mounted) return;
      
      String errorMessage = 'OTP verification failed';
      
      if (e.toString().contains('expired')) {
        errorMessage = 'OTP has expired. Please request a new one.';
        setState(() => _start = 0); // Allow immediate resend
      } else if (e.toString().contains('invalid') || e.toString().contains('Invalid')) {
        errorMessage = 'Invalid OTP. Please check and try again.';
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      
      errorController!.add(ErrorAnimationType.shake);
      setState(() => hasError = true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}