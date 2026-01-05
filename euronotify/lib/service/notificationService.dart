import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // Solicitar permissões (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Agendar notificação diária em horário específico
  static Future<void> scheduleDailyNotification({
    required int id, // ID único da notificação
    required String title, // Título que aparece na notificação
    required String body, // Mensagem da notificação
    required int hour, // Hora do dia (0-23)
    required int minute, // Minuto (0-59)
  }) async {
    await _notifications.zonedSchedule(
      id, // Identificador da notificação
      title, // Título
      body, // Corpo/mensagem
      _nextInstanceOfTime(
        hour,
        minute,
      ), // Quando disparar (calcula próxima ocorrência)

      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_cotacao_channel', // ID do canal (interno)
          'Notificações de Cotação', // Nome que aparece nas config
          channelDescription: 'Notificações diárias da cotação EUR/BRL',
          importance: Importance.high, // Importância (som, vibração)
          priority: Priority.high, // Prioridade na fila
        ),
      ),

      // MODO: dispara mesmo em economia de bateria
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // Repetir diariamente no MESMO horário (ignora data, só compara hora)
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Se o horário já passou hoje, agenda para amanhã
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Verificar se tem notificações agendadas
  static Future<bool> hasScheduledNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.isNotEmpty;
  }
}
