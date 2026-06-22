import '../../domain/entities/user_entity.dart';

/// Data model for UserEntity with JSON serialization.
/// Extends [UserEntity] for easy conversion between layers.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    super.siteName,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'agent',
      siteName: json['site']?['name']?.toString(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'siteName': siteName,
      'token': token,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      role: entity.role,
      siteName: entity.siteName,
      token: entity.token,
    );
  }
}
