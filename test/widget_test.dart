import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  testWidgets('cold start lands on Discover with navigation', (tester) async {
    await tester.pumpWidget(const GlamSlotApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('Find a quiet chair.'), findsOneWidget);
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Bookings'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Atelier Noor'), findsOneWidget);
  });

  testWidgets('bookings tab shows empty state', (tester) async {
    await tester.pumpWidget(const GlamSlotApp());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Bookings').last);
    await tester.pump();
    await tester.pump();

    expect(find.text('No appointments yet'), findsOneWidget);
  });
}
