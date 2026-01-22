import 'package:go_router/go_router.dart';

import '../../presentation/screens/budget_screen.dart';
import '../../presentation/screens/categories_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/about_screen.dart';
import '../../presentation/screens/contact_screen.dart';
import '../../presentation/screens/export_data_screen.dart';
import '../../presentation/screens/reports_screen.dart';
import '../../presentation/screens/reminders_screen.dart';
import '../../presentation/screens/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/export',
        builder: (context, state) => const ExportDataScreen(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
