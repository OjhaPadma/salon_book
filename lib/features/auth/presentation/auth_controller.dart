import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:salon_book/data/repositories/seed_auth_repository.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _subscription = _repository.watchUser().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<User> _subscription;
  User? _user;

  User get user => _user ?? _repository.currentUser ?? SeedAuthRepository.guest;

  bool get isGuest => user.isGuest;
  bool get isClient => user.isClient;
  bool get isStaff => user.isStaff;

  String get clientId => user.isGuest ? 'guest-client' : user.id;

  Future<User> signIn({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }

  Future<void> signOut() => _repository.signOut();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
