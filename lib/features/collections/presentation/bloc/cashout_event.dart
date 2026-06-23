import 'package:equatable/equatable.dart';
import '../../domain/entities/cashout_entity.dart';

abstract class CashOutEvent extends Equatable {
  const CashOutEvent();

  @override
  List<Object?> get props => [];
}

class LoadCashOutsRequested extends CashOutEvent {
  final String? lineId;

  const LoadCashOutsRequested({this.lineId});

  @override
  List<Object?> get props => [lineId];
}

class AddCashOutSubmitted extends CashOutEvent {
  final CashOutEntity cashOut;

  const AddCashOutSubmitted(this.cashOut);

  @override
  List<Object?> get props => [cashOut];
}

class SettleCashOutSubmitted extends CashOutEvent {
  final String cashOutId;

  const SettleCashOutSubmitted(this.cashOutId);

  @override
  List<Object?> get props => [cashOutId];
}
