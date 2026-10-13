# Perbandingan Solusi Penyimpanan Lokal Flutter

## 1. Evaluasi Kriteria Penyimpanan Lokal

Pemilihan solusi penyimpanan lokal (*local storage*) dalam Flutter perlu mempertimbangkan kompleksitas query, kebutuhan relasi, reaktivitas, type-safety, boilerplate, dan kemudahan testing. Empat solusi yang dibandingkan adalah SharedPreferences, Hive, sqflite, dan Drift.

### 1.1 SharedPreferences

- **Kompleksitas Query:** Sangat rendah. Hanya mendukung penyimpanan pasangan kunci-nilai (*key-value*), seperti `getString()`, `getBool()`, dan `setBool()`. Tidak mendukung query kompleks, filter, atau pencarian berbasis database.
- **Kebutuhan Relasi:** Tidak mendukung relasi antartabel maupun *foreign key*.
- **Reaktivitas (Stream):** Tidak reaktif secara bawaan. Perubahan nilai perlu diteruskan secara manual melalui mekanisme *state management*.
- **Type-Safety:** Terbatas. Tipe data dasar didukung melalui API khusus, tetapi pengembang harus memastikan tipe nilai yang dibaca sesuai dengan kebutuhan aplikasi.
- **Ukuran Boilerplate:** Sangat kecil. Dapat langsung digunakan tanpa konfigurasi model, skema tabel, atau generator kode.
- **Kemudahan Testing:** Mudah. Pengujian dapat menggunakan `SharedPreferences.setMockInitialValues({})` untuk menginisialisasi data awal tanpa mengakses penyimpanan perangkat yang sebenarnya.

### 1.2 Hive

- **Kompleksitas Query:** Rendah hingga menengah. Tidak menggunakan bahasa query SQL. Pencarian dan pemfilteran data umumnya dilakukan melalui iterasi koleksi di Dart.
- **Kebutuhan Relasi:** Tidak menyediakan relasi tabular dan *foreign key* seperti SQLite. Relasi perlu dimodelkan secara manual menggunakan referensi ID atau objek bersarang (*nested objects*).
- **Reaktivitas (Stream):** Reaktif. Mendukung pemantauan perubahan data melalui API seperti `box.watch()`.
- **Type-Safety:** Menengah hingga tinggi, bergantung pada implementasi. Penyimpanan objek terstruktur membutuhkan definisi model dan `TypeAdapter`, yang dapat dibuat secara manual atau melalui generator kode.
- **Ukuran Boilerplate:** Rendah hingga menengah. Membutuhkan inisialisasi Hive, pembukaan box, dan registrasi adapter jika menggunakan objek khusus.
- **Kemudahan Testing:** Relatif mudah. Pengujian dapat menggunakan penyimpanan sementara dan konfigurasi Hive khusus untuk lingkungan pengujian.

### 1.3 sqflite (SQLite)

- **Kompleksitas Query:** Sangat tinggi. Mendukung SQL relasional, termasuk `SELECT`, `WHERE`, `JOIN`, `GROUP BY`, subquery, dan agregasi.
- **Kebutuhan Relasi:** Mendukung relasi melalui *primary key*, *foreign key*, dan aturan seperti `ON DELETE CASCADE`, dengan konfigurasi yang sesuai.
- **Reaktivitas (Stream):** Tidak reaktif secara bawaan. Query biasanya harus dijalankan ulang atau diintegrasikan dengan mekanisme notifikasi pada lapisan *state management*.
- **Type-Safety:** Terbatas. Data umumnya dibaca dan ditulis melalui `Map<String, Object?>`, sehingga kesalahan nama kolom atau konversi tipe bisa muncul saat runtime.
- **Ukuran Boilerplate:** Sedang hingga tinggi. Pengembang perlu menulis SQL, mengelola skema dan migrasi, serta membuat konversi data seperti `fromMap()` dan `toMap()`.
- **Kemudahan Testing:** Cukup menantang pada pengujian unit desktop. Penggunaan SQLite melalui FFI, misalnya dengan `sqflite_common_ffi`, memerlukan konfigurasi tambahan.

### 1.4 Drift

