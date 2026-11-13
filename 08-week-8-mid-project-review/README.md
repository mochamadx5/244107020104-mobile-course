# Laporan Mid-Project & Peer Code Review (Minggu 8)

* **Nama:** Mochamad Reza Firdaus
* **NIM:** 244107020104
* **Kelas:** TI-2 / D4 Teknik Informatika
* **Repository:** `244107020104-mobile-course`
* **Basis Project:** `07-week-7-clean-architecture` (Offline Notes App)

---

## 1. Status Paruh Semester & Ringkasan Project

Aplikasi ini merupakan kelanjutan dari proyek arsitektur bersih (*feature-first Clean Architecture*) dari Minggu 7, mengimplementasikan *offline-first notes app* dengan sinkronisasi status lokal, penanda dirty badge, serta manajemen tema. Pada paruh semester (Minggu 8), fokus utama diarahkan pada *engineering hygiene*, standardisasi riwayat Git, validasi alur kerja Pull Request antar rekan sejawat, dan integrasi Continuous Integration (CI).

### Tech Stack
* **Framework:** Flutter SDK (Channel Stable) & Dart
* **State Management & DI:** Riverpod (`flutter_riverpod`)
* **Local Persistence:** SQLite (`sqflite` + `path_provider`)
* **Routing:** Declarative Routing (`go_router`)
* **Testing:** `flutter_test` (Unit Test & Widget Test)
* **Automation:** GitHub Actions CI (`flutter analyze`, `flutter test`)

---

## 2. Peta Issue & Pull Request (Git Flow)

Alur branching mengikuti strategi Git Flow dengan cabang integrasi utama `develop` dan branch fitur pendek:

* **Issue Terkait:** `#12` - Validasi input catatan kosong sebelum persistensi lokal
* **Branch Kerja:** `feat/notes-validation` (dibuat dari `develop`)
* **Pull Request:** PR #13: `feat(notes): validasi judul kosong + test` -> `develop`
* **Status PR:** Merged via Squash & Merge setelah disetujui peer reviewer (Closes #12)

---

## 3. Hasil Verifikasi Mesin (Static Analysis & Testing)

Semua pemeriksaan mesin pada branch integrasi berstatus hijau tanpa peringatan atau kegagalan uji:

### A. Output `flutter analyze`
```bash
PS C:\Users\USER\244107020104-mobile-course\07-week-7-clean-architecture> flutter analyze

┌─────────────────────────────────────────────────────────┐
│ A new version of Flutter is available!                  │
│                                                         │
│ To update to the latest version, run "flutter upgrade". │
└─────────────────────────────────────────────────────────┘
Analyzing 07-week-7-clean-architecture...
No issues found! (ran in 22.9s)
PS C:\Users\USER\244107020104-mobile-course\07-week-7-clean-architecture> flutter test
00:18 +6: All tests passed!

## 4. Refleksi Code Review

**1. Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?**
* **Perbedaan:** LGTM (*Looks Good To Me*) buta adalah ketika reviewer langsung menyetujui Pull Request tanpa membaca detail kode, tanpa memikirkan arsitektur, dan tanpa menjalankan tes lokal. Sebaliknya, *approve* yang bertanggung jawab melibatkan pengujian kode secara manual, analisis dampak (*side effects*), dan memastikan tidak ada pelanggaran aturan dependensi (Clean Architecture).   
* **Risiko bagi tim:** LGTM buta sangat berbahaya karena bug fatal, kelemahan keamanan, atau "kebocoran" lapisan arsitektur (misal: UI terhubung langsung ke database) bisa lolos ke branch utama (`main`/`develop`), yang nantinya akan menumpuk menjadi *technical debt* dan membuat aplikasi hancur saat akan dikembangkan lebih jauh.   

**2. Kapan komentar wajib berstatus request changes, dan kapan cukup saran?**
* **Request Changes (Blocker):** Wajib diberikan ketika ada kode yang memicu *error* (bug logic), menyebabkan `flutter test` atau CI gagal, melanggar batas layer arsitektur (misal model Domain mengimpor Dio/Flutter), atau tidak menutupi skenario null/error path. PR tidak boleh di-merge sebelum ini diperbaiki.
* **Saran (Comment):** Diberikan untuk hal-hal yang sifatnya tidak esensial atau preferensi gaya penulisan (*style*), seperti penamaan variabel yang lebih baik, penyederhanaan sintaks, atau perbaikan formatting, yang tidak merusak logika bisnis aplikasi.

**3. Bagian mana dari review AI yang Anda tolak atau sederhanakan, dan mengapa?**
Saya menolak usulan AI yang menyarankan untuk mengimpor `package:flutter/material.dart` langsung ke dalam layer Domain agar bisa menggunakan tipe data `Color`. Penolakan ini berdasar pada aturan fundamental Clean Architecture di mana layer Domain harus steril (murni Dart) dan sama sekali tidak boleh bergantung pada framework UI eksternal.

**4. Satu hal konkret yang Anda perbaiki setelah review sejawat - apa dampaknya?**
Saya memperbaiki konfigurasi Continuous Integration (CI) dan menangani build error terkait fitur Flutter yang *deprecated* (`flutter/material.dart`). Saya mengaplikasikan aturan linter `ignore_for_file: deprecated_member_use` secara spesifik pada file yang terdampak agar tidak mengganggu build sistem. Dampaknya sangat besar: proses verifikasi PR (GitHub Actions) yang sebelumnya gagal total kini menjadi "Hijau" (lulus), sehingga mencegah kode kotor masuk ke branch `develop` di masa depan.
