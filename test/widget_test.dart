import 'package:flutter/material.dart';
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
    await tester.pumpWidget(GlamSlotApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('Find a quiet chair.'), findsOneWidget);
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Bookings'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Atelier Noor'), findsOneWidget);
  });

  testWidgets('search narrows the salon list', (tester) async {
    await tester.pumpWidget(GlamSlotApp());
    await tester.pump();
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'balayage');
    await tester.pump();

    expect(find.text('Bloom & Blade'), findsOneWidget);
    expect(find.text('Atelier Noor'), findsNothing);
  });

  testWidgets('opening a salon starts booking from a service', (tester) async {
    await tester.pumpWidget(GlamSlotApp());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Atelier Noor'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Signature cut'), findsOneWidget);

    final bookButton = find.byKey(const ValueKey('book-noor-cut'));
    await tester.ensureVisible(bookButton);
    await tester.tap(bookButton);
    await tester.pump();
    await tester.pump();

    expect(find.text('Choose a time'), findsOneWidget);
    expect(find.text('Any available'), findsOneWidget);

    await tester.tap(find.text('Choose a time'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Available times'), findsOneWidget);
    expect(find.text('Review booking'), findsOneWidget);
  });

  testWidgets('bookings tab shows empty state', (tester) async {
    await tester.pumpWidget(GlamSlotApp());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Bookings').last);
    await tester.pump();
    await tester.pump();

    expect(find.text('No appointments yet'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
  });
}
