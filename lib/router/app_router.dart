import 'package:go_router/go_router.dart';
import 'package:visitor_management_app/models/visitor.dart';
import 'package:visitor_management_app/ui/app_shell.dart';
import 'package:visitor_management_app/ui/dashboard_page.dart';
import 'package:visitor_management_app/ui/scanner_page.dart';
import 'package:visitor_management_app/ui/visitor_details_page.dart';
import 'package:visitor_management_app/ui/visitor_form_page.dart';
import 'package:visitor_management_app/ui/visitor_list_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'initial',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/visitors',
      name: 'visitors',
      builder: (context, state) => const VisitorListPage(),
    ),
    GoRoute(
      path: '/visitors/add',
      name: 'addVisitor',
      builder: (context, state) => const VisitorFormPage(),
    ),
    GoRoute(
      path: '/visitors/details',
      name: 'visitorDetails',
      builder: (context, state) {
        final visitor = state.extra as Visitor;
        return VisitorDetailsPage(visitor: visitor);
      },
    ),
    GoRoute(
      path: '/visitors/edit',
      name: 'editVisitor',
      builder: (context, state) {
        final visitor = state.extra as Visitor;
        return VisitorFormPage(visitor: visitor);
      },
    ),
    GoRoute(
      path: '/scanner',
      name: 'scanner',
      builder: (context, state) => const ScannerPage(),
    ),
  ],
);
