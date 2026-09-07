import 'package:flutter/material.dart';
import 'package:salon_book/core/widgets/empty_state.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: const EmptyState(
        icon: Icons.event_available_outlined,
        title: 'No appointments yet',
        message: 'When you book a chair, it will appear here — upcoming first, then the past.',
      ),
    );
  }
}
