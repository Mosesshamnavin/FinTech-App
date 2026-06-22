import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking for existing session on app start
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated and session is valid
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// User is not authenticated / logged out
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Login / Register in progress
class AuthActionLoading extends AuthState {
  final String message;
  const AuthActionLoading([this.message = 'Please wait...']);

  @override
  List<Object> get props => [message];
}

/// Any auth action failed (login, register, reset password)
class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);

  @override
  List<Object> get props => [message];
}

/// OTP sent successfully
class AuthOtpSent extends AuthState {
  const AuthOtpSent();
}

/// Password reset successful
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

/// Register successful (may need to go to login)
class AuthRegisterSuccess extends AuthState {
  final UserEntity user;
  const AuthRegisterSuccess(this.user);

  @override
  List<Object> get props => [user];
}
