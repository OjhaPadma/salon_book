import 'package:go_router/go_router.dart';
import 'package:salon_book/domain/models/models.dart';

String? authRedirect(GoRouterState state, User user) {
  final location = state.matchedLocation;

  if (location == '/login') {
    if (user.isGuest) return null;
    return user.isStaff ? '/staff' : '/discover';
  }

  if (location.startsWith('/staff')) {
    if (user.isGuest) return '/login';
    if (user.isClient) return '/discover';
    return null;
  }

  if (user.isStaff) {
    return '/staff';
  }

  return null;
}
