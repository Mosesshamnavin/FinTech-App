import '../../domain/entities/cashout_entity.dart';

class CashOutModel extends CashOutEntity {
  const CashOutModel({
    required super.id,
    required super.lineId,
    required super.amount,
    required super.date,
    required super.name,
    required super.comments,
    super.isActive = true,
  });

  factory CashOutModel.fromEntity(CashOutEntity entity) {
    return CashOutModel(
      id: entity.id,
      lineId: entity.lineId,
      amount: entity.amount,
      date: entity.date,
      name: entity.name,
      comments: entity.comments,
      isActive: entity.isActive,
    );
  }

  @override
  CashOutModel copyWith({
    String? id,
    String? lineId,
    double? amount,
    DateTime? date,
    String? name,
    String? comments,
    bool? isActive,
  }) {
    return CashOutModel(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      name: name ?? this.name,
      comments: comments ?? this.comments,
      isActive: isActive ?? this.isActive,
    );
  }
}
