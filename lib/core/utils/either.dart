import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// A simple Either type for representing success [Right] or failure [Left].
/// Used as the return type for all use cases and repository methods.
///
/// Example:
///   Either<Failure, User> result = await loginUseCase(params);
///   result.fold(
///     (failure) => // handle failure,
///     (user) => // handle success,
///   );
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return switch (this) {
      Left<L, R>(value: final l) => onLeft(l),
      Right<L, R>(value: final r) => onRight(r),
    };
  }

  R? getOrNull() => switch (this) {
        Left() => null,
        Right(value: final r) => r,
      };

  L? leftOrNull() => switch (this) {
        Left(value: final l) => l,
        Right() => null,
      };
}

final class Left<L, R> extends Either<L, R> with EquatableMixin {
  final L value;
  const Left(this.value);

  @override
  List<Object?> get props => [value];
}

final class Right<L, R> extends Either<L, R> with EquatableMixin {
  final R value;
  const Right(this.value);

  @override
  List<Object?> get props => [value];
}

/// Convenience helpers
Either<Failure, R> left<R>(Failure failure) => Left(failure);
Either<Failure, R> right<R>(R value) => Right(value);
