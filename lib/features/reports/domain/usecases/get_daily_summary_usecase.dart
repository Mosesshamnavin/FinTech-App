import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetDailySummaryUseCase extends UseCase<ReportEntity, DailySummaryParams> {
  final ReportRepository repository;

  GetDailySummaryUseCase(this.repository);

  @override
  Future<Either<Failure, ReportEntity>> call(DailySummaryParams params) {
    if (params.date.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Date is required.')));
    }
    return repository.getDailySummary(
      date: params.date,
      lineType: params.lineType,
      line: params.line,
    );
  }
}

class DailySummaryParams extends Equatable {
  final String date;
  final String? lineType;
  final String? line;

  const DailySummaryParams({
    required this.date,
    this.lineType,
    this.line,
  });

  @override
  List<Object?> get props => [date, lineType, line];
}
