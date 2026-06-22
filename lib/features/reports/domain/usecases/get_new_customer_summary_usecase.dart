import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetNewCustomerSummaryUseCase extends UseCase<ReportEntity, NewCustomerSummaryParams> {
  final ReportRepository repository;

  GetNewCustomerSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, ReportEntity>> call(NewCustomerSummaryParams params) {
    if (params.fromDate.trim().isEmpty || params.toDate.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('From and To dates are required.')));
    }
    return repository.getNewCustomerSummary(
      fromDate: params.fromDate,
      toDate: params.toDate,
      lineType: params.lineType,
      line: params.line,
      all: params.all,
    );
  }
}

class NewCustomerSummaryParams extends Equatable {
  final String fromDate;
  final String toDate;
  final String? lineType;
  final String? line;
  final bool all;

  const NewCustomerSummaryParams({
    required this.fromDate,
    required this.toDate,
    this.lineType,
    this.line,
    this.all = true,
  });

  @override
  List<Object?> get props => [fromDate, toDate, lineType, line, all];
}
