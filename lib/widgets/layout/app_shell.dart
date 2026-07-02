import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';

part 'nav_tab.dart';
part 'crm_app_bar.dart';
part 'more_screen.dart';
part 'module.dart';
part 'module_tile.dart';

// ============================================================
// AppShell — Bottom navigation + persistent shell
// ============================================================

class AppShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const AppShell({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  static const _tabs = [
    _NavTab(
        label: 'Dashboard', icon: Icons.dashboard_rounded, route: '/dashboard'),
    _NavTab(label: 'Leads', icon: Icons.person_search_rounded, route: '/leads'),
    _NavTab(label: 'Clients', icon: Icons.people_rounded, route: '/clients'),
    _NavTab(label: 'Tasks', icon: Icons.check_box_rounded, route: '/tasks'),
    _NavTab(label: 'Projects', icon: Icons.folder_rounded, route: '/projects'),
    _NavTab(label: 'More', icon: Icons.grid_view_rounded, route: '/more'),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleTabs = _tabs
        .where((tab) => CrmApi.instance.canAccessRoute(tab.route))
        .toList();
    final path = GoRouterState.of(context).uri.path;
    final activeIndex =
        visibleTabs.indexWhere((tab) => path.startsWith(tab.route));
    final selected = visibleTabs.isEmpty
        ? 0
        : activeIndex < 0
            ? selectedIndex.clamp(0, visibleTabs.length - 1).toInt()
            : activeIndex;
    return Scaffold(
      body: child,
      bottomNavigationBar: visibleTabs.length < 2
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.slate100)),
              ),
              child: NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: (i) => context.go(visibleTabs[i].route),
                destinations: visibleTabs
                    .map((t) => NavigationDestination(
                          icon: Icon(t.icon),
                          selectedIcon: Icon(t.icon),
                          label: t.label,
                        ))
                    .toList(),
              ),
            ),
    );
  }
}

// ============================================================
// CrmAppBar — Consistent app bar used across screens
// ============================================================

// ============================================================
// More Drawer — shows remaining modules
// ============================================================
