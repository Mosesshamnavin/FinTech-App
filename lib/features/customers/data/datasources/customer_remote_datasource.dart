import 'dart:math';

import '../../../../core/error/exceptions.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({String? lineId, String? areaId});
  Future<CustomerModel> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String lineId,
    required String areaId,
  });
}

class MockCustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  static const _mockDelay = Duration(milliseconds: 600);
  
  // Simulated database
  final List<CustomerModel> _mockCustomers = [
    const CustomerModel(
      id: 'cust-001',
      name: 'Ramesh Kumar',
      phone: '9876543210',
      address: '123 Main St, City',
      lineId: 'Line 1',
      areaId: 'Area A',
      isActive: true,
    ),
    const CustomerModel(
      id: 'cust-002',
      name: 'Suresh Babu',
      phone: '8765432109',
      address: '456 Second St, City',
      lineId: 'Line 1',
      areaId: 'Area B',
      isActive: true,
    ),
    const CustomerModel(
      id: 'cust-003',
      name: 'Anitha Reddy',
      phone: '7654321098',
      address: '789 Third St, City',
      lineId: 'Line 2',
      areaId: 'Area A',
      isActive: true,
    ),
  ];

  @override
  Future<List<CustomerModel>> getCustomers({String? lineId, String? areaId}) async {
    await Future.delayed(_mockDelay);

    List<CustomerModel> filtered = List.from(_mockCustomers);

    if (lineId != null && lineId.isNotEmpty) {
      filtered = filtered.where((c) => c.lineId == lineId).toList();
    }
    
    if (areaId != null && areaId.isNotEmpty) {
      filtered = filtered.where((c) => c.areaId == areaId).toList();
    }

    return filtered;
  }

  @override
  Future<CustomerModel> addCustomer({
    required String name,
    required String phone,
    required String address,
    required String lineId,
    required String areaId,
  }) async {
    await Future.delayed(_mockDelay);

    // Basic mock validation check to simulate server rules
    if (_mockCustomers.any((c) => c.phone == phone)) {
      throw const ServerException('A customer with this phone number already exists.');
    }

    final newCustomer = CustomerModel(
      id: 'cust-${Random().nextInt(999999)}',
      name: name,
      phone: phone,
      address: address,
      lineId: lineId,
      areaId: areaId,
      isActive: true,
    );

    _mockCustomers.add(newCustomer);
    return newCustomer;
  }
}
