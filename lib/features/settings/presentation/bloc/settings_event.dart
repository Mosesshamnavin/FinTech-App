import '../../domain/entities/settings_entities.dart';

abstract class SettingsEvent {}

class LoadSettingsRequested extends SettingsEvent {}

class AddExpenseTypeSubmitted extends SettingsEvent {
  final ExpenseTypeEntity expenseType;
  AddExpenseTypeSubmitted(this.expenseType);
}

class AddInvestmentTypeSubmitted extends SettingsEvent {
  final InvestmentTypeEntity investmentType;
  AddInvestmentTypeSubmitted(this.investmentType);
}

class AddAreaSubmitted extends SettingsEvent {
  final AreaEntity area;
  AddAreaSubmitted(this.area);
}

class AddLineSubmitted extends SettingsEvent {
  final LineEntity line;
  AddLineSubmitted(this.line);
}
