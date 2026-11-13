# LAPORAN MID-PROJECT & PEER CODE REVIEW
**Minggu 8 – D4 Teknik Informatika**

## Identitas Mahasiswa

| Keterangan | Informasi |
|---|---|
| Nama | Mochamad Reza Firdaus |
| NIM | 244107020104 |
| Kelas | TI-2 / D4 Teknik Informatika |
| Repository | `244107020104-mobile-course` |
| Basis Project | `07-week-7-clean-architecture` (Offline Notes App) |

---

## 1. Status Paruh Semester & Ringkasan Project

Aplikasi ini merupakan kelanjutan dari proyek arsitektur bersih (*Feature-First Clean Architecture*) pada Minggu 7, yang mengimplementasikan konsep *offline-first notes app* dengan sinkronisasi status lokal, penanda *dirty badge*, serta manajemen tema.

Pada paruh semester (Minggu 8), fokus pengembangan diarahkan pada peningkatan *engineering hygiene*, standardisasi riwayat Git, validasi alur kerja *Pull Request* antar-rekan sejawat, serta integrasi *Continuous Integration* (CI).

### Tech Stack

- **Framework:** Flutter SDK (Channel Stable) & Dart.
- **State Management & Dependency Injection:** Riverpod (`flutter_riverpod`).
- **Local Persistence:** SQLite (`sqflite` & `path_provider`).
- **Routing:** Declarative Routing (`go_router`).
- **Testing:** `flutter_test` (Unit Test & Widget Test).
- **Automation:** GitHub Actions CI (`flutter analyze` & `flutter test`).

---

## 2. Peta Issue & Pull Request (Git Flow)

Alur pengembangan menggunakan strategi Git Flow dengan branch integrasi utama `develop` dan branch fitur yang dibuat secara terpisah untuk setiap kebutuhan pengembangan.

Rincian implementasi:

