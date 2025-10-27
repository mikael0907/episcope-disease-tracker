//lib/shared/admin_navigation_bar.dart

import 'package:flutter/material.dart';

class AdminNavigationBar extends StatelessWidget {
  final int currentIndex;
  
  const AdminNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (int index) {
        // Navigate to the selected screen
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            }
            break;
          case 1:
            if (currentIndex != 1) {
              // Navigate to requests tab in admin dashboard
              Navigator.pushReplacementNamed(
                context,
                '/admin-dashboard',
                arguments: {'initialTab': 6}, // Research Requests tab
              );
            }
            break;
          case 2:
            if (currentIndex != 2) {
              // Navigate to analytics tab in admin dashboard
              Navigator.pushReplacementNamed(
                context,
                '/admin-dashboard',
                arguments: {'initialTab': 0}, // Dashboard tab with stats
              );
            }
            break;
          case 3:
            if (currentIndex != 3) {
              // Navigate to settings tab in admin dashboard
              Navigator.pushReplacementNamed(
                context,
                '/admin-dashboard',
                arguments: {'initialTab': 5}, // Management tab
              );
            }
            break;
          case 4:
            if (currentIndex != 4) {
              Navigator.pushReplacementNamed(context, '/profile');
            }
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
          tooltip: 'Overview of reports & data',
        ),
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: 'Requests',
          tooltip: 'Research access & feature submissions',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Analytics',
          tooltip: 'Outbreak trends & user activity',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
          tooltip: 'Manage app features & privacy',
        ),
        NavigationDestination(
          icon: Icon(Icons.verified_user_outlined),
          selectedIcon: Icon(Icons.verified_user),
          label: 'Profile',
          tooltip: 'Admin profile & logout',
        ),
      ],
    );
  }
}