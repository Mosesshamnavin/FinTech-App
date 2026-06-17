import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/collections/presentation/pages/cashout_page.dart';
import 'features/collections/presentation/pages/collections_page.dart';
import 'features/collections/presentation/pages/reminders_notes_page.dart';
import 'features/customers/presentation/pages/customers_page.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';
import 'features/home/presentation/pages/home_shell_page.dart';
import 'features/reports/presentation/pages/report_detail_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/settings/presentation/pages/language_settings_page.dart';
import 'features/settings/presentation/pages/my_settings_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/pages/change_password_page.dart';
import 'features/settings/presentation/pages/enable_security_alert_page.dart';
import 'features/settings/presentation/pages/enable_fingerprint_page.dart';
import 'features/settings/presentation/pages/site_page.dart';
import 'features/settings/presentation/pages/expense_type_page.dart';
import 'features/settings/presentation/pages/investment_type_page.dart';
import 'features/settings/presentation/pages/add_expense_type_page.dart';
import 'features/settings/presentation/pages/add_investment_type_page.dart';
import 'features/settings/presentation/pages/area_page.dart';
import 'features/settings/presentation/pages/add_area_page.dart';
import 'features/settings/presentation/pages/license_page.dart';
import 'features/settings/presentation/pages/line_page.dart';
import 'features/settings/presentation/pages/move_line_customer_page.dart';
import 'features/settings/presentation/pages/import_line_page.dart';
import 'features/settings/presentation/pages/export_line_page.dart';
import 'features/settings/presentation/pages/sms_template_page.dart';
import 'features/settings/presentation/pages/support_page.dart';

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
                GoRoute(
                  path: 'reminders',
                  builder: (context, state) => const RemindersNotesPage(),
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
                  path: 'support',
                  builder: (context, state) => const SupportPage(),
                ),
                GoRoute(
                  path: 'language',
                  builder: (context, state) => const LanguageSettingsPage(),
                ),
                GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordPage(),
                ),
                GoRoute(
                  path: 'enable-security-alert',
                  builder: (context, state) => const EnableSecurityAlertPage(),
                ),
                GoRoute(
                  path: 'enable-fingerprint',
                  builder: (context, state) => const EnableFingerprintPage(),
                ),
                GoRoute(
                  path: 'site',
                  builder: (context, state) => const SitePage(),
                ),
                GoRoute(
                  path: 'expense-type',
                  builder: (context, state) => const ExpenseTypePage(),
                ),
                GoRoute(
                  path: 'investment-type',
                  builder: (context, state) => const InvestmentTypePage(),
                ),
                GoRoute(
                  path: 'add-expense-type',
                  builder: (context, state) => const AddExpenseTypePage(),
                ),
                GoRoute(
                  path: 'add-investment-type',
                  builder: (context, state) => const AddInvestmentTypePage(),
                ),
                GoRoute(
                  path: 'area',
                  builder: (context, state) => const AreaPage(),
                ),
                GoRoute(
                  path: 'add-area',
                  builder: (context, state) => const AddAreaPage(),
                ),
                GoRoute(
                  path: 'license',
                  builder: (context, state) => const AppLicensePage(),
                ),
                GoRoute(
                  path: 'line',
                  builder: (context, state) => const LinePage(),
                ),
                GoRoute(
                  path: 'move-line-customer',
                  builder: (context, state) => const MoveLineCustomerPage(),
                ),
                GoRoute(
                  path: 'import-line',
                  builder: (context, state) => const ImportLinePage(),
                ),
                GoRoute(
                  path: 'export-line',
                  builder: (context, state) => const ExportLinePage(),
                ),
                GoRoute(
                  path: 'sms-template',
                  builder: (context, state) => const SmsTemplatePage(),
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
