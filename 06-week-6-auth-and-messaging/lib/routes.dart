class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String pengumumanDetail = '/pengumuman/:id';

  static String pengumumanById(String id) => '/pengumuman/$id';
}

/// Fungsi murni (pure function) untuk mengekstrak rute dari data payload FCM
/// tanpa ketergantungan langsung pada class RemoteMessage milik Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final rawRoute = data['route']?.toString().trim() ?? '';
  if (rawRoute.isEmpty) {
    return AppRoutes.home;
  }
  return rawRoute.startsWith('/') ? rawRoute : '/$rawRoute';
}
