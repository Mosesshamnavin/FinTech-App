import 'package:equatable/equatable.dart';

class CashOutEntity extends Equatable {
  final String id;
  final String lineId;
  final double amount;
  final DateTime date;
  final String name;
  final String comments;
  final bool isActive;

  const CashOutEntity({
    required this.id,
    required this.lineId,
    required this.amount,
    required this.date,
    required this.name,
    required this.comments,
    this.isActive = true, // Defaults to true when first created
  });

  CashOutEntity copyWith({
    String? id,
    String? lineId,
    double? amount,
    DateTime? date,
    String? name,
    String? comments,
    bool? isActive,
  }) {
    return CashOutEntity(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      name: name ?? this.name,
      comments: comments ?? this.comments,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, lineId, amount, date, name, comments, isActive];
}
