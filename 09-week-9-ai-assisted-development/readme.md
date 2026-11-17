# Tugas Minggu 9: AI-Assisted Development

**Nama:** Mochamad Reza Firdaus  
**NIM:** 244107020104  
**Kelas:** TI-2  
**Mata Kuliah:** Mobile Development  
**Aplikasi:** Offline Notes (Fitur Search, Filter & Empty State)  
**Branch Git:** `feat/notes-title-search`  

Repository ini mendokumentasikan implementasi fitur pencarian catatan (*Offline Notes*) dengan alur kerja **AI-Assisted Development** (Prompt -> Generate -> Verify -> Test -> Refactor -> Explain). Pengembangan ini melanjutkan arsitektur *Clean Architecture* dari Minggu 7 dengan fokus pada penambahan fitur berbasis AI tanpa merusak integritas batas antar-lapis (*layer boundary*).

---

## 1. Deskripsi Fitur & Arsitektur

Fitur yang ditambahkan meliputi sistem pencarian judul catatan secara real-time disertai umpan balik visual saat data kosong:
* **Pencarian Real-Time & Kebal Format (Case-Insensitive):** Memfilter catatan secara instan saat pengguna mengetik, mengabaikan perbedaan huruf kapital/kecil serta spasi berlebih (`.trim().toLowerCase()`).
* **Dual Empty State Handling:**
  1. Kondisi data kosong (`query` kosong dan database kosong): Menampilkan teks `"Belum ada catatan."`.
  2. Kondisi pencarian nihil (`query` terisi namun tidak ada judul yang cocok): Menampilkan teks `"Catatan tidak ditemukan"`.
* **Prinsip Arsitektur (Clean Architecture):** Logika filter diisolasi murni ke dalam layer **Domain** (`filter_notes.dart`) tanpa mengimpor framework Flutter atau SQLite, sedangkan *state reactive* dikelola di layer **Presentation** menggunakan Riverpod.

---

## 2. Prompt Inti (Formula 5-Slot)

Sesuai panduan Praktikum 1, instruksi yang diberikan kepada GitHub Copilot disusun menggunakan formula 5 slot yang terstruktur, bebas dari data rahasia (*zero secrets*), dan memiliki batasan yang tegas:

```text
Peran: Senior Flutter Developer
Konteks:
- Struktur Feature-First Clean Architecture (presentation -> domain <- data)
- State management: flutter_riverpod, Storage: sqflite
- Entity: Note({id, title, body, updatedAt, dirty}) di lib/features/notes/domain/entities/note.dart
Tugas: Tambah fitur search/filter catatan berdasarkan judul (title) + tampilan empty state saat hasil pencarian kosong ("Catatan tidak ditemukan").
Batas:
- Jangan ubah arsitektur layer yang sudah ada
- Jangan panggil SQLite dari widget
- Maksimal 80 baris perubahan kode
Output: Kode implementasi + 3 test case (unit/widget test) + langkah cara uji manual
```

---

## 3. Tech Stack

* **Framework:** Flutter SDK (Channel stable) & Dart 3.x
* **Arsitektur:** Feature-First Clean Architecture (`domain`, `data`, `presentation`)
* **State Management & DI:** `flutter_riverpod` (`NotifierProvider`, `FutureProvider`)
* **Penyimpanan Lokal:** `sqflite` (SQLite database) & `shared_preferences`
* **Asisten AI:** GitHub Copilot

---

## 4. Panduan Menjalankan Aplikasi & Pengujian

### A. Menjalankan Aplikasi di Perangkat / Emulator
```powershell
flutter pub get
flutter run
```

### B. Uji Integritas Batas Layer (Sterilitas Domain)
Pastikan layer domain tidak terkontaminasi dependensi UI atau database:
```powershell
Select-String -Path "lib\features\notes\domain\**\*.dart" -Pattern "package:flutter|package:sqflite|package:dio"
```
*(Hasil: 0 temuan / Steril)*

### C. Analisis Statis & Linter
```powershell
dart format --set-exit-if-changed lib test
flutter analyze
```

### D. Eksekusi Unit Test & Widget Test
```powershell
flutter test test/search_filter_test.dart
```

---

## 5. Hasil Pengujian & Bukti Eksekusi

### A. Hasil Terminal
* **`flutter analyze`:**
  ```text
  Analyzing 09-week-9-ai-assisted-development...
  No issues found! (ran in 8.2s)
  ```
