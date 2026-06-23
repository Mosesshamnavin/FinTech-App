import '../../domain/entities/settings_entities.dart';

class SettingsRemoteDataSource {
  final List<ExpenseTypeEntity> _expenseTypes = [
    ExpenseTypeEntity(id: 'E01', name: 'Food', isActive: true),
    ExpenseTypeEntity(id: 'E02', name: 'Petrol', isActive: true),
  ];

  final List<InvestmentTypeEntity> _investmentTypes = [
    InvestmentTypeEntity(id: 'I01', name: 'Fixed Deposit', isActive: true),
  ];

  final List<AreaEntity> _areas = [
    AreaEntity(id: 'A01', name: 'South Street', lineId: 'L01'),
  ];

  final List<LineEntity> _lines = [
    LineEntity(
      id: 'L01',
      name: 'Main Bazar Line',
      type: 'Daily',
      interestPerHundred: 2.0,
      billAmountPerHundred: 100.0,
      noOfInstall: 100,
      badLoanDays: 30,
      closeLoanManually: false,
      enablePenalty: true,
      keepPaidCustomer: false,
    ),
  ];

  Future<ExpenseTypeEntity> addExpenseType(ExpenseTypeEntity expenseType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _expenseTypes.add(expenseType);
    return expenseType;
  }

  Future<List<ExpenseTypeEntity>> getExpenseTypes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _expenseTypes;
  }

  Future<InvestmentTypeEntity> addInvestmentType(InvestmentTypeEntity investmentType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _investmentTypes.add(investmentType);
    return investmentType;
  }

  Future<List<InvestmentTypeEntity>> getInvestmentTypes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _investmentTypes;
  }

  Future<AreaEntity> addArea(AreaEntity area) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _areas.add(area);
    return area;
  }

  Future<List<AreaEntity>> getAreas() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _areas;
  }

  Future<LineEntity> addLine(LineEntity line) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _lines.add(line);
    return line;
  }

  Future<List<LineEntity>> getLines() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _lines;
  }
}
