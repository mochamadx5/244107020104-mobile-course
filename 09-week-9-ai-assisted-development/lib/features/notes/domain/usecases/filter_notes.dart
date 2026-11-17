import '../entities/note.dart';

List<Note> filterNotesByTitle(List<Note> notes, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return notes;
  return notes.where((note) => note.title.toLowerCase().contains(q)).toList();
}
