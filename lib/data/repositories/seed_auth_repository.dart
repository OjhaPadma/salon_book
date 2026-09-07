import 'dart:async';

import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/auth_repository.dart';

class SeedAuthRepository implements AuthRepository {
  static const guest = User(
    id: 'guest-client',
    name: 'Guest',
    email: '',
    role: UserRole.guest,
  );

  static const client = User(
    id: 'client-1',
    name: 'Priya Kapoor',
    email: 'client@glamslot.com',
    role: UserRole.client,
  );

  static const staff = User(
    id: 'staff-meera',
    name: 'Meera Iyer',
    email: 'staff@glamslot.com',
    role: UserRole.staff,
    salonId: 'salon-noor',
  );

  static const _credentials = <String, String>{
    'client@glamslot.com': 'client',
    'staff@glamslot.com': 'staff',
  };

  User? _user;
  final _controller = StreamController<User>.broadcast();

  @override
  User? get currentUser => _user;

  @override
  Stream<User> watchUser() async* {
    yield _user ?? guest;
    yield* _controller.stream;
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    final normalized = email.trim().toLowerCase();
    final expected = _credentials[normalized];
    if (expected == null || expected != password) {
      throw const AuthException('Email or password didn’t match.');
    }

    _user = normalized == client.email ? client : staff;
    _controller.add(_user!);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(guest);
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
