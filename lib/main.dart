import 'core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/loans/presentation/bloc/loans_bloc.dart';
import 'features/loans/presentation/bloc/loans_event.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/collections/presentation/bloc/cashout_bloc.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/collections/presentation/pages/cashout_page.dart';
import 'features/collections/presentation/pages/collections_page.dart';
import 'features/collections/presentation/pages/reminders_notes_page.dart';
import 'features/customers/presentation/pages/customer_detail_page.dart';
import 'features/customers/domain/entities/customer_entity.dart';
import 'features/loans/presentation/pages/add_loan_page.dart';
import 'features/customers/presentation/pages/add_customer_page.dart';
import 'features/customers/presentation/pages/customers_page.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';
import 'features/home/presentation/pages/home_shell_page.dart';
import 'features/reports/presentation/pages/plan_report_page.dart';
import 'features/reports/presentation/pages/daily_summary_page.dart';
import 'features/reports/presentation/pages/line_summary_page.dart';
import 'features/reports/presentation/pages/online_collection_summary_page.dart';
import 'features/reports/presentation/pages/site_dashboard_summary_page.dart';
import 'features/reports/presentation/pages/expense_summary_page.dart';
import 'features/reports/presentation/pages/investment_summary_page.dart';
import 'features/reports/presentation/pages/investment_expense_summary_page.dart';
import 'features/reports/presentation/pages/book_excess_loss_summary_page.dart';
import 'features/reports/presentation/pages/loan_summary_page.dart';
import 'features/reports/presentation/pages/about_to_close_loan_summary_page.dart';
import 'features/reports/presentation/pages/missing_customer_summary_page.dart';
import 'features/reports/presentation/pages/monthly_interest_pending_summary_page.dart';
import 'features/reports/presentation/pages/completed_loan_summary_page.dart';
import 'features/reports/presentation/pages/non_performance_loan_summary_page.dart';
import 'features/reports/presentation/pages/new_customer_summary_page.dart';
import 'features/reports/presentation/pages/bad_loan_summary_page.dart';
import 'features/reports/presentation/pages/new_bad_loan_by_date_summary_page.dart';
import 'features/reports/presentation/pages/loan_analysis_page.dart';
import 'features/reports/presentation/pages/ledger_report_page.dart';
import 'features/reports/presentation/pages/report_detail_page.dart';
import 'features/reports/domain/entities/report_entity.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
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
  initialLocation: '/',
  redirect: (context, state) {
    // Auth redirect is handled by BlocListener in LoginPage.
    // Router stays simple — no global redirect needed with BLoC.
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
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
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CashOutPage(),
                ),
                GoRoute(
                  path: 'reminders',
                  parentNavigatorKey: _rootNavigatorKey,
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
              builder: (context, state) => BlocProvider<ExpensesBloc>(
                create: (_) => sl<ExpensesBloc>(),
                child: const ExpensesPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _sectionCNavigatorKey,
          routes: [
            GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomersPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddCustomerPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final customer = state.extra as CustomerEntity;
                    return CustomerDetailPage(customer: customer);
                  },
                ),
                GoRoute(
                  path: ':id/add-loan',
                  builder: (context, state) {
                    final customer = state.extra as CustomerEntity;
                    return AddLoanPage(customer: customer);
                  },
                ),
              ],
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
                  path: 'plan',
                  builder: (context, state) => const PlanReportPage(),
                ),
                GoRoute(
                  path: 'daily-summary',
                  builder: (context, state) => const DailySummaryPage(),
                ),
                GoRoute(
                  path: 'line-summary',
                  builder: (context, state) => const LineSummaryPage(),
                ),
                GoRoute(
                  path: 'online-collection-summary',
                  builder: (context, state) => const OnlineCollectionSummaryPage(),
                ),
                GoRoute(
                  path: 'site-dashboard-summary',
                  builder: (context, state) => const SiteDashboardSummaryPage(),
                ),
                GoRoute(
                  path: 'expense-summary',
                  builder: (context, state) => const ExpenseSummaryPage(),
                ),
                GoRoute(
                  path: 'investment-summary',
                  builder: (context, state) => const InvestmentSummaryPage(),
                ),
                GoRoute(
                  path: 'investment-expense-summary',
                  builder: (context, state) => const InvestmentExpenseSummaryPage(),
                ),
                GoRoute(
                  path: 'book-excess-loss-summary',
                  builder: (context, state) => const BookExcessLossSummaryPage(),
                ),
                GoRoute(
                  path: 'loan-summary',
                  builder: (context, state) => BlocProvider<LoansBloc>(
                    create: (_) => sl<LoansBloc>(),
                    child: const LoanSummaryPage(),
                  ),
                ),
                GoRoute(
                  path: 'about-to-close-loan-summary',
                  builder: (context, state) => const AboutToCloseLoanSummaryPage(),
                ),
                GoRoute(
                  path: 'missing-customer-summary',
                  builder: (context, state) => const MissingCustomerSummaryPage(),
                ),
                GoRoute(
                  path: 'monthly-interest-pending-summary',
                  builder: (context, state) => const MonthlyInterestPendingSummaryPage(),
                ),
                GoRoute(
                  path: 'completed-loan-summary',
                  builder: (context, state) => const CompletedLoanSummaryPage(),
                ),
                GoRoute(
                  path: 'non-performance-loan-summary',
                  builder: (context, state) => const NonPerformanceLoanSummaryPage(),
                ),
                GoRoute(
                  path: 'new-customer-summary',
                  builder: (context, state) => const NewCustomerSummaryPage(),
                ),
                GoRoute(
                  path: 'bad-loan-summary',
                  builder: (context, state) => const BadLoanSummaryPage(),
                ),
                GoRoute(
                  path: 'new-bad-loan-by-date-summary',
                  builder: (context, state) => const NewBadLoanByDateSummaryPage(),
                ),
                GoRoute(
                  path: 'loan-analysis',
                  builder: (context, state) => const LoanAnalysisPage(),
                ),
                GoRoute(
                  path: 'ledger-report',
                  builder: (context, state) => const LedgerReportPage(),
                ),
                GoRoute(
                  path: ':reportId',
                  builder: (context, state) {
                    final report = state.extra as ReportEntity;
                    return ReportDetailPage(report: report);
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<LoansBloc>()..add(LoadAllLoansRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<SettingsBloc>()..add(LoadSettingsRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<CashOutBloc>(),
        ),
      ],
      child: ValueListenableBuilder<String>(
        valueListenable: AppTheme.themeNotifier,
        builder: (context, themeName, _) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              // Handle session expiry or logout from anywhere in the app
              if (state is AuthUnauthenticated) {
                // Do not interrupt SplashPage
                if (_router.routerDelegate.currentConfiguration.uri.toString() != '/') {
                  _router.go('/login');
                }
              }
            },
            child: MaterialApp.router(
              title: 'Sri Vinayaga Finance',
              theme: AppTheme.getTheme(themeName),
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
