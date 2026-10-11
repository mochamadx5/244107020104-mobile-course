import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo.dart';

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier()
      : super(const [
          Todo(id: '1', title: 'Belajar GoRouter dasar', completed: true),
          Todo(id: '2', title: 'Pahami konsep State Management'),
          Todo(id: '3', title: 'Implementasi Riverpod Notifier'),
        ]);

  void add(String title) {
    if (title.trim().isEmpty) return;
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    state = [...state, newTodo];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(completed: !todo.completed)
        else
          todo,
    ];
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

// Provider global untuk daftar Todo
final todoListProvider =
    StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});
