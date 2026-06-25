import 'package:equatable/equatable.dart';

/// Represents a logged-in user in the domain layer.
/// This is a pure Dart class — no dependency on any framework or data layer.
class UserEntity extends Equatable {
  final String id;
  final String username;
  final String name;
  final String email;
  final String role; // 'admin' | 'agent'
  final String? siteName;
  final String? token;

  const UserEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.siteName,
    this.token,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, username, name, email, role, siteName, token];
}
