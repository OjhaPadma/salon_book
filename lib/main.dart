import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/routing/app_router.dart';
import 'package:salon_book/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(GlamSlotApp());
}

class GlamSlotApp extends StatelessWidget {
  GlamSlotApp({super.key, GoRouter? router}) : router = router ?? createAppRouter();

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
