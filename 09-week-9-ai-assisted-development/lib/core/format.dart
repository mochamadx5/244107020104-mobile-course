class AppFormat {
  /// Mengubah DateTime menjadi string format lokal sederhana
  static String date(DateTime? dt) {
    if (dt == null) return 'Belum ada data';
    // Format sederhana: DD/MM/YYYY HH:MM
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Mengubah string ISO-8601 (dari SharedPreferences) menjadi string rapi
  static String dateFromIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Belum ada data';
    final dt = DateTime.tryParse(isoString);
    return date(dt);
  }
}
