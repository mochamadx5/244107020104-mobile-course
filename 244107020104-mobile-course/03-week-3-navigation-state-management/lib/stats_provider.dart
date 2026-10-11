import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_notifier.dart';

class TaskStats {
  final int total;
  final int completed;
  final int pending;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
  });
}

// State untuk memicu simulasi error saat pengujian
final simulateErrorProvider = StateProvider<bool>((ref) => false);

// FutureProvider yang mengkalkulasi statistik todo secara asinkron
final statsFutureProvider = FutureProvider.autoDispose<TaskStats>((ref) async {
  final todos = ref.watch(todoListProvider);
  final isError = ref.watch(simulateErrorProvider);

  // Simulasi network delay 1.5 detik
  await Future.delayed(const Duration(milliseconds: 1500));

  if (isError) {
    throw Exception('Gagal memuat ringkasan data dari server.');
  }

  final completed = todos.where((t) => t.completed).length;
  final total = todos.length;
  final pending = total - completed;

  return TaskStats(
    total: total,
    completed: completed,
    pending: pending,
  );
});
