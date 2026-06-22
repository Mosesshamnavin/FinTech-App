import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String lineId;
  final String areaId;
  final bool isActive;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.lineId,
    required this.areaId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, phone, address, lineId, areaId, isActive];
}
