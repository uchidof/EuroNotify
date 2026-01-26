import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //INITIALIZE SERVICE
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

    //init Timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone =
        (await FlutterTimezone.getLocalTimezone()) as String;
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    //Android Initial settings
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    //init Settings
    const initSettings = InitializationSettings(android: initSettingsAndroid);

    //Initialize plugin
    await notificationsPlugin.initialize(initSettings);

    // Ask Permission (Android 13+)
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _isInitialized = true;
    print('[app]: Notificações inicializadas com sucesso');
  }

  //NOTIFICATION DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'dailyChannelId',
        'DailyNotifications',
        channelDescription: 'Daily Notifications Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  //SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    print('[app]: MOSTRAR NOTIFICACAO...');
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  //SCHEDULE NOTIFICATION
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    //Get the current *date/time* in device local timezone
    final now = tz.TZDateTime.now(tz.local);
    print('[app] Timezone local: ${tz.local.name}');
    print('[app] Horário atual (now):');
    print(
      '[app] Horario: ${now.hour}:${now.minute}:${now.second} - ${now.timeZoneName}',
    );

    //Create a *date/time* for today at the specified hour/min
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('\n[app] Data Selecionada:');
    print(
      '[app] Horario: ${scheduledDate.hour}:${scheduledDate.minute}:${scheduledDate.second} - ${scheduledDate.timeZoneName}',
    );

    //Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),

      //Android specific: Notifications in low power mode
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      //Make notification repeat DAILY at the same time
      //matchDateTimeComponents: DateTimeComponents.time,
    );

    print('[app]: NOTIFICACAO FOI AGENDADA ');
  }

  //Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
