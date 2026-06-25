// models/reminder.dart
import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String title;
  final String clientName;
  final String time;
  final String deadlineText;
  final DateTime dateTime;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.clientName,
    required this.time,
    required this.deadlineText,
    required this.dateTime,
    this.isCompleted = false,
  });

  // Getter para deadlineDate que devuelve la fecha formateada
  String get deadlineDate {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  // Getter para obtener el día de la semana
  String get weekday {
    const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return weekdays[dateTime.weekday - 1];
  }

  // Método para obtener la fecha como texto legible
  String get readableDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = date.difference(today).inDays;

    if (difference == 0) return "HOY";
    if (difference == 1) return "MAÑANA";
    if (difference == -1) return "AYER";
    if (difference > 1 && difference < 7) {
      return weekday;
    }
    return deadlineDate;
  }

  // Método para obtener el color según la urgencia
  Color get urgencyColor {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = date.difference(today).inDays;

    if (difference < 0) return const Color(0xffEF4444);
    if (difference == 0) return const Color(0xffEF4444);
    if (difference == 1) return const Color(0xffF59E0B);
    if (difference <= 3) return const Color(0xff8B5CF6);
    return const Color(0xff64748B);
  }

  // Si usas JSON:
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      clientName: json['clientName'] ?? '',
      time: json['time'] ?? '',
      deadlineText: json['deadlineText'] ?? '',
      dateTime: DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'clientName': clientName,
      'time': time,
      'deadlineText': deadlineText,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}