import 'dart:async';
import 'dart:io';

class ApiErrors {
  /// Memetakan kode status HTTP atau exception jaringan menjadi pesan ramah pengguna.
  static String fromError(Object error, {int? statusCode}) {
    if (statusCode == 401) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (statusCode == 403) {
      return 'Anda tidak memiliki akses ke halaman ini.';
    }
    if (statusCode == 404) {
      return 'Data pengumuman tidak ditemukan.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Terjadi gangguan pada server kampus. Coba beberapa saat lagi.';
    }

    if (error is TimeoutException ||
        error.toString().toLowerCase().contains('timeout')) {
      return 'Koneksi ke server melebihi batas waktu (timeout). Periksa jaringan Anda.';
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('socketexception') ||
        error.toString().toLowerCase().contains('offline')) {
      return 'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke jaringan.';
    }

    return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
  }
}
