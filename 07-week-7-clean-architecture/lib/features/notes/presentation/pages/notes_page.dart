import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../pages/settings_page.dart';
import '../providers/notes_providers.dart';

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
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
                child: Text(
                  'Dirty: $count',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Notes',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyinkronkan data...')),
              );

              final syncResult = await ref.read(syncNotesProvider).call();

              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);

              if (context.mounted) {
                if (syncResult.failure != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(syncResult.failure!.message)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${syncResult.syncedCount} catatan berhasil disinkronkan!',
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(notesProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.body),
                trailing: note.dirty
                    ? const Chip(
                        label: Text('Belum sync', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.amberAccent,
                      )
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
                final result = await ref.read(addNoteProvider).call(
                      title: titleController.text,
                      body: bodyController.text,
                    );

                if (result.failure != null && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(result.failure!.message)),
                  );
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
