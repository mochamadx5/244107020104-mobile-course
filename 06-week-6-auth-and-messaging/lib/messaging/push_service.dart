import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Pesan background diterima: ${message.messageId}');
}

class PushService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Notification channel dengan priority HIGH agar pop-up banner muncul
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Channel ini digunakan untuk notifikasi penting.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    // 1. Minta izin notifikasi
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Status izin user: ${settings.authorizationStatus}');

    // 2. Setup Flutter Local Notifications & daftarkan channel ke Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Dapatkan registration token FCM
    String? token = await _fcm.getToken();
    debugPrint('FCM Token: $token');

    // 4. Tangani pesan saat aplikasi aktif (Foreground) -> Tampilkan Banner Lokal!
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Pesan diterima (foreground): ${message.notification?.title}');
      
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // 5. Tangani ketika notifikasi diklik
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notifikasi diklik: ${message.data}');
    });
  }
}
