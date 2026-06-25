// lib/models/order.dart
import 'measurements.dart';
import 'progress_note.dart';
import 'activity_item.dart';

class Order {
  final String id;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String clientAvatar;
  final String title;
  final String description;
  final String type;
  final String size;
  final String status;
  final String statusDate;
  final String expectedDeliveryDate;
  final double totalAmount;
  final double advancePaid;
  final double balanceDue;
  final String shelfAssignment;
  final Measurements measurements;
  final List<ProgressNote> progressNotes;
  final List<ActivityItem> activityHistory;
  final String priority;

  Order({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.clientAvatar,
    required this.title,
    required this.description,
    required this.type,
    required this.size,
    required this.status,
    required this.statusDate,
    required this.expectedDeliveryDate,
    required this.totalAmount,
    required this.advancePaid,
    required this.balanceDue,
    required this.shelfAssignment,
    required this.measurements,
    required this.progressNotes,
    required this.activityHistory,
    required this.priority,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      clientName: json['clientName'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      clientEmail: json['clientEmail'] ?? '',
      clientAvatar: json['clientAvatar'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? '',
      status: json['status'] ?? '',
      statusDate: json['statusDate'] ?? '',
      expectedDeliveryDate: json['expectedDeliveryDate'] ?? '',
      totalAmount: json['totalAmount']?.toDouble() ?? 0,
      advancePaid: json['advancePaid']?.toDouble() ?? 0,
      balanceDue: json['balanceDue']?.toDouble() ?? 0,
      shelfAssignment: json['shelfAssignment'] ?? '',
      measurements: json['measurements'] != null
          ? Measurements.fromJson(json['measurements'])
          : Measurements.empty(),
      progressNotes: json['progressNotes'] != null
          ? (json['progressNotes'] as List)
              .map((e) => ProgressNote.fromJson(e))
              .toList()
          : [],
      activityHistory: json['activityHistory'] != null
          ? (json['activityHistory'] as List)
              .map((e) => ActivityItem.fromJson(e))
              .toList()
          : [],
      priority: json['priority'] ?? 'Media',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'clientAvatar': clientAvatar,
      'title': title,
      'description': description,
      'type': type,
      'size': size,
      'status': status,
      'statusDate': statusDate,
      'expectedDeliveryDate': expectedDeliveryDate,
      'totalAmount': totalAmount,
      'advancePaid': advancePaid,
      'balanceDue': balanceDue,
      'shelfAssignment': shelfAssignment,
      'measurements': measurements.toJson(),
      'progressNotes': progressNotes.map((e) => e.toJson()).toList(),
      'activityHistory': activityHistory.map((e) => e.toJson()).toList(),
      'priority': priority,
    };
  }
}