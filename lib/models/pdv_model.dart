import 'package:flutter/material.dart';

class PDV {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String openingTime;
  final String closingTime;
  final bool openWeekend;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PDV({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.openingTime,
    required this.closingTime,
    required this.openWeekend,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PDV.fromJson(Map<String, dynamic> json) {
    return PDV(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      phone: json['phone'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      openWeekend: json['openWeekend'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'openWeekend': openWeekend,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool isOpen() {
    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      final openingParts = this.openingTime.split(':');
      final closingParts = this.closingTime.split(':');

      final openingTime = TimeOfDay(
        hour: int.parse(openingParts[0]),
        minute: int.parse(openingParts[1])
      );

      final closingTime = TimeOfDay(
        hour: int.parse(closingParts[0]),
        minute: int.parse(closingParts[1])
      );

      final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final openingMinutes = openingTime.hour * 60 + openingTime.minute;
      final closingMinutes = closingTime.hour * 60 + closingTime.minute;

      return (!isWeekend || openWeekend)
        && (currentMinutes >= openingMinutes && currentMinutes < closingMinutes);
    } catch (e) {
      return false;
    }
  }
}
