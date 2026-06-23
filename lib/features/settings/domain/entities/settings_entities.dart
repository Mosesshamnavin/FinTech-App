class ExpenseTypeEntity {
  final String id;
  final String name;
  final bool isActive;

  ExpenseTypeEntity({
    required this.id,
    required this.name,
    this.isActive = true,
  });
}

class InvestmentTypeEntity {
  final String id;
  final String name;
  final bool isActive;

  InvestmentTypeEntity({
    required this.id,
    required this.name,
    this.isActive = true,
  });
}

class AreaEntity {
  final String id;
  final String name;
  final String lineId;

  AreaEntity({
    required this.id,
    required this.name,
    required this.lineId,
  });
}

class LineEntity {
  final String id;
  final String name;
  final String type;
  final double interestPerHundred;
  final double billAmountPerHundred;
  final int noOfInstall;
  final int badLoanDays;
  final bool closeLoanManually;
  final bool enablePenalty;
  final bool keepPaidCustomer;

  LineEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.interestPerHundred,
    required this.billAmountPerHundred,
    required this.noOfInstall,
    required this.badLoanDays,
    required this.closeLoanManually,
    required this.enablePenalty,
    required this.keepPaidCustomer,
  });
}
