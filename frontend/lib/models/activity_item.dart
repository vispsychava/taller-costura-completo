// lib/models/activity_item.dart
class ActivityItem {
  final String id;
  final String action;
  final String description;
  final DateTime date;
  final String userId;

  ActivityItem({
    this.id = '',
    this.action = '',
    this.description = '',
    required this.date,
    this.userId = '',
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
}