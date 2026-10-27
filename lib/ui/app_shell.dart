import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import 'dashboard_page.dart';
import 'visitor_list_page.dart';
import 'scanner_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const VisitorListPage(),
      const ScannerPage(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          if (i == 0 || i == 1) {
            context.read<VisitorBloc>().add(const VisitorsRequested());
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withValues(alpha: .18),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.people_alt_outlined), label: 'Visitors'),
          NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_rounded), label: 'Scan QR'),
        ],
      ),
    );
  }
}
