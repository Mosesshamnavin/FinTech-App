import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/collection_entity.dart';
import '../repositories/collection_repository.dart';

class GetDailyCollectionsUseCase extends UseCase<List<DailyCollectionCustomerEntity>, GetDailyCollectionsParams> {
  final CollectionRepository repository;

  GetDailyCollectionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DailyCollectionCustomerEntity>>> call(GetDailyCollectionsParams params) {
    if (params.date.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Date is required.')));
    }
    return repository.getDailyCollections(
      date: params.date.trim(),
      lineId: params.lineId,
      areaId: params.areaId,
    );
  }
}

class GetDailyCollectionsParams extends Equatable {
  final String date;
  final String? lineId;
  final String? areaId;

  const GetDailyCollectionsParams({
    required this.date,
    this.lineId,
    this.areaId,
  });

  @override
  List<Object?> get props => [date, lineId, areaId];
}
