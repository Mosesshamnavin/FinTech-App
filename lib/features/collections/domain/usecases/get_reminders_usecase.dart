import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/reminder_entity.dart';
import '../repositories/collection_repository.dart';

class GetRemindersUseCase implements UseCase<List<ReminderEntity>, NoParams> {
  final CollectionRepository repository;

  GetRemindersUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReminderEntity>>> call(NoParams params) async {
    return await repository.getReminders();
  }
}
