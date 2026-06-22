import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if a user session exists (called on app start)
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User submitted the login form
class AuthLoginSubmitted extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginSubmitted({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

/// User submitted the register form
class AuthRegisterSubmitted extends AuthEvent {
  final String name;
  final String username;
  final String password;
  final String confirmPassword;
  final String email;
  final String mobile;

  const AuthRegisterSubmitted({
    required this.name,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.email,
    required this.mobile,
  });

  @override
  List<Object> get props => [name, username, password, confirmPassword, email, mobile];
}

/// User tapped logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// User requested to send OTP for password reset
class AuthSendOtpRequested extends AuthEvent {
  final String username;
  const AuthSendOtpRequested({required this.username});

  @override
  List<Object> get props => [username];
}

/// User submitted OTP and new password
class AuthResetPasswordSubmitted extends AuthEvent {
  final String otp;
  final String newPassword;

  const AuthResetPasswordSubmitted({required this.otp, required this.newPassword});

  @override
  List<Object> get props => [otp, newPassword];
}
