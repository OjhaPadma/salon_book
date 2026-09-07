import 'package:flutter_test/flutter_test.dart';
import 'package:salon_book/data/repositories/seed_auth_repository.dart';
import 'package:salon_book/domain/models/models.dart';

void main() {
  late SeedAuthRepository repository;

  setUp(() {
    repository = SeedAuthRepository();
  });

  test('client credentials sign in as client', () async {
    final user = await repository.signIn(email: 'client@glamslot.com', password: 'client');
    expect(user.role, UserRole.client);
    expect(user.id, 'client-1');
  });

  test('staff credentials sign in as staff with salon', () async {
    final user = await repository.signIn(email: 'staff@glamslot.com', password: 'staff');
    expect(user.role, UserRole.staff);
    expect(user.salonId, 'salon-noor');
  });

  test('invalid credentials throw', () async {
    expect(
      repository.signIn(email: 'client@glamslot.com', password: 'wrong'),
      throwsA(isA<AuthException>()),
    );
  });

  test('sign out returns to guest stream', () async {
    await repository.signIn(email: 'client@glamslot.com', password: 'client');
    await repository.signOut();
    expect(repository.currentUser, isNull);
    final user = await repository.watchUser().first;
    expect(user.isGuest, isTrue);
  });
}
