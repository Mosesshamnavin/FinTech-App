import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/storage_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_cached_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/collections/data/datasources/collection_remote_datasource.dart';
import '../../features/collections/data/repositories/collection_repository_impl.dart';
import '../../features/collections/domain/repositories/collection_repository.dart';
import '../../features/collections/domain/usecases/add_collection_usecase.dart';
import '../../features/collections/domain/usecases/get_daily_collections_usecase.dart';
import '../../features/collections/presentation/bloc/collections_bloc.dart';
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer_usecase.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/presentation/bloc/customers_bloc.dart';
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/get_daily_summary_usecase.dart';
import '../../features/reports/domain/usecases/get_line_summary_usecase.dart';
import '../../features/reports/domain/usecases/get_new_customer_summary_usecase.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';

// Loans
import '../../features/loans/data/datasources/loan_remote_datasource.dart';
import '../../features/loans/data/repositories/loan_repository_impl.dart';
import '../../features/loans/domain/repositories/loan_repository.dart';
import '../../features/loans/domain/usecases/add_loan_usecase.dart';
import '../../features/loans/domain/usecases/get_all_loans_usecase.dart';
import '../../features/loans/domain/usecases/get_customer_loans_usecase.dart';
import '../../features/loans/presentation/bloc/loans_bloc.dart';

// Expenses
import '../../features/expenses/data/datasources/expense_remote_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/add_expense_usecase.dart';
import '../../features/expenses/domain/usecases/get_expenses_usecase.dart';
import '../../features/expenses/presentation/bloc/expenses_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ─── Core Services ────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => StorageService(sl()));

  // ─── Auth: Data Sources ───────────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // 🔄 SWAP THIS when Hasura server is ready:
  //   Replace MockAuthRemoteDataSourceImpl with HasuraAuthRemoteDataSourceImpl(sl())
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSourceImpl(),
  );

  // ─── Auth: Repository ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ─── Auth: Use Cases ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));

  // ─── Auth: BLoC ───────────────────────────────────────────────────────────
  // Registered as Factory so each route gets a fresh instance
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCachedUserUseCase: sl(),
    ),
  );
  // ─── Customers: Data Sources ──────────────────────────────────────────────
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => MockCustomerRemoteDataSourceImpl(),
  );

  // ─── Customers: Repository ────────────────────────────────────────────────
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );

  // ─── Customers: Use Cases ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomerUseCase(sl()));

  // ─── Customers: BLoC ──────────────────────────────────────────────────────
  sl.registerFactory(
    () => CustomersBloc(
      getCustomersUseCase: sl(),
      addCustomerUseCase: sl(),
    ),
  );

  // ─── Collections: Data Sources ────────────────────────────────────────────
  sl.registerLazySingleton<CollectionRemoteDataSource>(
    () => MockCollectionRemoteDataSourceImpl(),
  );

  // ─── Collections: Repository ──────────────────────────────────────────────
  sl.registerLazySingleton<CollectionRepository>(
    () => CollectionRepositoryImpl(
      collectionRemoteDataSource: sl(),
      customerRemoteDataSource: sl(),
    ),
  );

  // ─── Collections: Use Cases ───────────────────────────────────────────────
  sl.registerLazySingleton(() => GetDailyCollectionsUseCase(sl()));
  sl.registerLazySingleton(() => AddCollectionUseCase(sl()));

  // ─── Collections: BLoC ────────────────────────────────────────────────────
  sl.registerFactory(
    () => CollectionsBloc(
      getDailyCollectionsUseCase: sl(),
      addCollectionUseCase: sl(),
    ),
  );

  // ─── Reports: Data Sources ────────────────────────────────────────────────
  // ---------------------------------------------------------------------------
  // REPORTS FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => MockReportRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetDailySummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetLineSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetNewCustomerSummaryUseCase(sl()));

  sl.registerFactory(() => ReportBloc(
        getDailySummaryUseCase: sl(),
        getLineSummaryUseCase: sl(),
        getNewCustomerSummaryUseCase: sl(),
      ));

  // ---------------------------------------------------------------------------
  // LOANS FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => LoanRemoteDataSource());
  sl.registerLazySingleton<LoanRepository>(
    () => LoanRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => AddLoanUseCase(sl()));
  sl.registerLazySingleton(() => GetAllLoansUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerLoansUseCase(sl()));

  sl.registerFactory(() => LoansBloc(
        getAllLoans: sl(),
        getCustomerLoans: sl(),
        addLoan: sl(),
      ));

  // ---------------------------------------------------------------------------
  // EXPENSES FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => ExpenseRemoteDataSource());
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => AddExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));

  sl.registerFactory(() => ExpensesBloc(
        getExpenses: sl(),
        addExpense: sl(),
      ));
}
