import 'package:salon_book/domain/models/user.dart';

abstract class AuthRepository {
  User? get currentUser;

  Stream<User> watchUser();

  Future<User> signIn({required String email, required String password});

  Future<void> signOut();
}
