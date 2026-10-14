import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Handler wajib diletakkan di top-level (luar class) untuk background message
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Pesan background diterima: ${message.messageId}');
}

class PushService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Minta izin notifikasi (wajib untuk Android 13+ dan iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Status izin user: ${settings.authorizationStatus}');

    // 2. Dapatkan registration token FCM
    String? token = await _fcm.getToken();
    debugPrint('FCM Token: $token');

    // 3. Listener token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui: $newToken');
      // Di sini token baru bisa dikirim ke server/backend
    });

    // 4. Tangani pesan saat aplikasi aktif (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Pesan diterima (foreground): ${message.notification?.title}');
    });

    // 5. Tangani ketika notifikasi diklik dan membuka aplikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notifikasi diklik: ${message.data}');
    });
  }
}
