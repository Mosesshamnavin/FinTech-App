import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesParams {
  final DateTime from;
  final DateTime to;
  final bool isInvestment;
  final String? lineId;

  GetExpensesParams({
    required this.from,
    required this.to,
    required this.isInvestment,
    this.lineId,
  });
}

class GetExpensesUseCase extends UseCase<List<ExpenseEntity>, GetExpensesParams> {
  final ExpenseRepository repository;
  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(GetExpensesParams params) async {
    return repository.getExpenses(
      from: params.from,
      to: params.to,
      isInvestment: params.isInvestment,
      lineId: params.lineId,
    );
  }
}
