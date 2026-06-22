import '../../domain/entities/report_entity.dart';

abstract class ReportRemoteDataSource {
  Future<ReportEntity> getDailySummary({
    required String date,
    String? lineType,
    String? line,
  });

  Future<ReportEntity> getLineSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  });

  Future<ReportEntity> getNewCustomerSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  });
}

class MockReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  static const _mockDelay = Duration(milliseconds: 600);

  @override
  Future<ReportEntity> getDailySummary({
    required String date,
    String? lineType,
    String? line,
  }) async {
    await Future.delayed(_mockDelay);

    final lineLabel = line ?? 'All Lines';

    return ReportEntity(
      title: 'Daily Summary — $date',
      summaryFields: {
        'Line': lineLabel,
        'Total Customers': '12',
        'Collected': '₹8,500',
        'Pending': '₹3,500',
        'Cash': '₹6,000',
        'Online': '₹2,500',
      },
      columns: ['Customer', 'Line', 'Amount', 'Status'],
      rows: [
        {'Customer': 'Ramesh Kumar', 'Line': 'Line 1', 'Amount': '₹500', 'Status': 'Paid'},
        {'Customer': 'Suresh Babu', 'Line': 'Line 1', 'Amount': '₹1,000', 'Status': 'Paid'},
        {'Customer': 'Anitha Reddy', 'Line': 'Line 2', 'Amount': '₹750', 'Status': 'Paid'},
        {'Customer': 'Lakshmi Devi', 'Line': 'Line 1', 'Amount': '₹2,000', 'Status': 'Paid'},
        {'Customer': 'Vijay Kumar', 'Line': 'Line 2', 'Amount': '₹1,250', 'Status': 'Paid'},
        {'Customer': 'Priya Sharma', 'Line': 'Line 3', 'Amount': '₹1,500', 'Status': 'Paid'},
        {'Customer': 'Gopal Reddy', 'Line': 'Line 1', 'Amount': '₹1,500', 'Status': 'Paid'},
        {'Customer': 'Meena Kumari', 'Line': 'Line 2', 'Amount': '₹0', 'Status': 'Pending'},
        {'Customer': 'Ravi Shankar', 'Line': 'Line 3', 'Amount': '₹0', 'Status': 'Pending'},
        {'Customer': 'Kavitha Nair', 'Line': 'Line 1', 'Amount': '₹0', 'Status': 'Skipped'},
        {'Customer': 'Arun Prasad', 'Line': 'Line 2', 'Amount': '₹0', 'Status': 'Pending'},
        {'Customer': 'Divya Mohan', 'Line': 'Line 3', 'Amount': '₹0', 'Status': 'Pending'},
      ],
    );
  }

  @override
  Future<ReportEntity> getLineSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  }) async {
    await Future.delayed(_mockDelay);

    return ReportEntity(
      title: 'Line Summary — $fromDate to $toDate',
      summaryFields: {
        'Total Lines': '3',
        'Total Loan Given': '₹1,50,000',
        'Total Collected': '₹85,000',
        'Outstanding': '₹65,000',
        'Active Customers': '28',
      },
      columns: ['Line', 'Loan Given', 'Collected', 'Outstanding', 'Customers'],
      rows: [
        {'Line': 'Line 1', 'Loan Given': '₹60,000', 'Collected': '₹35,000', 'Outstanding': '₹25,000', 'Customers': '10'},
        {'Line': 'Line 2', 'Loan Given': '₹50,000', 'Collected': '₹28,000', 'Outstanding': '₹22,000', 'Customers': '9'},
        {'Line': 'Line 3', 'Loan Given': '₹40,000', 'Collected': '₹22,000', 'Outstanding': '₹18,000', 'Customers': '9'},
      ],
    );
  }

  @override
  Future<ReportEntity> getNewCustomerSummary({
    required String fromDate,
    required String toDate,
    String? lineType,
    String? line,
    bool all = true,
  }) async {
    await Future.delayed(_mockDelay);

    return ReportEntity(
      title: 'New Customers — $fromDate to $toDate',
      summaryFields: {
        'Total New Customers': '5',
        'Total Loan Given': '₹45,000',
      },
      columns: ['Name', 'Phone', 'Line', 'Area', 'Date Joined'],
      rows: [
        {'Name': 'Arun Prasad', 'Phone': '9876543210', 'Line': 'Line 1', 'Area': 'Area A', 'Date Joined': '18/06/2026'},
        {'Name': 'Divya Mohan', 'Phone': '9876543211', 'Line': 'Line 2', 'Area': 'Area B', 'Date Joined': '19/06/2026'},
        {'Name': 'Karthik Raj', 'Phone': '9876543212', 'Line': 'Line 1', 'Area': 'Area C', 'Date Joined': '20/06/2026'},
        {'Name': 'Selvi Devi', 'Phone': '9876543213', 'Line': 'Line 3', 'Area': 'Area A', 'Date Joined': '21/06/2026'},
        {'Name': 'Manoj Kumar', 'Phone': '9876543214', 'Line': 'Line 2', 'Area': 'Area B', 'Date Joined': '22/06/2026'},
      ],
    );
  }
}
