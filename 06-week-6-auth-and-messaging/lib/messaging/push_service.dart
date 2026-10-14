import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../routes.dart';

// Handler wajib diletakkan di top-level (luar class) untuk background message
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Pesan background diterima: ${message.messageId}');
}

class PushService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize({void Function(String route)? onNavigate}) async {
    // 1. Minta izin notifikasi (wajib untuk Android 13+ dan iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Status izin user: ${settings.authorizationStatus}');

    // 2. Dapatkan registration token FCM
    String? token = await _fcm.getToken();
    if (token != null && kDebugMode) {
      final masked = token.length > 8 ? '${token.substring(0, 8)}...[MASKED]' : '[MASKED]';
      debugPrint('FCM Token: $masked');
    }

    // 3. Listener token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        final masked = newToken.length > 8 ? '${newToken.substring(0, 8)}...[MASKED]' : '[MASKED]';
        debugPrint('FCM Token diperbarui: $masked');
      }
    });

    // 4. Tangani pesan saat aplikasi aktif (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Pesan diterima (foreground): ${message.notification?.title}');
    });

    // 5. Tangani ketika notifikasi diklik dan membuka aplikasi (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final targetRoute = routeFromMessage(message.data);
      debugPrint('Notifikasi diklik menuju rute: $targetRoute');
      onNavigate?.call(targetRoute);
    });

    // 6. Tangani ketika aplikasi dibuka dari kondisi mati total (Terminated)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final targetRoute = routeFromMessage(initialMessage.data);
      debugPrint('Notifikasi initial menuju rute: $targetRoute');
      onNavigate?.call(targetRoute);
    }
  }
}