- **Kompleksitas Query:** Sangat tinggi. Mendukung query SQL maupun *fluent API* Dart dengan pemeriksaan tipe yang lebih kuat.
- **Kebutuhan Relasi:** Mendukung relasi SQLite, termasuk *foreign key* dan berbagai jenis *join*. Query dapat ditulis dengan API yang lebih aman terhadap kesalahan tipe.
- **Reaktivitas (Stream):** Sangat baik. Menyediakan query reaktif yang dapat memancarkan data terbaru secara otomatis ketika tabel yang diamati berubah.
- **Type-Safety:** Sangat tinggi. Skema dan hasil query menghasilkan kelas Dart melalui *code generation*, sehingga banyak kesalahan dapat ditemukan saat kompilasi.
- **Ukuran Boilerplate:** Sedang hingga tinggi pada tahap awal. Membutuhkan definisi tabel, dependensi generator seperti `drift_dev`, dan `build_runner`.
- **Kemudahan Testing:** Mudah. Mendukung database dalam memori melalui `NativeDatabase.memory()` untuk pengujian unit tanpa harus menggunakan database permanen.

---

## 2. Rekomendasi Berdasarkan Kebutuhan

| Kebutuhan Fitur | Solusi Terpilih | Alasan Pemilihan |
| :--- | :--- | :--- |
| Preferensi tema aplikasi | **SharedPreferences** | Cocok untuk menyimpan nilai sederhana seperti `bool isDarkMode`, tanpa memerlukan tabel database atau skema tambahan. |
| Penyimpanan 1.000+ catatan dengan CRUD dan sinkronisasi | **Drift** | Menyediakan mesin SQLite yang efisien, query relasional, indeks, type-safety, migrasi skema, dan stream reaktif. |
| Alternatif database relasional yang sederhana | **sqflite** | Cocok jika membutuhkan fleksibilitas SQL secara langsung dan ingin mengelola query serta pemetaan data secara manual. |
| Penyimpanan objek lokal tanpa SQL | **Hive** | Cocok untuk aplikasi yang membutuhkan penyimpanan objek dan akses data sederhana tanpa query relasional kompleks. |

### 2.1 Preferensi Tema: SharedPreferences

Untuk preferensi tema aplikasi, SharedPreferences merupakan pilihan yang paling sesuai karena data yang disimpan hanya berupa nilai sederhana.

Contoh implementasi:

```dart
final prefs = await SharedPreferences.getInstance();

await prefs.setBool('isDarkMode', true);

final isDarkMode = prefs.getBool('isDarkMode') ?? false;
```

Solusi ini menghindari kompleksitas pembuatan tabel, migrasi database, dan model data yang tidak diperlukan untuk kebutuhan tersebut.

### 2.2 Catatan dengan CRUD dan Sinkronisasi: Drift

Untuk aplikasi yang menyimpan lebih dari 1.000 catatan, Drift menjadi rekomendasi utama karena mendukung query relasional, pengindeksan, serta pemantauan perubahan data melalui stream.

Keunggulan ini relevan untuk aplikasi yang memiliki fitur:

- Create, Read, Update, Delete (CRUD).
- Pencarian dan filter catatan.
- Pengurutan berdasarkan waktu pembuatan atau pembaruan.
- Pelacakan perubahan lokal yang belum disinkronkan.
- Sinkronisasi data dengan server.
- Pembaruan antarmuka secara reaktif.

SQLite yang digunakan Drift mampu menangani ribuan baris data dengan baik apabila skema, indeks, dan query dirancang sesuai kebutuhan. Namun, pemilihan database tetap perlu mempertimbangkan kompleksitas aplikasi dan pola akses data, bukan hanya jumlah baris.

---

## 3. Rancangan Skema Database untuk 1.000+ Catatan

Pada aplikasi dengan antrean sinkronisasi, tabel catatan perlu menyimpan identitas catatan, konten, waktu pembuatan, waktu pembaruan, serta status sinkronisasi.

Kolom `dirty` digunakan untuk menandai data yang masih perlu disinkronkan ke server. Nilai `1` berarti data membutuhkan sinkronisasi, sedangkan `0` berarti data tidak sedang ditandai untuk disinkronkan.

### 3.1 Implementasi SQLite / sqflite

Berikut contoh DDL (*Data Definition Language*) untuk membuat tabel `notes`:

```sql
CREATE TABLE notes (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    dirty INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- Indeks untuk membantu pencarian berdasarkan status sinkronisasi
CREATE INDEX idx_notes_dirty
ON notes(dirty);

-- Indeks untuk membantu pengurutan berdasarkan waktu pembaruan
CREATE INDEX idx_notes_updated_at
ON notes(updated_at DESC);
```

### 3.2 Penjelasan Kolom

