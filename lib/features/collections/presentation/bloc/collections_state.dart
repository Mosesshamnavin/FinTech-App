import 'package:equatable/equatable.dart';
import '../../domain/entities/collection_entity.dart';

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
