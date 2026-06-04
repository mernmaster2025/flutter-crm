import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/premium_scaffold.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _NavItem('/dashboard', Icons.dashboard_rounded, 'Dashboard'),
    _NavItem('/leads', Icons.person_add_alt_1_rounded, 'Leads'),
    _NavItem('/customers', Icons.business_center_rounded, 'Customers'),
    _NavItem('/pipeline', Icons.view_kanban_rounded, 'Pipeline'),
    _NavItem('/more', Icons.more_horiz_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final morePaths = {
      '/tasks',
      '/activities',
      '/communication',
      '/reports',
      '/notifications',
      '/settings',
      '/admin',
      '/profile',
    };
    final selectedIndex = morePaths.contains(location)
        ? 4
        : _destinations.indexWhere((item) => location.startsWith(item.path));
    return PremiumScaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
        onDestinationSelected: (index) => context.go(_destinations[index].path),
        destinations: [
          for (final item in _destinations)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
      ),
      child: child,
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.icon, this.label);

  final String path;
  final IconData icon;
  final String label;
}
