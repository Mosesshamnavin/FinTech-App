import 'package:equatable/equatable.dart';
import '../../../customers/domain/entities/customer_entity.dart';

class CollectionEntity extends Equatable {
  final String id;
  final String customerId;
  final double amount;
  final String date; // YYYY-MM-DD format
  final String? notes;
  final String status; // e.g., 'paid', 'pending', 'skipped'

  const CollectionEntity({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.date,
    this.notes,
    required this.status,
  });

  @override
  List<Object?> get props => [id, customerId, amount, date, notes, status];
}

/// A combined entity for the UI that holds a customer and their collection for a specific date.
class DailyCollectionCustomerEntity extends Equatable {
  final CustomerEntity customer;
  final CollectionEntity? collection;

  const DailyCollectionCustomerEntity({
    required this.customer,
    this.collection,
  });

  bool get hasPaid => collection != null && collection!.status == 'paid';

  @override
  List<Object?> get props => [customer, collection];
}
