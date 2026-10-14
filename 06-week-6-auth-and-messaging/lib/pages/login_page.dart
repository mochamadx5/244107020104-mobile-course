@override
  Widget build(BuildContext context) {
    // Dengarkan perubahan state auth untuk menangani error & navigasi
    ref.listen<AsyncValue<bool>>(authStateProvider, (previous, next) {
      next.whenOrNull(
        data: (isLoggedIn) {
          if (isLoggedIn) {
            // Jika ada route GoRouter '/home' atau push manual:
            // context.go('/home'); // aktifkan jika pakai GoRouter
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Berhasil!')),
            );
          }
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login Gagal: $err'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    final authState = ref.watch(authStateProvider);

    return Scaffold(
...
