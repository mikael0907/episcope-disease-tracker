//lib/screens/profile_screens/user_profile_settings_screen.dart

import 'package:disease_tracker/providers/controllers/auth_provider.dart';
import 'package:disease_tracker/providers/controllers/current_user_provider.dart';
import 'package:disease_tracker/screens/onboarding_screens/logo_screen.dart';
import 'package:disease_tracker/screens/research_access_screen.dart';
import 'package:disease_tracker/shared/admin_navigation_bar.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:disease_tracker/shared/user_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileAndSettingsScreen extends ConsumerStatefulWidget {
  const UserProfileAndSettingsScreen({super.key});

  @override
  ConsumerState<UserProfileAndSettingsScreen> createState() =>
      _UserProfileAndSettingsScreenState();
}

class _UserProfileAndSettingsScreenState
    extends ConsumerState<UserProfileAndSettingsScreen> {
  bool isSwitched = false;
  bool emailSwitchAlert = false;
  bool inAppNotificationsSwitch = false;
  bool weeklyCaseToggle = false;
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authControllerProvider.notifier).signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogoScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StyledText(text: "Logout Error: ${e.toString()}"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
      final isAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: StyledText(
          text: "Profile & Settings",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).canvasColor,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Add Admin Section if user is admin
            if (isAdmin) ...[
              const SizedBox(height: 20),
              _buildAdminSection(context),
            ],



              // User Profile Card
              Card(
                elevation: 2,
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          currentUser?.firstName.substring(0, 1).toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // User Info
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text("Full Name"),
                        subtitle: Text(
                          currentUser?.fullName ?? 'Not available',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.alternate_email),
                        title: const Text("Username"),
                        subtitle: Text(
                          currentUser?.userName ?? 'Not available',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text("Email"),
                        subtitle: Text(
                          currentUser?.email ?? 'Not available',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.work),
                        title: const Text("Role"),
                        subtitle: Text(
                          _formatRole(currentUser?.role ?? 'regular_user'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Newsletter Subscription
              Card(
                child: ListTile(
                  leading: const Icon(Icons.newspaper_outlined),
                  title: const StyledText(
                    text: "Disease Alert Newsletter",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  subtitle: const StyledText(
                    text: "Stay informed about trending diseases",
                    fontSize: 12,
                  ),
                  trailing: Switch.adaptive(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Alert Preferences Section
              const StyledText(
                text: "Alert Preferences",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const StyledText(
                        text: "Email Alerts for New Outbreaks",
                        fontSize: 14,
                      ),
                      trailing: Switch.adaptive(
                        value: emailSwitchAlert,
                        onChanged: (value) {
                          setState(() {
                            emailSwitchAlert = value;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_active),
                      title: const StyledText(
                        text: "In-App Notifications",
                        fontSize: 14,
                      ),
                      trailing: Switch.adaptive(
                        value: inAppNotificationsSwitch,
                        onChanged: (value) {
                          setState(() {
                            inAppNotificationsSwitch = value;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const StyledText(
                        text: "Weekly Case Summary",
                        fontSize: 14,
                      ),
                      trailing: Switch.adaptive(
                        value: weeklyCaseToggle,
                        onChanged: (value) {
                          setState(() {
                            weeklyCaseToggle = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Account Security Section
              const StyledText(
                text: "Account Security",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              
              StyledButton(
                icon: Icons.password,
                onPressed: () {
                  // TODO: Navigate to change password screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Change password feature coming soon!'),
                    ),
                  );
                },
                text: "Change Password",
              ),
              const SizedBox(height: 10),
              
              StyledButton(
                onPressed: () {
                  // TODO: Navigate to 2FA setup screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('2FA feature coming soon!'),
                    ),
                  );
                },
                text: "Enable 2FA",
                icon: Icons.security,
              ),
              const SizedBox(height: 20),
              
              // Data Export Section
              const StyledText(
                text: "Data Export",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              
              const StyledText(
                text: "Download your anonymized health data",
                fontSize: 14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              
              StyledButton(
                onPressed: () {
                  // TODO: Implement data export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data export feature coming soon!'),
                    ),
                  );
                },
                text: "Export Health Data",
                icon: Icons.download,
              ),
              const SizedBox(height: 20),
              
              // Research Access Section
              const StyledText(
                text: "Research Access",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              
              const StyledText(
                text: "Request access to research data",
                fontSize: 14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              
              StyledButton(
                text: "Request Research Access",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResearchAccessScreen(),
                    ),
                  );
                },
                icon: Icons.science,
              ),
              const SizedBox(height: 30),
              
              // Logout Button
              if (authState == AuthStatus.authenticated)
                StyledButton(
                  text: "Logout",
                  onPressed: _handleLogout,
                  icon: Icons.logout,
                  color: const Color(0xFFEF4444),
                  isLoading: _isLoggingOut,
                )
              else
                const SizedBox.shrink(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: currentUser?.isAdmin == true
          ? const AdminNavigationBar(currentIndex: 4)
          : const UserNavigationBar(currentIndex: 4)
    );
  }



Widget _buildAdminSection(BuildContext context) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.admin_panel_settings, color: Colors.red),
            title: Text(
              'Administration',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 8),
          StyledButton(
            text: "Admin Dashboard",
            onPressed: () {
              Navigator.pushNamed(context, '/admin-dashboard');
            },
            color: Colors.red,
            icon: Icons.dashboard,
          ),
        ],
      ),
    ),
  );
}




  String _formatRole(String role) {
    // Convert database enum to readable format
    switch (role) {
      case 'academic_researcher':
        return 'Academic Researcher';
      case 'regular_user':
        return 'Regular User';
      case 'organization':
        return 'Organization';
      case 'government':
        return 'Government';
      case 'hospital':
        return 'Hospital';
      default:
        return role;
    }
  }
}