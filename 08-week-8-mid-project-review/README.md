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
