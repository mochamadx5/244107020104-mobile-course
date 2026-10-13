import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onLongPress;

  const NoteTile({
    super.key,
    required this.note,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(note.body),
      trailing: note.dirty
          ? const Chip(
              label: Text('Belum sync', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.amberAccent,
            )
          : const Icon(Icons.check_circle, color: Colors.green, size: 20),
      onLongPress: onLongPress,
    );
  }
}
