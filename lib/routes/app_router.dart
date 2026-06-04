import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/auth/auth_screen.dart';
import '../presentation/customers/customers_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/leads/leads_screen.dart';
import '../presentation/modules/module_screens.dart';
import '../presentation/pipeline/pipeline_screen.dart';
import '../presentation/providers/app_providers.dart';
import '../presentation/shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final isAuthenticated = authState.valueOrNull != null;
  final isRestoring = authState.isLoading;

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final authPaths = {'/login', '/register', '/forgot-password', '/otp'};
      final isAuthPath = authPaths.contains(state.uri.path);
      if (isRestoring) return null;
      if (!isAuthenticated && !isAuthPath) return '/login';
      if (isAuthenticated && isAuthPath) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(mode: AuthMode.login),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const AuthScreen(mode: AuthMode.register),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const AuthScreen(mode: AuthMode.forgotPassword),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const AuthScreen(mode: AuthMode.otp),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/leads', builder: (context, state) => const LeadsScreen()),
          GoRoute(path: '/customers', builder: (context, state) => const CustomersScreen()),
          GoRoute(path: '/pipeline', builder: (context, state) => const PipelineScreen()),
          GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
          GoRoute(path: '/tasks', builder: (context, state) => const TasksMeetingsScreen()),
          GoRoute(path: '/activities', builder: (context, state) => const ActivitiesScreen()),
          GoRoute(path: '/communication', builder: (context, state) => const CommunicationScreen()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
