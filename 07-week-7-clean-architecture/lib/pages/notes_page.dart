import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';
import 'settings_page.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final dirtyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});

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
          // 1. Tombol Buka Pengaturan Tema
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
          // 2. Badge Indikator Dirty
          Center(
            child: dirtyAsync.when(
              data: (count) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Dirty: $count',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          // 3. Tombol Sinkronisasi (Memanggil fungsi dari sync.dart)
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Notes',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyinkronkan data...')),
              );
              
              final repo = ref.read(noteRepositoryProvider);
              final count = await syncNotes(repo);
              
              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$count catatan berhasil disinkronkan!')),
                );
              }
            },
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              // Menggunakan custom widget NoteTile hasil ekstraksi
              return NoteTile(
                note: note,
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
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await ref.read(noteRepositoryProvider).addNote(
                      title: titleController.text,
                      body: bodyController.text,
                    );
                ref.invalidate(notesProvider);
                ref.invalidate(dirtyCountProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
