//lib/shared/user_navigation_bar.dart

import 'package:flutter/material.dart';

class UserNavigationBar extends StatelessWidget {
  final int currentIndex;
  
  const UserNavigationBar({
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
              Navigator.pushReplacementNamed(context, '/home');
            }
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushReplacementNamed(context, '/case-statistics');
            }
            break;
          case 2:
            if (currentIndex != 2) {
              Navigator.pushReplacementNamed(context, '/cases');
            }
            break;
          case 3:
            if (currentIndex != 3) {
              Navigator.pushReplacementNamed(context, '/symptom-checker');
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
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'Dashboard & disease alerts',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Reports',
          tooltip: 'Charts & trends',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Track Cases',
          tooltip: 'Report new cases & outbreak locations',
        ),
        NavigationDestination(
          icon: Icon(Icons.medical_services_outlined),
          selectedIcon: Icon(Icons.medical_services),
          label: 'Symptom',
          tooltip: 'Self-assessment for risk level',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
          tooltip: 'Account settings & data export',
        ),
      ],
    );
  }
}