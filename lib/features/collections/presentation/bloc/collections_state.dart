import 'package:equatable/equatable.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/entities/reminder_entity.dart';

abstract class CollectionsState extends Equatable {
  const CollectionsState();

  @override
  List<Object?> get props => [];
}

class CollectionsInitial extends CollectionsState {
  const CollectionsInitial();
}

class DailyCollectionsLoading extends CollectionsState {
  const DailyCollectionsLoading();
}

class DailyCollectionsLoaded extends CollectionsState {
  final List<DailyCollectionCustomerEntity> dailyList;

  const DailyCollectionsLoaded(this.dailyList);

  @override
  List<Object> get props => [dailyList];
}

class DailyCollectionsError extends CollectionsState {
  final String message;

  const DailyCollectionsError(this.message);

  @override
  List<Object> get props => [message];
}

class AddCollectionActionLoading extends CollectionsState {
  const AddCollectionActionLoading();
}

class AddCollectionActionSuccess extends CollectionsState {
  const AddCollectionActionSuccess();
}

class AddCollectionActionError extends CollectionsState {
  final String message;

  const AddCollectionActionError(this.message);

  @override
  List<Object> get props => [message];
}

class AddReminderActionLoading extends CollectionsState {
  const AddReminderActionLoading();
}

class AddReminderActionSuccess extends CollectionsState {
  const AddReminderActionSuccess();
}

class AddReminderActionError extends CollectionsState {
  final String message;
  const AddReminderActionError(this.message);

  @override
  List<Object> get props => [message];
}

class RemindersLoading extends CollectionsState {
  const RemindersLoading();
}

class RemindersLoaded extends CollectionsState {
  final List<ReminderEntity> reminders;
  const RemindersLoaded(this.reminders);

  @override
  List<Object> get props => [reminders];
}

class RemindersError extends CollectionsState {
  final String message;
  const RemindersError(this.message);

  @override
  List<Object> get props => [message];
}
