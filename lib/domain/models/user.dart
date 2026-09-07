import 'package:equatable/equatable.dart';

import 'user_role.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.salonId,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? salonId;

  bool get isGuest => role == UserRole.guest;
  bool get isClient => role == UserRole.client;
  bool get isStaff => role == UserRole.staff;

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [id, name, email, role, salonId];
}
