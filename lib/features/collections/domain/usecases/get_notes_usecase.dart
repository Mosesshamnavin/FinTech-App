import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/note_entity.dart';
import '../repositories/collection_repository.dart';

class GetNotesUseCase implements UseCase<List<NoteEntity>, NoParams> {
  final CollectionRepository repository;

  GetNotesUseCase(this.repository);

  @override
  Future<Either<Failure, List<NoteEntity>>> call(NoParams params) async {
    return await repository.getNotes();
  }
}
