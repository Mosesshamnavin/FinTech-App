import '../../../../core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/collection_repository.dart';

class AddReminderUseCase implements UseCase<void, AddReminderParams> {
  final CollectionRepository repository;

  AddReminderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddReminderParams params) async {
    return await repository.addReminder(params.date, params.text);
  }
}

class AddReminderParams {
  final String date;
  final String text;

  AddReminderParams({
    required this.date,
    required this.text,
  });
}
