// shared/admin_route_guard.dart
import 'package:disease_tracker/providers/controllers/current_user_provider.dart';
import 'package:disease_tracker/screens/profile_screens/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminRouteGuard extends ConsumerWidget {
  const AdminRouteGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    // Check if user is authenticated and has admin role
    if (currentUser == null) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/sign-in', 
          (route) => false
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!currentUser.isAdmin) {
      // Redirect to home if not admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/home', 
          (route) => false
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied: Admin privileges required'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // User is authenticated and has admin role
    return const AdminDashboardScreen();
  }
}