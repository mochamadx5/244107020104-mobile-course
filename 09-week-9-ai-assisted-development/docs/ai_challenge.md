# Laporan AI Challenge - Praktikum 7 (Clean Architecture)

## 1. Teks Prompt
Berikut adalah prompt yang digunakan untuk menguji AI terkait restrukturisasi project `campus_notify`:

> Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
> Kondisi kini: folder lib/{data, providers, pages, messaging}, repository tercampur dengan implementasi, widget memanggil Dio langsung.
> Tugas:
> 1. Usulkan struktur feature-first Clean Architecture (presentation/domain/data) untuk fitur auth + announcements.
> 2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
> 3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana, dan kapan use case benar-benar dibutuhkan vs repository langsung.
> 4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
> Jelaskan trade-off setiap keputusan.

---

## 2. Output Usulan Arsitektur & Penjelasan AI

**Usulan Struktur Feature-First:**
AI mengusulkan pemisahan fitur secara independen (`auth` dan `announcements`), ditambah folder `core` untuk konfigurasi global seperti Dio dan layanan Firebase.
* `lib/core/` (network, messaging, failures)
* `lib/features/auth/` (domain, data, presentation)
* `lib/features/announcements/` (domain, data, presentation)

**Pemetaan File Lama:**
* `lib/data/api_client.dart` -> Pindah ke `lib/core/network/dio_client.dart`
* `lib/messaging/fcm_service.dart` -> Pindah ke `lib/core/messaging/fcm_service.dart`
* `lib/data/auth_repository.dart` -> Dipecah: Interface ke `auth/domain/repositories/`, implementasi ke `auth/data/repositories/`
* `lib/providers/auth_provider.dart` -> Pindah ke `auth/presentation/providers/`
* `lib/pages/home_page.dart` -> Pindah ke `announcements/presentation/pages/` dan dibersihkan dari pemanggilan Dio langsung.

**Analisis Over-Engineering (Use Case vs Repository):**
AI menyoroti bahwa menggunakan *Use Case* untuk CRUD satu baris (seperti `fetchAnnouncements()`) adalah *over-engineering* karena hanya menambah *boilerplate* tanpa logika bisnis tambahan. Sebaliknya, *Use Case* sangat diperlukan untuk alur yang kompleks seperti `LoginUseCase`, di mana aplikasi harus mengambil token API, mengambil token FCM, dan menyimpannya ke secure storage secara berurutan.

**Wiring Riverpod (DI):**
AI memusatkan injeksi dependensi menggunakan provider Riverpod di layer *presentation* (`providers.dart`), seperti menyuntikkan `dioProvider` ke `announcementRepositoryProvider`, lalu hasilnya dikonsumsi oleh `announcementsProvider` (FutureProvider) untuk UI.

---

## 3. AI Verification Checklist & Tabel Keputusan Final

| Pertanyaan Verifikasi | Hasil Pengecekan pada Output AI | Keputusan Final |
| :--- | :--- | :--- |
| **Apakah interface repository tinggal di `domain` dan implementasi di `data`?** | **Lulus.** AI memecah `auth_repository.dart` lama dengan benar ke dalam `domain/repositories` (interface) dan `data/repositories` (implementasi). | Diterima. Ini memastikan lapisan bisnis tidak bergantung pada implementasi teknis. |
| **Apakah `domain` bebas import Flutter/Dio/SQLite/Firebase?** | **Lulus.** AI memisahkan file konfigurasi FCM dan Dio ke folder `core` dan menjaga `domain` murni berisi logika bisnis Dart. | Diterima. Layer `domain` siap diuji dengan murni (*unit testable*). |
| **Apakah AI membuat use case untuk tiap CRUD satu-baris?** | **Lulus.** AI menyadari potensi *over-engineering* dan merekomendasikan pemanggilan langsung repository dari notifier untuk CRUD pengumuman yang sederhana. | Diterima. Ini menghemat *boilerplate* dan menjaga kecepatan pengembangan fitur sederhana. |
| **Apakah entity bebas mapping (`toMap`/`fromMap`/`toJson` hanya di model)?** | **Lulus.** AI secara eksplisit memisahkan `UserModel` (di data layer) untuk keperluan parsing JSON dan `User` Entity (di domain layer) sebagai objek bisnis murni. | Diterima. Fleksibilitas tinggi bila respons API berubah di masa depan. |
| **Apakah wiring DI terpusat di provider dan widget tidak `new Repository()` sendiri?** | **Lulus.** AI mendemonstrasikan file `providers.dart` untuk *wiring* dependensi, menghindari instansiasi manual di dalam widget UI. | Diterima. Widget menjadi "bodoh" (hanya menampilkan state) dan mudah diuji. |

---

## 4. Alasan Teknis Penyesuaian

Berdasarkan analisis di atas, saya **menerima secara penuh** rekomendasi AI tersebut dengan argumen teknis berikut:
1. **Ketahanan Skalabilitas:** Mengadopsi *Feature-First* sangat ideal karena memisahkan *Auth* dan *Announcements* secara total. Jika kelak fitur pengumuman diganti atau dihapus, folder `auth` tidak akan terdampak sedikit pun.
2. **Efisiensi Kode (Mencegah Over-engineering):** Rekomendasi AI untuk mengizinkan layer *Presentation* mengakses *Repository* secara langsung pada operasi CRUD sederhana (*pass-through*) sangat efisien bagi ukuran tim kecil, sehingga kita tidak terjebak membuat puluhan class *Use Case* kosong.
3. **Sentralisasi Dependensi:** Penggunaan Riverpod murni sebagai *Service Locator* di satu tempat (`providers.dart`) memudahkan *mocking* repository saat melakukan UI testing.
