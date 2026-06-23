import 'package:equatable/equatable.dart';
import '../../domain/entities/settings_entities.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final List<ExpenseTypeEntity> expenseTypes;
  final List<InvestmentTypeEntity> investmentTypes;
  final List<AreaEntity> areas;
  final List<LineEntity> lines;

  const SettingsLoaded({
    required this.expenseTypes,
    required this.investmentTypes,
    required this.areas,
    required this.lines,
  });

  @override
  List<Object?> get props => [expenseTypes, investmentTypes, areas, lines];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
