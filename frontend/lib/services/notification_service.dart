import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // ✅ CORRECCIÓN: faltaba el "<" antes de AndroidFlutterLocalNotificationsPlugin
    final androidPlugin = _plugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
if (androidPlugin != null) {
  await androidPlugin.requestPermission();
}
  }

  /// Programa notificación 1 día antes de la entrega
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    final deliveryDate = DateTime(
      reminder.dateTime.year,
      reminder.dateTime.month,
      reminder.dateTime.day,
      9,
      0,
    );

    final notifyDate = deliveryDate.subtract(const Duration(days: 1));

    if (notifyDate.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(notifyDate, tz.local);

    await _plugin.zonedSchedule(
      reminder.id.hashCode,
      '⏰ Entrega mañana',
      '${reminder.clientName} — ${reminder.title}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'entregas_channel',
          'Recordatorios de Entrega',
          channelDescription: 'Notificaciones de pedidos próximos a entregar',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          ticker: 'Entrega pendiente',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela una notificación específica
  Future<void> cancelNotification(String reminderId) async {
    await _plugin.cancel(reminderId.hashCode);
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Reprograma todas las notificaciones de una lista de reminders
  Future<void> rescheduleAll(List<Reminder> reminders) async {
    await cancelAll();
    for (final r in reminders) {
      if (!r.isCompleted) {
        await scheduleReminderNotification(r);
      }
    }
  }

Future<void> mostrarNotificacionEn10Segundos() async {
  final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

  await _plugin.zonedSchedule(
    999,
    '⏰ Prueba programada',
    'Esta notificación se programó para 10 segundos después',
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'entregas_channel',
        'Recordatorios de Entrega',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
}