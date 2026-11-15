# Log AI-Assisted Development (Week 9)

**Mata Kuliah:** Mobile Development  
**Topik:** AI-Assisted Development (Search, Filter, and Empty State)  
**Tools AI:** GitHub Copilot  
**Branch Git:** `feat/notes-title-search`  

---

## Praktikum 1: Prompt & Context Engineering

### 1. Formula 5 Slot Prompt
Berikut adalah prompt terstruktur yang dirumuskan dan dikirimkan ke GitHub Copilot:

* **Peran:** Senior Flutter Developer
* **Konteks:**
  * Struktur Feature-First Clean Architecture (`presentation` -> `domain` <- `data`).
  * State management: `flutter_riverpod`, Local storage: `sqflite`.
  * Entity: `Note({id, title, body, updatedAt, dirty})` di `lib/features/notes/domain/entities/note.dart`.
* **Tugas:** Tambah fitur search/filter catatan berdasarkan judul (`title`) + tampilan *empty state* saat hasil pencarian tidak menemukan hasil ("Catatan tidak ditemukan").
* **Batas:**
  * Jangan ubah arsitektur layer yang sudah ada.
  * Jangan panggil SQLite dari layer widget/presentation.
  * Maksimal 80 baris perubahan kode.
* **Output:** Kode implementasi + 3 test case (unit/widget test) + langkah cara uji manual.

### 2. Analisis Kualitas Konteks
* **Zero Secrets:** Prompt tidak memuat kredensial, token API, maupun query database mentah yang sensitif.
* **Presisi Batasan:** Menetapkan batas ukuran perubahan (maksimal 80 baris) dan melarang manipulasi database dari widget.
* **Target Kontrak:** Menyertakan lokasi entity bisnis `Note` agar AI mengenali struktur data yang sudah ada tanpa mendefinisikan model baru.

---

## Praktikum 2: Generate & Verifikasi Hasil AI

### 1. Output Mentah dari GitHub Copilot
AI mengeksekusi perubahan langsung ke dalam file `lib/features/notes/presentation/pages/notes_page.dart` pada branch `feat/notes-title-search`:

```dart
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../pages/settings_page.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String value) => state = value;
}

List<Note> filterNotesByTitle(List<Note> notes, String query) {
  final q = query.trim().toLowerCase();
  return q.isEmpty ? notes : notes.where((note) => note.title.toLowerCase().contains(q)).toList();
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          Center(
            child: dirtyAsync.when(
              data: (count) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Dirty: $count', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Notes',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyinkronkan data...')));
              final syncResult = await ref.read(syncNotesProvider).call();
              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);
              if (context.mounted) {
                final message = syncResult.failure?.message ?? '${syncResult.syncedCount} catatan berhasil disinkronkan!';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan judul',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: ref.read(searchQueryProvider.notifier).setQuery,
            ),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (notes) {
                if (notes.isEmpty) return const Center(child: Text('Belum ada catatan.'));
                final filtered = filterNotesByTitle(notes, ref.watch(searchQueryProvider));
                if (filtered.isEmpty) return const Center(child: Text('Catatan tidak ditemukan'));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final note = filtered[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.body),
                      trailing: note.dirty
                          ? const Chip(label: Text('Belum sync', style: TextStyle(fontSize: 10)), backgroundColor: Colors.amberAccent)
                          : const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      onLongPress: () async {
                        if (note.id != null) {
                          await ref.read(noteRepositoryProvider).deleteNote(note.id!);
                          ref.invalidate(notesProvider);
                          ref.invalidate(dirtyCountProvider);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context, ref),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul')),
            TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Isi')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final result = await ref.read(addNoteProvider).call(title: titleController.text, body: bodyController.text);
                if (result.failure != null && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(result.failure!.message)));
                } else {
                  ref.invalidate(notesProvider);
                  ref.invalidate(dirtyCountProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
```

---

### 2. Pelaksanaan Verifikasi 6 Langkah

1. **Membaca Tiap Baris Kode:**
   Kode menjalankan filter di dalam callback UI `.when(data: (notes) { ... })`. Fungsionalitas pencarian berjalan, namun struktur penempatannya bermasalah.
2. **Cek Import & Batas Layer:**
   * Ditemukan fungsi logika bisnis `filterNotesByTitle` diletakkan di file UI `notes_page.dart`. Fungsi ini seharusnya berada di layer `domain/usecases/filter_notes.dart` agar murni Dart.
   * Deklarasi `SearchQueryNotifier` dan `searchQueryProvider` tercampur di dalam file presentasi UI, bukan di file provider terdedikasi (`notes_providers.dart`).
3. **Cek API Nyata & Autocomplete:**
   Seluruh API Riverpod (`Notifier`, `NotifierProvider`) dan Flutter Material valid dan dikenali pada Flutter SDK yang digunakan.
4. **Verifikasi `flutter analyze`:**
   Dijalankan di root direktori Week 9:
   ```text
   Analyzing 09-week-9-ai-assisted-development...
   No issues found! (ran in 9.2s)
   ```
   Analisis statis bersih dari error sintaks.
5. **Uji Otomatis (Unit & Widget Test):**
   AI tidak membuat file test di folder `test/`. File test pengujian (`test/search_filter_test.dart`) harus disiapkan manual untuk memverifikasi logika filter (case-insensitive, query kosong, query tidak cocok) serta kemunculan widget teks "Catatan tidak ditemukan".
6. **Uji Manual UI:**
   * Input teks kosong: seluruh daftar catatan tampil.
   * Input kata kunci cocok (misal: "pcvk"): hanya catatan terkait yang tampil.
   * Input kata kunci acak (misal: "matematika"): menampilkan empty state "Catatan tidak ditemukan".

---

### 3. Temuan Kelemahan, Halusinasi, dan Pelanggaran Arsitektur AI

Berikut adalah bukti temuan kritis pada kode yang dihasilkan oleh AI:

| No | Kategori Temuan | Detail Masalah | Dampak & Bukti Teknis |
| :---: | :--- | :--- | :--- |
| **1** | **Pelanggaran Clean Architecture (Layer Leaking)** | AI menaruh fungsi `filterNotesByTitle` langsung di `notes_page.dart`. | Logika bisnis tercampur ke UI. Logika filter tidak dapat diuji secara mandiri tanpa memuat dependensi Flutter UI (`package:flutter/material.dart`). |
| **2** | **Pencampuran State & Widget (DI Smell)** | Deklarasi `searchQueryProvider` dan notifernya ditulis di dalam file tampilan UI. | Mengulangi code smell Week 5 yang sebelumnya telah diaudit dan diperbaiki di Week 7. Seharusnya dikumpulkan di `features/notes/presentation/providers/notes_providers.dart`. |
| **3** | **Halusinasi Linter Suppression** | AI menambahkan anotasi `// ignore_for_file: deprecated_member_use` di baris 1. | Tidak ada satupun API usang (*deprecated*) yang dipanggil di kode tersebut. AI menunjukkan kebiasaan "menutup mata" terhadap peringatan linter alih-alih memastikan kebersihan kode secara nyata. |
| **4** | **Sub-optimal State Reactivity** | Pemanggilan `ref.watch(searchQueryProvider)` diletakkan di dalam callback builder `.when(data: ...)`. | Komputasi filter dilakukan secara berulang langsung di siklus *render tree* alih-alih memanfaatkan *derived provider* (`filteredNotesProvider`). |
