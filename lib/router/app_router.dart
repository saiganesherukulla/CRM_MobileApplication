import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/client_detail_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/projects/projects_screen.dart';
import '../screens/emails/emails_screen.dart';
import '../screens/workflows/workflows_screen.dart';
import '../screens/tickets/tickets_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/layout/app_shell.dart';

// ============================================================
// AppRouter — GoRouter configuration for the CRM app
// ============================================================

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _fade(state, const LoginScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(
        selectedIndex: _selectedIndex(state.uri.path),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              _slide(state, const DashboardScreen()),
        ),
        GoRoute(
          path: '/clients',
          pageBuilder: (context, state) => _slide(state, const ClientsScreen()),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => _slide(
                state,
                ClientDetailScreen(clientId: state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (context, state) => _slide(state, const TasksScreen()),
        ),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) =>
              _slide(state, const ProjectsScreen()),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => _slide(
                state,
                ProjectDetailScreen(projectId: state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/more',
          pageBuilder: (context, state) => _slide(state, const MoreScreen()),
        ),
        GoRoute(
          path: '/emails',
          pageBuilder: (context, state) => _slide(state, const EmailsScreen()),
        ),
        GoRoute(
          path: '/workflows',
          pageBuilder: (context, state) =>
              _slide(state, const WorkflowsScreen()),
        ),
        GoRoute(
          path: '/tickets',
          pageBuilder: (context, state) => _slide(state, const TicketsScreen()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => _slide(state, const ReportsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              _slide(state, const SettingsScreen()),
        ),
      ],
    ),
  ],
);

int _selectedIndex(String path) {
  if (path.startsWith('/clients')) return 1;
  if (path.startsWith('/tasks')) return 2;
  if (path.startsWith('/projects')) return 3;
  if (path.startsWith('/dashboard')) return 0;
  return 4;
}

CustomTransitionPage<void> _fade<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _slide<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) => SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      ),
      child: FadeTransition(opacity: animation, child: child),
    ),
  );
}