- **Issue Terkait:** `#12` – Validasi input catatan kosong sebelum proses persistensi lokal.
- **Branch Kerja:** `feat/notes-validation` (dibuat dari branch `develop`).
- **Pull Request:** PR #13 – `feat(notes): validasi judul kosong + test`, dengan target merge ke branch `develop`.
- **Status PR:** Berhasil di-merge menggunakan metode **Squash & Merge** setelah mendapatkan persetujuan dari *peer reviewer* (Closes #12).

---

## 3. Hasil Verifikasi Mesin (Static Analysis & Testing)

Seluruh pemeriksaan otomatis pada branch integrasi menunjukkan hasil yang berhasil, tanpa ditemukan peringatan analisis kode maupun kegagalan pengujian.

### A. Output `flutter analyze`

```powershell
PS C:\Users\USER\244107020104-mobile-course\07-week-7-clean-architecture> flutter analyze

┌─────────────────────────────────────────────────────────┐
│ A new version of Flutter is available!                  │
│                                                         │
│ To update to the latest version, run "flutter upgrade". │
└─────────────────────────────────────────────────────────┘

Analyzing 07-week-7-clean-architecture...

No issues found! (ran in 22.9s)
```

### B. Output `flutter test`

```powershell
PS C:\Users\USER\244107020104-mobile-course\07-week-7-clean-architecture> flutter test

00:18 +6: All tests passed!
```

**Kesimpulan:** Berdasarkan hasil tersebut, proses static analysis berhasil dijalankan tanpa temuan masalah, sedangkan seluruh 6 pengujian yang terdaftar berhasil dilewati (*passed*).

---

## 4. Refleksi Code Review

### 1. Apa perbedaan LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?

**Perbedaan:**

LGTM (*Looks Good To Me*) buta merupakan tindakan menyetujui Pull Request tanpa membaca detail implementasi kode, mempertimbangkan arsitektur, ataupun melakukan pengujian secara memadai.

Sebaliknya, *approve* yang bertanggung jawab melibatkan pemeriksaan kode secara menyeluruh, pengujian manual maupun otomatis, analisis dampak (*side effects*), serta verifikasi kepatuhan terhadap aturan dependensi arsitektur, khususnya Clean Architecture.

**Risiko bagi tim:**

LGTM buta berisiko menyebabkan bug, celah keamanan, maupun pelanggaran batas arsitektur lolos ke branch integrasi (`main`/`develop`). Sebagai contoh, UI yang terhubung langsung dengan database tanpa melalui lapisan abstraksi yang semestinya.

Jika tidak segera ditangani, masalah tersebut dapat menumpuk menjadi *technical debt*, meningkatkan kompleksitas pemeliharaan, dan menghambat pengembangan aplikasi di masa mendatang.

### 2. Kapan komentar wajib berstatus Request Changes, dan kapan cukup berupa saran?

**Request Changes (Blocker):**

Status ini wajib diberikan apabila ditemukan masalah yang berdampak langsung terhadap fungsionalitas atau kualitas sistem, seperti:

- Kesalahan logika (*logic bug*) yang menyebabkan aplikasi tidak berjalan sebagaimana mestinya.
- Kegagalan pengujian melalui `flutter test` atau kegagalan proses CI.
- Pelanggaran batas arsitektur, misalnya layer Domain mengimpor dependensi framework UI seperti Flutter atau Dio.
- Tidak adanya penanganan terhadap skenario `null`, error, maupun kondisi kegagalan lainnya yang berpotensi mengganggu aplikasi.

PR tidak boleh di-merge sebelum permasalahan yang bersifat blocker tersebut diperbaiki.

**Saran (Comment):**

Komentar berupa saran diberikan untuk hal-hal yang tidak bersifat kritis dan tidak menghambat fungsionalitas aplikasi, seperti:

- Rekomendasi penamaan variabel yang lebih deskriptif.
- Penyederhanaan sintaks atau struktur kode.
- Perbaikan formatting dan konsistensi gaya penulisan.
- Alternatif implementasi yang lebih efisien tanpa mengubah perilaku sistem.

### 3. Bagian mana dari review AI yang Anda tolak atau sederhanakan, dan mengapa?

Saya menolak usulan AI yang menyarankan penggunaan impor `package:flutter/material.dart` secara langsung pada layer Domain agar dapat memanfaatkan tipe data `Color`.

Penolakan tersebut didasarkan pada prinsip fundamental Clean Architecture, yaitu layer Domain harus bersifat independen dari framework eksternal, khususnya framework yang berkaitan dengan antarmuka pengguna (*UI*).

Layer Domain seharusnya hanya berisi logika bisnis dan aturan inti aplikasi yang dapat berjalan tanpa ketergantungan terhadap Flutter. Dengan demikian, penggunaan tipe data khusus Flutter pada layer tersebut dapat menyebabkan pelanggaran terhadap prinsip *dependency rule* dan mengurangi fleksibilitas arsitektur.

### 4. Satu hal konkret yang Anda perbaiki setelah review sejawat – apa dampaknya?

Saya melakukan perbaikan pada konfigurasi *Continuous Integration* (CI) serta menangani permasalahan terkait penggunaan fitur Flutter yang berstatus *deprecated* (`flutter/material.dart`).

Sebagai langkah penanganan, saya menerapkan aturan linter `ignore_for_file: deprecated_member_use` secara spesifik pada file yang terdampak agar peringatan penggunaan API deprecated tidak mengganggu proses verifikasi.

**Dampak perbaikan:**

Perbaikan tersebut membantu mengatasi kendala pada proses verifikasi GitHub Actions yang sebelumnya mengalami kegagalan. Setelah penyesuaian dilakukan, proses CI berhasil berjalan dengan status **hijau (passed)**.

Dengan demikian, proses validasi otomatis sebelum penggabungan kode ke branch `develop` dapat berjalan lebih konsisten dan membantu mengurangi risiko masuknya kode yang belum terverifikasi ke branch integrasi.

---

## 5. Kesimpulan

Pelaksanaan proyek hingga Minggu 8 tidak hanya berfokus pada pengembangan fitur aplikasi, tetapi juga pada penerapan praktik rekayasa perangkat lunak yang baik (*software engineering best practices*).

Melalui pengelolaan Issue dan Pull Request, proses *peer code review*, pengujian otomatis, serta integrasi CI, proyek ini memberikan pemahaman mengenai pentingnya kolaborasi dan pengendalian kualitas kode dalam pengembangan perangkat lunak secara tim.

Keberhasilan proses merge PR #13 dan hasil verifikasi otomatis yang berjalan dengan baik menjadi indikator bahwa alur kerja pengembangan telah diterapkan sesuai dengan tujuan pembelajaran pada paruh semester ini.
