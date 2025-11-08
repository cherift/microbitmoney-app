import 'package:bit_money/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:translator/translator.dart';

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

  static Future<ActivityItem> fromNotificationAsync(Map<String, dynamic> json, BuildContext context) async {
    IconData icon;
    Color color;

    final translator = GoogleTranslator();

    final type = json['type'] as String;
    final status = json['status'] as String?;
    final localeName = AppLocalizations.of(context)!.localeName;

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

    final createdAt = DateTime.parse(json['createdAt']);
    final relativeTime = _getRelativeTime(createdAt, localeName);

    String title = json['title'];
    String message = json['message'];

    if (localeName != 'fr') {
      try {
        final titleTranslation = await translator.translate(
          title,
          from: 'fr',
          to: localeName
        );

        final messageTranslation = await translator.translate(
          message,
          from: 'fr',
          to: localeName
        );

        title = titleTranslation.text;
        message = messageTranslation.text;
      } catch (e) {
        debugPrint('Erreur de traduction: $e');
      }
    }

    return ActivityItem(
      id: json['id'],
      title: title,
      message: message,
      time: relativeTime,
      icon: icon,
      iconColor: color,
      iconBackground: color.withValues(alpha: .1),
      type: type,
      status: status,
    );
  }

  static String _getRelativeTime(DateTime dateTime, localeName) {
    if (localeName == 'fr') {
      timeago.setLocaleMessages(localeName, timeago.FrMessages());
    } else if (localeName == 'en') {
      timeago.setLocaleMessages(localeName, timeago.EnMessages());
    }

    return timeago.format(dateTime, locale: localeName);
  }
}