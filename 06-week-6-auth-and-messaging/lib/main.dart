import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi container agar bisa dibaca di luar widget tree (oleh GoRouter)
  final container = ProviderContainer();

  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn =
          container.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == '/login';
      
      // Pengaman rute: arahkan ke login jika belum terautentikasi
      if (!loggedIn && !goingLogin) return '/login';
      
      // Jika sudah login tetapi mencoba akses halaman login, lempar ke beranda
      if (loggedIn && goingLogin) return '/';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (_, s) =>
            AnnouncementPage(id: s.pathParameters['id'] ?? ''),
      ),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Auth & Messaging',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
