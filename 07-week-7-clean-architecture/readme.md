## Praktikum 1: Audit Layer Project Lama

### 1. Pemetaan File ke Layer (`week5_offline_notes`)

| File | Layer saat ini | Masalah |
| :--- | :--- | :--- |
| `lib/main.dart` | `presentation` (root) | Menginstansiasi `PrefsRepository()` secara manual di dalam `main()` (DI bocor) dan belum memisahkan konfigurasi rute ke `routes.dart`. |
| `lib/pages/notes_page.dart` | `presentation` (+ state & DI) | Menginstansiasi `NoteRepository()` langsung di baris 9, mencampur deklarasi provider dengan widget UI, serta mengimpor `note.dart`, `note_repository.dart`, dan `sync.dart` langsung dari layer `data`. |
| `lib/pages/settings_page.dart` | `presentation` (+ state & DI) | Menginstansiasi `PrefsRepository()` langsung di baris 5, menyatukan `DarkModeNotifier` di dalam file halaman UI, dan menampilkan waktu `lastOpened` dalam format string ISO mentah. |
| `lib/pages/note_detail_page.dart` | `presentation` | Mengimpor model dan repository langsung dari layer `data` tanpa melewati kontrak layer `domain`. |
| `lib/widgets/note_tile.dart` | `presentation` | Mengimpor class `Note` langsung dari `data/local/note.dart` (melanggar *dependency rule*: `presentation` bergantung ke `data`). |
| `lib/data/local/db.dart` | `data` | OK bila hanya dipakai oleh implementasi repository (`openNotesDb`), bukan dipanggil langsung oleh widget. |
| `lib/data/local/note.dart` | `data` (+ entity tercampur) | Objek bisnis murni (*Entity*) masih tercampur dengan fungsi serialisasi SQLite (`toMap` dan `fromMap`) dalam satu class. |
| `lib/data/repositories/note_repository.dart` | `data` (+ kontrak tercampur) | Kontrak (*interface*) dan implementasi SQLite (`sqflite`) masih berada di satu class konkret, serta belum membungkus exception ke dalam `Failure`. |
| `lib/data/prefs.dart` | `data` (+ kontrak tercampur) | Kontrak dan implementasi `SharedPreferences` masih menyatu dalam satu class konkret (`PrefsRepository`). |
| `lib/data/sync.dart` | `data` (+ logika bisnis) | Operasi bisnis sinkronisasi (`syncNotes`) berada di layer `data` dan memanggil class repository konkret alih-alih menjadi *Use Case* di layer `domain`. |

---

### 2. Hasil Pencarian Tiga Pelanggaran Klasik (Sebelum Refactor)

1. **Widget menyentuh jaringan / database langsung (`lib/pages`, `lib/widgets`):**
   * Hasil: `0 temuan` (Akses `sqflite` dan `SharedPreferences` sudah berada di dalam class repository).
2. **Logika bisnis / formatting di dalam `build()` (`lib/pages`, `lib/widgets`):**
   * Hasil: `0 temuan` eksplisit, namun string ISO-8601 dari `getLastOpened()` ditampilkan mentah di `settings_page.dart`.
3. **Instansiasi manual / Dependency Injection bocor (`lib/pages`, `lib/widgets`):**
   * Hasil: **2 temuan**
  
### 2. Pratinjau Tampilan Tabel (Preview di GitHub)

Berikut adalah tampilan tabel di atas saat dirender di GitHub `README.md` Anda

| File | Layer saat ini | Masalah |
| :--- | :--- | :--- |
| `lib/main.dart` | `presentation` (root) | Menginstansiasi `PrefsRepository()` secara manual di dalam `main()` (DI bocor) dan belum memisahkan konfigurasi rute ke `routes.dart` |
| `lib/pages/notes_page.dart` | `presentation` (+ state & DI) | Menginstansiasi `NoteRepository()` langsung di baris 9, mencampur deklarasi provider dengan widget UI, serta mengimpor `note.dart`, `note_repository.dart`, dan `sync.dart` langsung dari layer `data` |
| `lib/pages/settings_page.dart` | `presentation` (+ state & DI) | Menginstansiasi `PrefsRepository()` langsung di baris 5, menyatukan `DarkModeNotifier` di dalam file halaman UI, dan menampilkan waktu `lastOpened` dalam format string ISO mentah |
| `lib/pages/note_detail_page.dart` | `presentation` | Mengimpor model dan repository langsung dari layer `data` tanpa melewati kontrak layer `domain`. |
| `lib/widgets/note_tile.dart` | `presentation` | Mengimpor class `Note` langsung dari `data/local/note.dart` (melanggar *dependency rule*: `presentation` bergantung ke `data`) |
| `lib/data/local/db.dart` | `data` | OK bila hanya dipakai oleh implementasi repository (`openNotesDb`), bukan dipanggil langsung oleh widget. |
| `lib/data/local/note.dart` | `data` (+ entity tercampur) | Objek bisnis murni (*Entity*) masih tercampur dengan fungsi serialisasi SQLite (`toMap` dan `fromMap`) dalam satu class. |
| `lib/data/repositories/note_repository.dart` | `data` (+ kontrak tercampur) | Kontrak (*interface*) dan implementasi SQLite (`sqflite`) masih berada di satu class konkret, serta belum membungkus exception ke dalam `Failure`. |
| `lib/data/prefs.dart` | `data` (+ kontrak tercampur) | Kontrak dan implementasi `SharedPreferences` masih menyatu dalam satu class konkret (`PrefsRepository`). |
| `lib/data/sync.dart` | `data` (+ logika bisnis) | Operasi bisnis sinkronisasi (`syncNotes`) berada di layer `data` dan memanggil class repository konkret alih-alih menjadi *Use Case* di layer `domain`. |

---
