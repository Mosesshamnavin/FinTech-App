import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/settings_usecases.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetExpenseTypesUseCase getExpenseTypes;
  final AddExpenseTypeUseCase addExpenseType;
  final UpdateExpenseTypeUseCase updateExpenseType;
  final DeleteExpenseTypeUseCase deleteExpenseType;
  
  final GetInvestmentTypesUseCase getInvestmentTypes;
  final AddInvestmentTypeUseCase addInvestmentType;
  final UpdateInvestmentTypeUseCase updateInvestmentType;
  final DeleteInvestmentTypeUseCase deleteInvestmentType;
  
  final GetAreasUseCase getAreas;
  final AddAreaUseCase addArea;
  final UpdateAreaUseCase updateArea;
  final DeleteAreaUseCase deleteArea;
  
  final GetLinesUseCase getLines;
  final AddLineUseCase addLine;
  final UpdateLineUseCase updateLine;
  final DeleteLineUseCase deleteLine;

  SettingsBloc({
    required this.getExpenseTypes,
    required this.addExpenseType,
    required this.updateExpenseType,
    required this.deleteExpenseType,
    required this.getInvestmentTypes,
    required this.addInvestmentType,
    required this.updateInvestmentType,
    required this.deleteInvestmentType,
    required this.getAreas,
    required this.addArea,
    required this.updateArea,
    required this.deleteArea,
    required this.getLines,
    required this.addLine,
    required this.updateLine,
    required this.deleteLine,
  }) : super(SettingsInitial()) {
    on<LoadSettingsRequested>(_onLoadSettings);
    on<AddExpenseTypeSubmitted>(_onAddExpenseType);
    on<UpdateExpenseTypeSubmitted>(_onUpdateExpenseType);
    on<DeleteExpenseTypeSubmitted>(_onDeleteExpenseType);
    on<AddInvestmentTypeSubmitted>(_onAddInvestmentType);
    on<UpdateInvestmentTypeSubmitted>(_onUpdateInvestmentType);
    on<DeleteInvestmentTypeSubmitted>(_onDeleteInvestmentType);
    on<AddAreaSubmitted>(_onAddArea);
    on<UpdateAreaSubmitted>(_onUpdateArea);
    on<DeleteAreaSubmitted>(_onDeleteArea);
    on<AddLineSubmitted>(_onAddLine);
    on<UpdateLineSubmitted>(_onUpdateLine);
    on<DeleteLineSubmitted>(_onDeleteLine);
  }

  Future<void> _onLoadSettings(LoadSettingsRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    final expenseTypesResult = await getExpenseTypes(NoParams());
    final investmentTypesResult = await getInvestmentTypes(NoParams());
    final areasResult = await getAreas(NoParams());
    final linesResult = await getLines(NoParams());

    // Instead of failing entirely if one request fails, we accumulate what we can.
    // If all fail, then we emit error. If at least one succeeds, we show partial data.
    if (expenseTypesResult.isRight || investmentTypesResult.isRight || areasResult.isRight || linesResult.isRight) {
      emit(SettingsLoaded(
        expenseTypes: expenseTypesResult.getOrNull() ?? [],
        investmentTypes: investmentTypesResult.getOrNull() ?? [],
        areas: areasResult.getOrNull() ?? [],
        lines: linesResult.getOrNull() ?? [],
      ));
    } else {
      emit(const SettingsError('Failed to load settings. Please check your connection.'));
    }
  }

  Future<void> _onAddExpenseType(AddExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await addExpenseType(event.expenseType);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onUpdateExpenseType(UpdateExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await updateExpenseType(event.expenseType);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onDeleteExpenseType(DeleteExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await deleteExpenseType(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onAddInvestmentType(AddInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await addInvestmentType(event.investmentType);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onUpdateInvestmentType(UpdateInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await updateInvestmentType(event.investmentType);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onDeleteInvestmentType(DeleteInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await deleteInvestmentType(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onAddArea(AddAreaSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await addArea(event.area);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onUpdateArea(UpdateAreaSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await updateArea(event.area);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onDeleteArea(DeleteAreaSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await deleteArea(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onAddLine(AddLineSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await addLine(event.line);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onUpdateLine(UpdateLineSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await updateLine(event.line);
    result.fold((f) {
      print('Error in _onUpdateLine: ${f.message}');
      emit(SettingsError(f.message));
    }, (_) => add(LoadSettingsRequested()));
  }

  Future<void> _onDeleteLine(DeleteLineSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await deleteLine(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) => add(LoadSettingsRequested()));
  }
}
