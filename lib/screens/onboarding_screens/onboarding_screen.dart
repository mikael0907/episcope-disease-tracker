import 'package:disease_tracker/screens/onboarding_screens/sign_in_screen.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _navigateToSignInScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(88.0),
          child: Column(
            children: [
              StyledText(
                text: "Track & report infectious diseases in real-time.",
                fontWeight: FontWeight.bold,
                fontSize: 40,
                textAlign: TextAlign.center,
                fontStyle: FontStyle.italic,
              ),
              SizedBox(height: 370),
              StyledButton(
                text: "GET STARTED",
                onPressed: () => _navigateToSignInScreen(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
