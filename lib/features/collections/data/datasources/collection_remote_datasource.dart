import 'dart:math';

import '../models/collection_model.dart';
import '../models/reminder_model.dart';

abstract class CollectionRemoteDataSource {
  Future<List<CollectionModel>> getCollectionsByDate(String date);
  
  Future<CollectionModel> addCollection({
    required String customerId,
    required double amount,
    required String date,
    String? notes,
    required String status,
  });

  Future<void> addReminder(String date, String text);
  Future<List<ReminderModel>> getReminders();
}

class MockCollectionRemoteDataSourceImpl implements CollectionRemoteDataSource {
  static const _mockDelay = Duration(milliseconds: 500);

  // Simulated database storing collection records
  final List<CollectionModel> _mockCollections = [
    // Pre-seed some collections for today or typical test dates
    const CollectionModel(
      id: 'coll-001',
      customerId: 'cust-001',
      amount: 500.0,
      date: '16/06/2026', // Matching the default date in the UI
      status: 'paid',
    )
  ];

  @override
  Future<List<CollectionModel>> getCollectionsByDate(String date) async {
    await Future.delayed(_mockDelay);
    return _mockCollections.where((c) => c.date == date).toList();
  }

  @override
  Future<CollectionModel> addCollection({
    required String customerId,
    required double amount,
    required String date,
    String? notes,
    required String status,
  }) async {
    await Future.delayed(_mockDelay);

    // If a collection already exists for this customer on this date, we simulate an update
    final existingIndex = _mockCollections.indexWhere((c) => c.customerId == customerId && c.date == date);
    
    if (existingIndex >= 0) {
      final updatedCollection = CollectionModel(
        id: _mockCollections[existingIndex].id,
        customerId: customerId,
        amount: amount,
        date: date,
        notes: notes,
        status: status,
      );
      _mockCollections[existingIndex] = updatedCollection;
      return updatedCollection;
    }

    // Otherwise create new
    final newCollection = CollectionModel(
      id: 'coll-${Random().nextInt(999999)}',
      customerId: customerId,
      amount: amount,
      date: date,
      notes: notes,
      status: status,
    );

    _mockCollections.add(newCollection);
    return newCollection;
  }

  @override
  Future<void> addReminder(String date, String text) async {
    await Future.delayed(_mockDelay);
    // Mock implementation does nothing, just succeeds
  }

  @override
  Future<List<ReminderModel>> getReminders() async {
    await Future.delayed(_mockDelay);
    return [];
  }
}