* **`flutter test test/search_filter_test.dart`:**
  ```text
  00:25 +4: All tests passed!
  ```
  Rincian skenario pengujian yang lolos:
  1. `Unit Test: Query cocok mengembalikan catatan yang sesuai` (PASSED)
  2. `Unit Test: Query tidak cocok mengembalikan list kosong` (PASSED)
  3. `Unit Test: Query spasi kosong mengembalikan semua catatan` (PASSED)
  4. `Widget Test: Tampilkan empty state saat pencarian tidak cocok` (PASSED)

### B. Bukti Tangkapan Layar (Folder `screenshots/`)
1. `screenshots/01_empty_query.png` : Tampilan awal seluruh catatan dengan kolom pencarian kosong.
2. `screenshots/02_search_match.png` : Tampilan saat kata kunci cocok dimasukkan dan menyaring item yang sesuai.
3. `screenshots/03_search_empty_state.png` : Tampilan pesan `"Catatan tidak ditemukan"` ketika kata kunci acak dimasukkan.

---

## 6. AI Challenge: Tabel Keputusan Usulan AI

Berikut adalah evaluasi terhadap kode usulan GitHub Copilot pada branch `feat/notes-title-search`:

| Usulan Kode AI (GitHub Copilot) | Level Temuan | Alasan Teknis | Keputusan Pengembang | Bukti Verifikasi |
| :--- | :--- | :--- | :--- | :--- |
| **Menambahkan `// ignore_for_file: deprecated_member_use`** di baris pertama `notes_page.dart` | *Halusinasi Linter / Bad Practice* | AI secara otomatis membungkam peringatan linter padahal tidak ada kode usang yang dipanggil. | **Tolak** *(Dihapus total)* | `flutter analyze` tetap lolos 0 issue tanpa memerlukan anotasi tersebut. |
| **Menaruh logika filter `filterNotesByTitle` di file UI (`notes_page.dart`)** | *Pelanggaran Arsitektur (Blocker)* | Melanggar *Dependency Rule*. Logika penyaringan catatan adalah aturan bisnis (*business rule*) yang wajib berada di layer domain agar dapat diuji tanpa memuat komponen UI Flutter. | **Refactor** *(Dipindahkan ke `domain/usecases/filter_notes.dart`)* | Pengecekan import UI di layer domain menghasilkan 0 temuan via `Select-String`, unit test domain lulus 100%. |
| **Mendeklarasikan `searchQueryProvider` di dalam file UI `notes_page.dart`** | *Code Smell (DI Leak)* | Mencampur deklarasi state management dengan widget rendering, mengulang masalah lama pada Week 5. | **Refactor** *(Dipindahkan ke `presentation/providers/notes_providers.dart`)* | File UI `notes_page.dart` fokus murni pada rendering tampilan antarmuka. |
| **Normalisasi query dengan `.trim().toLowerCase()`** | *Fitur Benar* | Mencegah bug sensitivitas huruf kapital dan spasi berlebih saat pengguna mengetik input. | **Terima** | Lolos pengujian unit test case 1 (`pcvk` berhasil mencocokkan `Tugas PCVK`) dan case 3. |

---

## 7. Refleksi Kritis

1. **Bagaimana pengalaman menerapkan workflow AI (Prompt -> Generate -> Verify -> Test -> Refactor -> Explain)?**  
   Penggunaan AI secara signifikan memangkas waktu pembuatan boilerplate kode dan penyusunan draf awal. Namun, AI cenderung memilih solusi termudah yang mengabaikan batasan arsitektur (seperti menaruh semua fungsi dalam satu file UI agar kode langsung berjalan). Melalui alur verifikasi dan pengujian bertahap, kita dapat menyaring output AI sehingga kode akhir tetap sesuai standar arsitektur industri.

2. **Pola halusinasi atau kebiasaan buruk apa yang ditemukan pada AI?**  
   AI memiliki kebiasaan menyembunyikan potensi error alih-alih menyelesaikannya secara benar, seperti menyisipkan supresi linter palsu (`ignore_for_file`). Selain itu, AI kerap mencampuradukkan layer jika tidak diawasi secara ketat oleh pengembang.

3. **Mengapa verifikasi via unit test dan analyze jauh lebih penting daripada sekadar aplikasi berjalan di layar?**  
   Tampilan aplikasi yang berjalan normal di emulator dapat menyembunyikan kecacatan logika (seperti pencarian case-sensitive) atau pelanggaran struktur layer yang menurunkan *maintainability*. Pengujian otomatis melalui `flutter analyze` dan `flutter test` adalah bukti objektif dan terukur bahwa aplikasi benar secara fungsional maupun struktural.
