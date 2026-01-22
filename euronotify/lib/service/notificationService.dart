import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //INITIALIZE SERVICE
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

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

    _isInitialized = true; // ✅ Marcar como inicializado APÓS sucesso
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

  //ON NOTI TAP
}
