import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.address,
    required super.lineId,
    required super.areaId,
    required super.isActive,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      lineId: json['lineId'] as String,
      areaId: json['areaId'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'lineId': lineId,
      'areaId': areaId,
      'isActive': isActive,
    };
  }

  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      lineId: entity.lineId,
      areaId: entity.areaId,
      isActive: entity.isActive,
    );
  }
}
