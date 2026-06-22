import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_collection_usecase.dart';
import '../../domain/usecases/get_daily_collections_usecase.dart';
import 'collections_event.dart';
import 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetDailyCollectionsUseCase getDailyCollectionsUseCase;
  final AddCollectionUseCase addCollectionUseCase;

  CollectionsBloc({
    required this.getDailyCollectionsUseCase,
    required this.addCollectionUseCase,
  }) : super(const CollectionsInitial()) {
    on<LoadDailyCollectionsRequested>(_onLoadDailyCollectionsRequested);
    on<AddCollectionRecordSubmitted>(_onAddCollectionRecordSubmitted);
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
}
