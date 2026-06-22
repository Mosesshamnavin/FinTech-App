import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportEntity>> getDailySummary({
    required String date,
    String? lineType,
    String? line,
  });

  Future<Either<Failure, ReportEntity>> getLineSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  });

  Future<Either<Failure, ReportEntity>> getNewCustomerSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  });
}
