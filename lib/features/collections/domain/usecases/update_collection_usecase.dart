import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/collection_repository.dart';

class UpdateCollectionUseCase implements UseCase<void, UpdateCollectionParams> {
  final CollectionRepository repository;

  UpdateCollectionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCollectionParams params) async {
    return await repository.updateCollection(
      id: params.id,
      amount: params.amount,
      notes: params.notes,
      status: params.status,
    );
  }
}

class UpdateCollectionParams extends Equatable {
  final String id;
  final double amount;
  final String? notes;
  final String status;

  const UpdateCollectionParams({
    required this.id,
    required this.amount,
    this.notes,
    required this.status,
  });

  @override
  List<Object?> get props => [id, amount, notes, status];
}
