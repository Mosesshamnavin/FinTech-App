import 'package:equatable/equatable.dart';

class LoanEntity extends Equatable {
  final String id;
  final String customerId;
  final double principalAmount;
  final double interestAmount;
  final double totalAmount;
  final double dailyDueAmount;
  final double outstandingBalance;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // e.g., 'Active', 'Completed', 'BadDebt'

  const LoanEntity({
    required this.id,
    required this.customerId,
    required this.principalAmount,
    required this.interestAmount,
    required this.totalAmount,
    required this.dailyDueAmount,
    required this.outstandingBalance,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        principalAmount,
        interestAmount,
        totalAmount,
        dailyDueAmount,
        outstandingBalance,
        startDate,
        endDate,
        status,
      ];
}
