import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// [DILARANG MENGAKSES BuildContext]
// Handler wajib diletakkan di top-level (luar class) untuk background message
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Pesan background diterima: ${message.messageId}');
}

// [DILARANG MENGAKSES BuildContext DI SELURUH CLASS INI]
class PushService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static const String _topicKampus = 'pengumuman-kampus';

  Future<void> initialize({void Function(String route)? onNavigate}) async {
    // 1. Minta izin notifikasi
    // [BERBEDA: Android 13+ memicu dialog runtime POST_NOTIFICATIONS, iOS memicu izin APNs]
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Status izin user: ${settings.authorizationStatus}');

    // 2. Dapatkan registration token FCM (dengan masking agar tidak bocor di log)
    String? token = await _fcm.getToken();
    if (token != null) {
      _logMaskedToken('FCM Token', token);
      await _sendTokenToBackend(token);
    }

    // 3. Listener token refresh -> wajib kirim token baru ke backend (POST /devices)
    _fcm.onTokenRefresh.listen((newToken) async {
      _logMaskedToken('FCM Token diperbarui', newToken);
      await _sendTokenToBackend(newToken);
    });

    // 4. Subscribe ke topic pengumuman-kampus
    await subscribeToCampusTopic();

    // 5. Tangani pesan saat aplikasi aktif (Foreground)
    // [BERBEDA: Di Android, FCM tidak memunculkan banner otomatis saat foreground]
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Pesan diterima (foreground): ${message.notification?.title}');
    });

    // 6. Tangani ketika notifikasi diklik dari kondisi Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final String? route = message.data['route'] as String?;
      debugPrint('Notifikasi diklik (background): $route');
      if (route != null && onNavigate != null) {
        onNavigate(route);
      }
    });

    // 7. Tangani ketika notifikasi diklik dari kondisi Terminated (Cold Start)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final String? route = initialMessage.data['route'] as String?;
      debugPrint('Notifikasi diklik (terminated): $route');
      if (route != null && onNavigate != null) {
        onNavigate(route);
      }
    }
  }

  Future<void> subscribeToCampusTopic() async {
    await _fcm.subscribeToTopic(_topicKampus);
    debugPrint('Subscribed ke topic: $_topicKampus');
  }

  Future<void> unsubscribeFromCampusTopic() async {
    await _fcm.unsubscribeFromTopic(_topicKampus);
    debugPrint('Unsubscribed dari topic: $_topicKampus');
  }

  Future<void> _sendTokenToBackend(String token) async {
    // Simulasi pengiriman token ke endpoint POST /devices
    debugPrint('Mengirim token ke POST /devices...');
  }

  void _logMaskedToken(String label, String token) {
    if (kDebugMode) {
      final masked = token.length > 8
          ? '${token.substring(0, 8)}...[MASKED]'
          : '[MASKED]';
      debugPrint('$label: $masked');
    }
  }
}
