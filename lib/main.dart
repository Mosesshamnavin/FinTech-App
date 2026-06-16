import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/collections/presentation/pages/cashout_page.dart';
import 'features/collections/presentation/pages/collections_page.dart';
import 'features/customers/presentation/pages/customers_page.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';
import 'features/home/presentation/pages/home_shell_page.dart';
import 'features/reports/presentation/pages/report_detail_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/settings/presentation/pages/language_settings_page.dart';
import 'features/settings/presentation/pages/my_settings_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionANavigatorKey = GlobalKey<NavigatorState>();
final _sectionBNavigatorKey = GlobalKey<NavigatorState>();
final _sectionCNavigatorKey = GlobalKey<NavigatorState>();
final _sectionDNavigatorKey = GlobalKey<NavigatorState>();
final _sectionENavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeShellPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _sectionANavigatorKey,
          routes: [
            GoRoute(
              path: '/collections',
              builder: (context, state) => const CollectionsPage(),
              routes: [
                GoRoute(
                  path: 'cashout',
                  builder: (context, state) => const CashOutPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _sectionBNavigatorKey,
          routes: [
            GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpensesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _sectionCNavigatorKey,
          routes: [
            GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomersPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _sectionDNavigatorKey,
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsPage(),
              routes: [
                GoRoute(
                  path: ':reportId',
                  builder: (context, state) {
                    final reportId = state.pathParameters['reportId']!;
                    return ReportDetailPage(reportName: Uri.decodeComponent(reportId));
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _sectionENavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'my-settings',
                  builder: (context, state) => const MySettingsPage(),
                ),
                GoRoute(
                  path: 'language',
                  builder: (context, state) => const LanguageSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeName, _) {
        return MaterialApp.router(
          title: 'Vasool Drive',
          theme: AppTheme.getTheme(themeName),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
