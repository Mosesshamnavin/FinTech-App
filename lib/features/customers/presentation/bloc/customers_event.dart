import 'package:equatable/equatable.dart';

abstract class CustomersEvent extends Equatable {
  const CustomersEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersRequested extends CustomersEvent {
  final String? lineId;
  final String? areaId;

  const LoadCustomersRequested({this.lineId, this.areaId});

  @override
  List<Object?> get props => [lineId, areaId];
}

class AddCustomerSubmitted extends CustomersEvent {
  final String name;
  final String phone;
  final String address;
  final String lineId;
  final String areaId;

  const AddCustomerSubmitted({
    required this.name,
    required this.phone,
    required this.address,
    required this.lineId,
    required this.areaId,
  });

  @override
  List<Object> get props => [name, phone, address, lineId, areaId];
}
