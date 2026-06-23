import '../../domain/repositories/loan_repository.dart';
import '../../domain/entities/loan_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../datasources/loan_remote_datasource.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanRemoteDataSource remoteDataSource;

  LoanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LoanEntity>> addLoan(LoanEntity loan) async {
    try {
      final result = await remoteDataSource.addLoan(loan);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LoanEntity>>> getAllLoans() async {
    try {
      final result = await remoteDataSource.getAllLoans();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LoanEntity>>> getLoansByCustomer(String customerId) async {
    try {
      final result = await remoteDataSource.getLoansByCustomer(customerId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(const ServerFailure());
    }
  }
}
