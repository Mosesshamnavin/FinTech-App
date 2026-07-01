import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../repositories/collection_repository.dart';

class AddNoteUseCase implements UseCase<void, AddNoteParams> {
  final CollectionRepository repository;

  AddNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddNoteParams params) async {
    if (params.text.trim().isEmpty) {
      return Future.value(Left(const ValidationFailure('Note text cannot be empty.')));
    }
    return await repository.addNote(params.text);
  }
}

class AddNoteParams extends Equatable {
  final String text;

  const AddNoteParams({required this.text});

  @override
  List<Object?> get props => [text];
}
