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
  
  final GetLinesUseCase getLines;
  final AddLineUseCase addLine;

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
    required this.getLines,
    required this.addLine,
  }) : super(SettingsInitial()) {
    on<LoadSettingsRequested>(_onLoadSettings);
    on<AddExpenseTypeSubmitted>(_onAddExpenseType);
    on<UpdateExpenseTypeSubmitted>(_onUpdateExpenseType);
    on<DeleteExpenseTypeSubmitted>(_onDeleteExpenseType);
    on<AddInvestmentTypeSubmitted>(_onAddInvestmentType);
    on<UpdateInvestmentTypeSubmitted>(_onUpdateInvestmentType);
    on<DeleteInvestmentTypeSubmitted>(_onDeleteInvestmentType);
    on<AddAreaSubmitted>(_onAddArea);
    on<AddLineSubmitted>(_onAddLine);
  }

  Future<void> _onLoadSettings(LoadSettingsRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    final expenseTypesResult = await getExpenseTypes(NoParams());
    final investmentTypesResult = await getInvestmentTypes(NoParams());
    final areasResult = await getAreas(NoParams());
    final linesResult = await getLines(NoParams());

    // Basic aggregation - if any fail, we could emit an error, or just show what we have.
    // For simplicity, we assume they all succeed or fail together.
    if (expenseTypesResult.isRight && investmentTypesResult.isRight && areasResult.isRight && linesResult.isRight) {
      emit(SettingsLoaded(
        expenseTypes: expenseTypesResult.getOrNull() ?? [],
        investmentTypes: investmentTypesResult.getOrNull() ?? [],
        areas: areasResult.getOrNull() ?? [],
        lines: linesResult.getOrNull() ?? [],
      ));
    } else {
      emit(const SettingsError('Failed to load some settings'));
    }
  }

  Future<void> _onAddExpenseType(AddExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await addExpenseType(event.expenseType);
    add(LoadSettingsRequested());
  }

  Future<void> _onUpdateExpenseType(UpdateExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await updateExpenseType(event.expenseType);
    add(LoadSettingsRequested());
  }

  Future<void> _onDeleteExpenseType(DeleteExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await deleteExpenseType(event.id);
    add(LoadSettingsRequested());
  }

  Future<void> _onAddInvestmentType(AddInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await addInvestmentType(event.investmentType);
    add(LoadSettingsRequested());
  }

  Future<void> _onUpdateInvestmentType(UpdateInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await updateInvestmentType(event.investmentType);
    add(LoadSettingsRequested());
  }

  Future<void> _onDeleteInvestmentType(DeleteInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await deleteInvestmentType(event.id);
    add(LoadSettingsRequested());
  }

  Future<void> _onAddArea(AddAreaSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await addArea(event.area);
    add(LoadSettingsRequested());
  }

  Future<void> _onAddLine(AddLineSubmitted event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    await addLine(event.line);
    add(LoadSettingsRequested());
  }
}
