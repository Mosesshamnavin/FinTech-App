import '../../domain/entities/collection_entity.dart';

class CollectionModel extends CollectionEntity {
  const CollectionModel({
    required super.id,
    required super.customerId,
    required super.amount,
    required super.date,
    super.notes,
    required super.status,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
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
      amount: entity.amount,
      date: entity.date,
      notes: entity.notes,
      status: entity.status,
    );
  }
}
