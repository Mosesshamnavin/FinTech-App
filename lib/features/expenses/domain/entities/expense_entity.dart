class ExpenseEntity {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isInvestment;
  final bool isOnline;
  final String? lineId;

  ExpenseEntity({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.isInvestment,
    required this.isOnline,
    this.lineId,
  });
}