| Kolom | Tipe Data | Fungsi |
| :--- | :--- | :--- |
| `id` | `TEXT` | Identitas unik catatan yang dapat digunakan sebagai ID lokal maupun ID sinkronisasi, sesuai rancangan sistem. |
| `title` | `TEXT` | Judul catatan. |
| `body` | `TEXT` | Isi catatan. |
| `dirty` | `INTEGER` | Status yang menandakan apakah catatan perlu disinkronkan. |
| `created_at` | `INTEGER` | Waktu pembuatan catatan, misalnya dalam Unix timestamp milidetik. |
| `updated_at` | `INTEGER` | Waktu terakhir catatan diperbarui, menggunakan format waktu yang konsisten. |

### 3.3 Strategi Pengindeksan

Indeks membantu SQLite menemukan data tanpa harus selalu memindai seluruh tabel. Namun, indeks bukan jaminan bahwa setiap query akan berjalan lebih cepat.

Beberapa pertimbangan penting:

- **Indeks `dirty`:** Dapat membantu pencarian catatan berdasarkan status sinkronisasi, terutama jika query dan distribusi nilai datanya mendukung penggunaan indeks.
- **Indeks `updated_at`:** Dapat membantu pengurutan berdasarkan waktu pembaruan, khususnya ketika query mengambil data terbaru secara bertahap.
- **Indeks gabungan:** Jika aplikasi sering mengambil catatan yang belum disinkronkan dan mengurutkannya berdasarkan waktu pembaruan, indeks gabungan seperti `(dirty, updated_at)` dapat dipertimbangkan setelah menguji pola query yang sebenarnya.
- **Biaya indeks:** Indeks tambahan menggunakan ruang penyimpanan dan menambah pekerjaan saat operasi `INSERT`, `UPDATE`, dan `DELETE`.

Contoh query untuk mengambil catatan yang belum disinkronkan:

```sql
SELECT *
FROM notes
WHERE dirty = 1
ORDER BY updated_at ASC;
```

Untuk antrean sinkronisasi yang besar, pengambilan data dapat dilakukan secara bertahap menggunakan `LIMIT`, disertai strategi penanganan konflik dan penandaan status setelah sinkronisasi berhasil.

---

## 4. Perbandingan Trade-off Setiap Solusi

### 4.1 SharedPreferences

**Kelebihan:**
- Sangat ringan untuk preferensi sederhana.
- API mudah digunakan dan tidak membutuhkan skema database.
- Cocok untuk pengaturan tema, bahasa, dan preferensi pengguna lainnya.
- Mendukung pengujian menggunakan nilai awal tiruan.

**Kekurangan:**
- Tidak dirancang untuk penyimpanan data dalam jumlah besar.
- Tidak mendukung query relasional, indeks, atau transaksi database kompleks.
- Menyimpan ribuan catatan dalam satu string JSON besar dapat meningkatkan biaya serialisasi, parsing, dan penggunaan memori.
- Tidak menyediakan stream reaktif bawaan untuk mengamati perubahan nilai.

### 4.2 Hive

**Kelebihan:**
- Mendukung penyimpanan objek lokal tanpa SQL.
- Memiliki API yang relatif sederhana.
- Mendukung pemantauan perubahan box melalui mekanisme watch.
- Cocok untuk data berbentuk objek yang tidak membutuhkan query relasional kompleks.

**Kekurangan:**
- Pencarian dan pemfilteran data umumnya dilakukan pada lapisan aplikasi.
- Tidak menyediakan kemampuan relasional seperti `JOIN` dan *foreign key* ala SQLite.
- Pengelolaan model objek memerlukan adapter atau mekanisme serialisasi.
- Kebutuhan query kompleks dapat membuat kode pemrosesan data semakin rumit.

### 4.3 sqflite

**Kelebihan:**
- Menggunakan SQLite, mesin database relasional yang matang dan banyak digunakan.
- Mendukung query SQL, indeks, transaksi, dan relasi.
- Cocok untuk data terstruktur dengan banyak pola pencarian.
- Memungkinkan pengembang mengontrol query dan optimasi database secara langsung.

**Kekurangan:**
- Query berbasis string tidak memberikan type-safety penuh saat kompilasi.
- Pengembang perlu mengelola pemetaan data, migrasi, dan sebagian besar boilerplate secara manual.
- Tidak menyediakan stream reaktif bawaan.
- Pengujian unit di lingkungan desktop memerlukan konfigurasi tambahan jika menggunakan FFI.

### 4.4 Drift

**Kelebihan:**
- Menggabungkan kemampuan SQLite dengan API Dart yang lebih type-safe.
- Mendukung query SQL maupun *fluent API*.
- Menyediakan stream reaktif untuk query yang diamati.
- Mendukung pengelolaan skema dan migrasi database.
- Memudahkan pengujian melalui database dalam memori.
- Mengurangi kebutuhan penulisan kode pemetaan data secara manual.

