import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_collection_usecase.dart';
import '../../domain/usecases/get_daily_collections_usecase.dart';
import '../../domain/usecases/add_reminder_usecase.dart';
import '../../domain/usecases/get_reminders_usecase.dart';
import '../../domain/usecases/add_note_usecase.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'collections_event.dart';
import 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetDailyCollectionsUseCase getDailyCollectionsUseCase;
  final AddCollectionUseCase addCollectionUseCase;
  final AddReminderUseCase addReminderUseCase;
  final GetRemindersUseCase getRemindersUseCase;

  final AddNoteUseCase addNoteUseCase;
  final GetNotesUseCase getNotesUseCase;

  CollectionsBloc({
    required this.getDailyCollectionsUseCase,
    required this.addCollectionUseCase,
    required this.addReminderUseCase,
    required this.getRemindersUseCase,
    required this.addNoteUseCase,
    required this.getNotesUseCase,
  }) : super(const CollectionsInitial()) {
    on<LoadDailyCollectionsRequested>(_onLoadDailyCollectionsRequested);
    on<AddCollectionRecordSubmitted>(_onAddCollectionRecordSubmitted);
    on<AddReminderSubmitted>(_onAddReminderSubmitted);
    on<LoadRemindersRequested>(_onLoadRemindersRequested);
    on<LoadNotesRequested>(_onLoadNotesRequested);
    on<AddNoteSubmitted>(_onAddNoteSubmitted);
  }

  Future<void> _onLoadDailyCollectionsRequested(
    LoadDailyCollectionsRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const DailyCollectionsLoading());
    
    final result = await getDailyCollectionsUseCase(
      GetDailyCollectionsParams(
        date: event.date,
        lineId: event.lineId,
        areaId: event.areaId,
      ),
    );

    result.fold(
      (failure) => emit(DailyCollectionsError(failure.message)),
      (dailyList) => emit(DailyCollectionsLoaded(dailyList)),
    );
  }

  Future<void> _onAddCollectionRecordSubmitted(
    AddCollectionRecordSubmitted event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const AddCollectionActionLoading());
    
    final result = await addCollectionUseCase(
      AddCollectionParams(
        customerId: event.customerId,
        amount: event.amount,
        date: event.date,
        notes: event.notes,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(AddCollectionActionError(failure.message)),
      (collection) => emit(const AddCollectionActionSuccess()),
    );
  }

  Future<void> _onAddReminderSubmitted(
    AddReminderSubmitted event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const AddReminderActionLoading());
    
    final result = await addReminderUseCase(
      AddReminderParams(
        date: event.date,
        text: event.text,
      ),
    );

    result.fold(
      (failure) => emit(AddReminderActionError(failure.message)),
      (_) => emit(const AddReminderActionSuccess()),
    );
  }

  Future<void> _onLoadRemindersRequested(
    LoadRemindersRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const RemindersLoading());
    
    final result = await getRemindersUseCase(NoParams());

    result.fold(
      (failure) => emit(RemindersError(failure.message)),
      (reminders) => emit(RemindersLoaded(reminders)),
    );
  }

  Future<void> _onLoadNotesRequested(
    LoadNotesRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const NotesLoading());
    
    final result = await getNotesUseCase(NoParams());

    result.fold(
      (failure) => emit(NotesError(failure.message)),
      (notes) => emit(NotesLoaded(notes)),
    );
  }

  Future<void> _onAddNoteSubmitted(
    AddNoteSubmitted event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const AddNoteActionLoading());
    
    final result = await addNoteUseCase(
      AddNoteParams(text: event.text),
    );

    result.fold(
      (failure) => emit(AddNoteActionError(failure.message)),
      (_) => emit(const AddNoteActionSuccess()),
    );
  }
}
