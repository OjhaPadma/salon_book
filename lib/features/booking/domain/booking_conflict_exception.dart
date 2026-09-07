class BookingConflictException implements Exception {
  const BookingConflictException([
    this.message = 'That time was just taken. Please pick another slot.',
  ]);

  final String message;

  @override
  String toString() => message;
}