**Kekurangan:**
- Memerlukan pemahaman tentang konsep SQL dan desain database.
- Membutuhkan konfigurasi awal serta proses *code generation*.
- Perubahan skema dapat memerlukan pembaruan kode hasil generator dan migrasi.
- Waktu kompilasi dan kompleksitas proyek dapat meningkat karena dependensi tambahan.

---

## 5. Kesimpulan

Pemilihan solusi penyimpanan lokal Flutter sebaiknya didasarkan pada karakteristik data dan kebutuhan aplikasi.

- **SharedPreferences** paling sesuai untuk preferensi sederhana, seperti tema aplikasi dan pengaturan pengguna.
- **Hive** sesuai untuk penyimpanan objek lokal ketika query relasional bukan kebutuhan utama.
- **sqflite** cocok untuk aplikasi yang membutuhkan SQL secara langsung dan memberikan kontrol penuh kepada pengembang.
- **Drift** direkomendasikan untuk aplikasi dengan data terstruktur, operasi CRUD, query kompleks, sinkronisasi, dan kebutuhan antarmuka reaktif dengan type-safety yang lebih kuat.

Untuk aplikasi catatan dengan lebih dari 1.000 data dan mekanisme sinkronisasi ke server, **Drift merupakan pilihan yang paling seimbang** karena menggabungkan kemampuan SQLite dengan query yang lebih aman, pengelolaan skema, dan stream reaktif.

Sementara itu, untuk preferensi tema, SharedPreferences tetap menjadi pilihan yang sederhana dan efisien. Menggunakan solusi berbeda untuk kebutuhan penyimpanan yang berbeda merupakan pendekatan yang wajar dalam arsitektur aplikasi Flutter.

### 5. AI Verification Checklist

Berikut adalah hasil verifikasi terhadap rekomendasi AI sebelum diterapkan ke dalam proyek:

1. **Apakah AI menempatkan daftar catatan di SharedPreferences? (menolak: rapuh untuk koleksi)**
   **Tidak.** AI menolak penggunaan SharedPreferences untuk daftar catatan. AI menjelaskan dengan tepat bahwa SharedPreferences memuat seluruh datanya ke RAM saat aplikasi dimulai. Jika digunakan untuk menyimpan 1000+ catatan, aplikasi akan mengalami *jank* atau *UI freeze*. AI merekomendasikan SharedPreferences murni untuk preferensi tema saja.

2. **Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos?**
   **Ya, mendukung penuh.** Skema yang diusulkan AI tidak sekadar CRUD polos. AI secara spesifik menyertakan kolom `dirty` (tipe Integer/Boolean) dan `updated_at`. Lebih penting lagi, AI memberikan perintah *indexing* (`CREATE INDEX idx_notes_dirty`) yang sangat krusial untuk performa antrean sync pada koleksi 1000+ data.

3. **Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi?**
   **Didukung fakta fitur, bukan asumsi.** AI menyatakan dengan jelas mekanisme di balik reaktivitas tersebut, yaitu adanya fungsi `watch()` bawaan pada Hive dan *auto-updating Stream* kueri pada Drift. AI juga jujur menyatakan bahwa sqflite murni tidak memiliki reaktivitas bawaan dan memerlukan *refresh* manual.

4. **Apakah estimasi boilerplate AI masuk akal setelah Anda mencoba instalasinya?**
   **Masuk akal dan akurat.** AI menilai ukuran *boilerplate* Drift sebagai "Tinggi", karena memang membutuhkan pengaturan dependensi tambahan (`drift_dev`, `build_runner`), pembuatan skema, dan proses *code generation* sebelum bisa digunakan, yang mana sangat sesuai dengan realita proses instalasinya di Flutter.

5. **Keputusan final beserta alasannya:**
   **Saya menyetujui rekomendasi kombinasi dari AI.** 
   * **SharedPreferences** terbukti sebagai pilihan paling masuk akal untuk menyimpan *state* sederhana seperti tema gelap (Dark Mode) karena dapat dibaca secara sinkron dengan cepat saat inisialisasi awal UI.
   * **sqflite / Drift** adalah keharusan mutlak untuk menyimpan entitas data utama seperti Catatan. Kemampuan mesin SQLite mengeksekusi *query* secara efisien pada kolom terindeks (`dirty`) menjadikan mekanisme sinkronisasi data *offline-first* lebih terjamin, aman (*type-safe*), dan terukur (*scalable*) meskipun pengguna memiliki ribuan catatan.
