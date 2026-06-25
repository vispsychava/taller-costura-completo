// lib/models/progress_note.dart
class ProgressNote {
  final String id;
  final String note;
  final DateTime date;
  final String author;

  ProgressNote({
    this.id = '',
    this.note = '',
    required this.date,
    this.author = '',
  });

  factory ProgressNote.fromJson(Map<String, dynamic> json) {
    return ProgressNote(
      id: json['id'] ?? '',
      note: json['note'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'date': date.toIso8601String(),
      'author': author,
    };
  }
}