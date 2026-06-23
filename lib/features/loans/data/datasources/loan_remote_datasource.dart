import '../../domain/entities/loan_entity.dart';
import '../../../../core/error/exceptions.dart';

class LoanRemoteDataSource {
  // In‑memory mock data source – stores loans for the lifetime of the app
  final List<LoanEntity> _loans = [];

  LoanRemoteDataSource() {
    // Add a few realistic mock loans
    _loans.addAll([
      LoanEntity(
        id: 'L001',
        customerId: 'C001',
        principalAmount: 10000,
        interestAmount: 2000,
        totalAmount: 12000,
        dailyDueAmount: 120,
        outstandingBalance: 12000,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        status: 'Active',
      ),
      LoanEntity(
        id: 'L002',
        customerId: 'C002',
        principalAmount: 15000,
        interestAmount: 3000,
        totalAmount: 18000,
        dailyDueAmount: 180,
        outstandingBalance: 18000,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'Completed',
      ),
      LoanEntity(
        id: 'L003',
        customerId: 'C003',
        principalAmount: 8000,
        interestAmount: 1200,
        totalAmount: 9200,
        dailyDueAmount: 92,
        outstandingBalance: 5000,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        status: 'Active',
      ),
    ]);
  }

  Future<LoanEntity> addLoan(LoanEntity loan) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    _loans.add(loan);
    return loan;
  }

  Future<List<LoanEntity>> getAllLoans() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<LoanEntity>.from(_loans);
  }

  Future<List<LoanEntity>> getLoansByCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _loans.where((l) => l.customerId == customerId).toList();
  }
}
