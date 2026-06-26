import '../../domain/entities/settings_entities.dart';

abstract class SettingsEvent {}

class LoadSettingsRequested extends SettingsEvent {}

class AddExpenseTypeSubmitted extends SettingsEvent {
  final ExpenseTypeEntity expenseType;
  AddExpenseTypeSubmitted(this.expenseType);
}

class UpdateExpenseTypeSubmitted extends SettingsEvent {
  final ExpenseTypeEntity expenseType;
  UpdateExpenseTypeSubmitted(this.expenseType);
}

class DeleteExpenseTypeSubmitted extends SettingsEvent {
  final String id;
  DeleteExpenseTypeSubmitted(this.id);
}

class AddInvestmentTypeSubmitted extends SettingsEvent {
  final InvestmentTypeEntity investmentType;
  AddInvestmentTypeSubmitted(this.investmentType);
}

class UpdateInvestmentTypeSubmitted extends SettingsEvent {
  final InvestmentTypeEntity investmentType;
  UpdateInvestmentTypeSubmitted(this.investmentType);
}

class DeleteInvestmentTypeSubmitted extends SettingsEvent {
  final String id;
  DeleteInvestmentTypeSubmitted(this.id);
}

class AddAreaSubmitted extends SettingsEvent {
  final AreaEntity area;
  AddAreaSubmitted(this.area);
}

class AddLineSubmitted extends SettingsEvent {
  final LineEntity line;
  AddLineSubmitted(this.line);
}
