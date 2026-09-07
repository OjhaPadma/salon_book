import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:salon_book/core/notifications/appointment_notifier.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/booking.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalAppointmentNotifier implements AppointmentNotifier {
  LocalAppointmentNotifier() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static Future<LocalAppointmentNotifier> create() async {
    final notifier = LocalAppointmentNotifier();
    await notifier._init();
    return notifier;
  }

  Future<void> _init() async {
    if (kIsWeb) return;

    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    _ready = true;
  }

  int _id(String bookingId, int offset) => bookingId.hashCode.abs() + offset;

  @override
  Future<void> scheduleForBooking({
    required Booking booking,
    required String salonName,
    required String serviceName,
  }) async {
    if (!_ready) return;

    final when = DateTimeUtils.formatTimeRange(booking.start, booking.end);
    await _plugin.show(
      _id(booking.id, 0),
      'Booking confirmed',
      '$serviceName at $salonName · $when',
      const NotificationDetails(
        android: AndroidNotificationDetails('bookings', 'Bookings', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
    );

    await _scheduleReminder(
      bookingId: booking.id,
      offset: 1,
      at: booking.start.subtract(const Duration(hours: 24)),
      title: 'Tomorrow at the salon',
      body: '$serviceName at $salonName · $when',
    );
    await _scheduleReminder(
      bookingId: booking.id,
      offset: 2,
      at: booking.start.subtract(const Duration(hours: 1)),
      title: 'One hour to go',
      body: '$serviceName at $salonName · $when',
    );
  }

  Future<void> _scheduleReminder({
    required String bookingId,
    required int offset,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (at.isBefore(DateTime.now())) return;
    final scheduled = tz.TZDateTime.from(at, tz.local);
    await _plugin.zonedSchedule(
      _id(bookingId, offset),
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelForBooking(String bookingId) async {
    if (!_ready) return;
    for (final offset in [0, 1, 2]) {
      await _plugin.cancel(_id(bookingId, offset));
    }
  }
}
