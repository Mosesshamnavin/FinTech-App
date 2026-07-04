import '../../domain/entities/collection_entity.dart';

class CollectionModel extends CollectionEntity {
  const CollectionModel({
    required super.id,
    required super.customerId,
    super.loanId,
    required super.amount,
    required super.date,
    super.notes,
    required super.status,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      customerId: (json['customer_id'] ?? json['customerId']) as String,
      loanId: (json['loan_id'] ?? json['loanId']) as String?,
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'loanId': loanId,
      'amount': amount,
      'date': date,
      'notes': notes,
      'status': status,
    };
  }

  factory CollectionModel.fromEntity(CollectionEntity entity) {
    return CollectionModel(
      id: entity.id,
      customerId: entity.customerId,
      loanId: entity.loanId,
      amount: entity.amount,
      date: entity.date,
      notes: entity.notes,
      status: entity.status,
    );
  }
}
