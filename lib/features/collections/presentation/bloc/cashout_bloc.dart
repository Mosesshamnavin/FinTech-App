import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cashout_usecases.dart';
import 'cashout_event.dart';
import 'cashout_state.dart';

class CashOutBloc extends Bloc<CashOutEvent, CashOutState> {
  final GetActiveCashOutsUseCase getActiveCashOuts;
  final GetCashOutHistoryUseCase getCashOutHistory;
  final AddCashOutUseCase addCashOut;
  final SettleCashOutUseCase settleCashOut;

  LoadCashOutsRequested? _lastLoadEvent;

  CashOutBloc({
    required this.getActiveCashOuts,
    required this.getCashOutHistory,
    required this.addCashOut,
    required this.settleCashOut,
  }) : super(CashOutInitial()) {
    on<LoadCashOutsRequested>(_onLoadCashOuts);
    on<AddCashOutSubmitted>(_onAddCashOut);
    on<SettleCashOutSubmitted>(_onSettleCashOut);
  }

  Future<void> _onLoadCashOuts(LoadCashOutsRequested event, Emitter<CashOutState> emit) async {
    _lastLoadEvent = event;
    emit(CashOutLoading());

    final activeResult = await getActiveCashOuts(event.lineId);
    final historyResult = await getCashOutHistory(event.lineId);

    if (activeResult.isRight && historyResult.isRight) {
      emit(CashOutLoaded(
        activeCashOuts: activeResult.getOrNull() ?? [],
        historyCashOuts: historyResult.getOrNull() ?? [],
      ));
    } else {
      final error = activeResult.isLeft
          ? activeResult.fold((f) => f.message, (_) => 'Unknown error')
          : historyResult.fold((f) => f.message, (_) => 'Unknown error');
      emit(CashOutError(error));
    }
  }

  Future<void> _onAddCashOut(AddCashOutSubmitted event, Emitter<CashOutState> emit) async {
    emit(CashOutLoading());
    final result = await addCashOut(event.cashOut);
    
    result.fold(
      (failure) => emit(CashOutError(failure.message)),
      (_) {
        // Reload with last query params
        if (_lastLoadEvent != null) {
          add(_lastLoadEvent!);
        } else {
          add(const LoadCashOutsRequested());
        }
      },
    );
  }

  Future<void> _onSettleCashOut(SettleCashOutSubmitted event, Emitter<CashOutState> emit) async {
    emit(CashOutLoading());
    final result = await settleCashOut(event.cashOutId);

    result.fold(
      (failure) => emit(CashOutError(failure.message)),
      (_) {
        if (_lastLoadEvent != null) {
          add(_lastLoadEvent!);
        } else {
          add(const LoadCashOutsRequested());
        }
      },
    );
  }
}
