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

  final GetLineTypesUseCase getLineTypes;
  final AddLineTypeUseCase addLineType;
  final UpdateLineTypeUseCase updateLineType;
  final DeleteLineTypeUseCase deleteLineType;
  
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
    required this.getLineTypes,
    required this.addLineType,
    required this.updateLineType,
    required this.deleteLineType,
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
    on<AddLineTypeSubmitted>(_onAddLineType);
    on<UpdateLineTypeSubmitted>(_onUpdateLineType);
    on<DeleteLineTypeSubmitted>(_onDeleteLineType);
    on<AddLineSubmitted>(_onAddLine);
    on<UpdateLineSubmitted>(_onUpdateLine);
    on<DeleteLineSubmitted>(_onDeleteLine);
  }

  Future<void> _onLoadSettings(LoadSettingsRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    final expenseTypesResult = await getExpenseTypes(NoParams());
    final investmentTypesResult = await getInvestmentTypes(NoParams());
    final areasResult = await getAreas(NoParams());
    final lineTypesResult = await getLineTypes(NoParams());
    final linesResult = await getLines(NoParams());

    // Log failures for debugging
    expenseTypesResult.fold((f) => print('Expense Types Load Failure: ${f.message}'), (_) {});
    investmentTypesResult.fold((f) => print('Investment Types Load Failure: ${f.message}'), (_) {});
    areasResult.fold((f) => print('Areas Load Failure: ${f.message}'), (_) {});
    lineTypesResult.fold((f) => print('Line Types Load Failure: ${f.message}'), (_) {});
    linesResult.fold((f) => print('Lines Load Failure: ${f.message}'), (_) {});

    // Instead of failing entirely if one request fails, we accumulate what we can.
    // If all fail, then we emit error. If at least one succeeds, we show partial data.
    if (expenseTypesResult.isRight || investmentTypesResult.isRight || areasResult.isRight || lineTypesResult.isRight || linesResult.isRight) {
      emit(SettingsLoaded(
        expenseTypes: expenseTypesResult.getOrNull() ?? [],
        investmentTypes: investmentTypesResult.getOrNull() ?? [],
        areas: areasResult.getOrNull() ?? [],
        lineTypes: lineTypesResult.getOrNull() ?? [],
        lines: linesResult.getOrNull() ?? [],
      ));
    } else {
      emit(const SettingsError('Failed to load settings. Please check your connection.'));
    }
  }

  Future<void> _onAddLineType(AddLineTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await addLineType(event.lineType);
    result.fold((f) => emit(SettingsError(f.message)), (newItem) {
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: [...currentState.lineTypes, newItem],
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onUpdateLineType(UpdateLineTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await updateLineType(event.lineType);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.lineTypes.map((e) => e.id == event.lineType.id ? event.lineType : e).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: updatedList,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onDeleteLineType(DeleteLineTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await deleteLineType(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.lineTypes.where((e) => e.id != event.id).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: updatedList,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onAddExpenseType(AddExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await addExpenseType(event.expenseType);
    result.fold((f) => emit(SettingsError(f.message)), (newItem) {
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          expenseTypes: [...currentState.expenseTypes, newItem],
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onUpdateExpenseType(UpdateExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await updateExpenseType(event.expenseType);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.expenseTypes.map((e) => e.id == event.expenseType.id ? event.expenseType : e).toList();
        emit(SettingsLoaded(
          expenseTypes: updatedList,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onDeleteExpenseType(DeleteExpenseTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await deleteExpenseType(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.expenseTypes.where((e) => e.id != event.id).toList();
        emit(SettingsLoaded(
          expenseTypes: updatedList,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onAddInvestmentType(AddInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await addInvestmentType(event.investmentType);
    result.fold((f) => emit(SettingsError(f.message)), (newItem) {
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: [...currentState.investmentTypes, newItem],
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onUpdateInvestmentType(UpdateInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await updateInvestmentType(event.investmentType);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.investmentTypes.map((e) => e.id == event.investmentType.id ? event.investmentType : e).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: updatedList,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onDeleteInvestmentType(DeleteInvestmentTypeSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await deleteInvestmentType(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.investmentTypes.where((e) => e.id != event.id).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: updatedList,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onAddArea(AddAreaSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await addArea(event.area);
    result.fold((f) => emit(SettingsError(f.message)), (newItem) {
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: [...currentState.areas, newItem],
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onUpdateArea(UpdateAreaSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await updateArea(event.area);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.areas.map((e) => e.id == event.area.id ? event.area : e).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: updatedList,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onDeleteArea(DeleteAreaSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await deleteArea(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.areas.where((e) => e.id != event.id).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: updatedList,
          lineTypes: currentState.lineTypes,
          lines: currentState.lines,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onAddLine(AddLineSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await addLine(event.line);
    result.fold((f) => emit(SettingsError(f.message)), (newItem) {
      if (currentState is SettingsLoaded) {
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: [...currentState.lines, newItem],
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onUpdateLine(UpdateLineSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await updateLine(event.line);
    result.fold((f) {
      print('Error in _onUpdateLine: ${f.message}');
      emit(SettingsError(f.message));
    }, (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.lines.map((e) => e.id == event.line.id ? event.line : e).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: updatedList,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }

  Future<void> _onDeleteLine(DeleteLineSubmitted event, Emitter<SettingsState> emit) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await deleteLine(event.id);
    result.fold((f) => emit(SettingsError(f.message)), (_) {
      if (currentState is SettingsLoaded) {
        final updatedList = currentState.lines.where((e) => e.id != event.id).toList();
        emit(SettingsLoaded(
          expenseTypes: currentState.expenseTypes,
          investmentTypes: currentState.investmentTypes,
          areas: currentState.areas,
          lineTypes: currentState.lineTypes,
          lines: updatedList,
        ));
      } else {
        add(LoadSettingsRequested());
      }
    });
  }
}
