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
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer_usecase.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/presentation/bloc/customers_bloc.dart';

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
}
