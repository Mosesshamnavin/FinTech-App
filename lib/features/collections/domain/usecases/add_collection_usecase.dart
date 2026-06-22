import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/collection_entity.dart';
import '../repositories/collection_repository.dart';

class AddCollectionUseCase extends UseCase<CollectionEntity, AddCollectionParams> {
  final CollectionRepository repository;

  AddCollectionUseCase(this.repository);

  @override
  Future<Either<Failure, CollectionEntity>> call(AddCollectionParams params) {
    if (params.customerId.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Customer is required.')));
    }
    if (params.date.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Date is required.')));
    }
    if (params.amount <= 0 && params.status == 'paid') {
      return Future.value(Left(const ValidationFailure('Amount must be greater than zero for paid status.')));
    }

    return repository.addCollection(
      customerId: params.customerId.trim(),
      amount: params.amount,
      date: params.date.trim(),
      notes: params.notes?.trim(),
      status: params.status.trim(),
    );
  }
}

class AddCollectionParams extends Equatable {
  final String customerId;
  final double amount;
  final String date;
  final String? notes;
  final String status;

  const AddCollectionParams({
    required this.customerId,
    required this.amount,
    required this.date,
    this.notes,
    required this.status,
  });

  @override
  List<Object?> get props => [customerId, amount, date, notes, status];
}
