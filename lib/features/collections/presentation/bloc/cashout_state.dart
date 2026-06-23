import 'package:equatable/equatable.dart';
import '../../domain/entities/cashout_entity.dart';

abstract class CashOutState extends Equatable {
  const CashOutState();

  @override
  List<Object?> get props => [];
}

class CashOutInitial extends CashOutState {}

class CashOutLoading extends CashOutState {}

class CashOutLoaded extends CashOutState {
  final List<CashOutEntity> activeCashOuts;
  final List<CashOutEntity> historyCashOuts;

  const CashOutLoaded({
    required this.activeCashOuts,
    required this.historyCashOuts,
  });

  @override
  List<Object?> get props => [activeCashOuts, historyCashOuts];
}

class CashOutError extends CashOutState {
  final String message;

  const CashOutError(this.message);

  @override
  List<Object?> get props => [message];
}
