import 'package:equatable/equatable.dart';

abstract class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyCollectionsRequested extends CollectionsEvent {
  final String date;
  final String? lineId;
  final String? areaId;

  const LoadDailyCollectionsRequested({
    required this.date,
    this.lineId,
    this.areaId,
  });

  @override
  List<Object?> get props => [date, lineId, areaId];
}

class AddCollectionRecordSubmitted extends CollectionsEvent {
  final String customerId;
  final double amount;
  final String date;
  final String? notes;
  final String status;

  const AddCollectionRecordSubmitted({
    required this.customerId,
    required this.amount,
    required this.date,
    this.notes,
    required this.status,
  });

  @override
  List<Object?> get props => [customerId, amount, date, notes, status];
}

class AddReminderSubmitted extends CollectionsEvent {
  final String date;
  final String text;

  const AddReminderSubmitted({
    required this.date,
    required this.text,
  });

  @override
  List<Object?> get props => [date, text];
}

class LoadRemindersRequested extends CollectionsEvent {
  const LoadRemindersRequested();
}

class LoadNotesRequested extends CollectionsEvent {
  const LoadNotesRequested();
}

class AddNoteSubmitted extends CollectionsEvent {
  final String text;

  const AddNoteSubmitted({required this.text});

  @override
  List<Object?> get props => [text];
}
