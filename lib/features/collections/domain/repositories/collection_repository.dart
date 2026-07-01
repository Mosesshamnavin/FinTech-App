import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/collection_entity.dart';
import '../entities/reminder_entity.dart';
import '../entities/note_entity.dart';

abstract class CollectionRepository {
  /// Fetches the daily collection sheet for a specific line, area, and date.
  /// Returns a list of customers with their associated collection record for that date (if any).
  Future<Either<Failure, List<DailyCollectionCustomerEntity>>> getDailyCollections({
    required String date,
    String? lineId,
    String? areaId,
  });

  /// Records a payment or status update for a customer on a specific date.
  Future<Either<Failure, CollectionEntity>> addCollection({
    required String customerId,
    required double amount,
    required String date,
    String? notes,
    required String status,
  });

  /// Adds a reminder
  Future<Either<Failure, void>> addReminder(String date, String text);
  
  /// Fetches reminders
  Future<Either<Failure, List<ReminderEntity>>> getReminders();

  /// Adds a note
  Future<Either<Failure, void>> addNote(String text);
  
  /// Fetches notes
  Future<Either<Failure, List<NoteEntity>>> getNotes();
}
