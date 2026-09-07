import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/routing/app_router.dart';
import 'package:salon_book/core/theme/app_theme.dart';
import 'package:salon_book/features/auth/presentation/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final auth = getIt<AuthController>();
  runApp(GlamSlotApp(router: createAppRouter(auth)));
}

class GlamSlotApp extends StatelessWidget {
  const GlamSlotApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GlamSlot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
