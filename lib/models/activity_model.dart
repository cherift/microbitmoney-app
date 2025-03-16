import 'package:flutter/material.dart';

class ActivityItem {
  final String id;
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color iconColor;
  final Color iconBackground;
  final String type;
  final String? status;

  ActivityItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.iconColor,
    required this.iconBackground,
    required this.type,
    this.status,
  });

  factory ActivityItem.fromNotification(Map<String, dynamic> json) {
    // Déterminer l'icône et la couleur basées sur le type et le statut
    IconData icon;
    Color color;

    final type = json['type'] as String;
    final status = json['status'] as String?;

    switch (type) {
      case 'TRANSACTION':
        if (status == 'COMPLETED') {
          icon = Icons.check_circle;
          color = Colors.green;
        } else if (status == 'REJECTED') {
          icon = Icons.cancel_outlined;
          color = Colors.red;
        } else {
          icon = Icons.pending_actions;
          color = Colors.orange;
        }
        break;
      case 'RECEPTION':
        if (status == 'COMPLETED') {
          icon = Icons.download_done;
          color = Colors.green;
        } else if (status == 'REJECTED') {
          icon = Icons.cancel_outlined;
          color = Colors.red;
        } else {
          icon = Icons.download;
          color = Colors.blue;
        }
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blue;
    }

    // Calculer le temps relatif
    final createdAt = DateTime.parse(json['createdAt']);
    final relativeTime = _getRelativeTime(createdAt);

    return ActivityItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      time: relativeTime,
      icon: icon,
      iconColor: color,
      iconBackground: color.withValues(alpha: .1),
      type: type,
      status: status,
    );
  }

  // Calculer le temps relatif (il y a X minutes, heures, etc.)
  static String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return dateTime.toString().substring(0, 10); // Format YYYY-MM-DD
    }
  }
}