import 'package:bit_money/constants/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String time;
  final Color iconColor;
  final Color iconBackground;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.iconColor,
    required this.iconBackground,
  });
}

class RecentNotificationsWidget extends StatefulWidget {
  const RecentNotificationsWidget({super.key});

  @override
  State<RecentNotificationsWidget> createState() => _RecentNotificationsWidgetState();
}

class _RecentNotificationsWidgetState extends State<RecentNotificationsWidget> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationItem(
        icon: Icons.pending_actions,
        title: 'Transaction en attente',
        time: 'Il y a 5 minutes',
        iconColor: Colors.orange,
        iconBackground: Colors.orange.withValues(alpha: .1),
      ),
      NotificationItem(
        icon: Icons.check_circle_outline,
        title: 'Nouveau PDV enrôlé',
        time: 'Il y a 30 minutes',
        iconColor: Colors.green,
        iconBackground: Colors.green.withValues(alpha: .1),
      ),
      NotificationItem(
        icon: Icons.check_circle,
        title: 'Transaction validée',
        time: 'Il y a 1 heure',
        iconColor: Colors.green,
        iconBackground: Colors.green.withValues(alpha: .1),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: .95),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.almostBlack,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildNotificationsList(),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationsList() {
    final List<Widget> notificationWidgets = [];

    for (int i = 0; i < _notifications.length; i++) {
      notificationWidgets.add(
        _buildNotificationItem(
          icon: _notifications[i].icon,
          title: _notifications[i].title,
          time: _notifications[i].time,
          iconColor: _notifications[i].iconColor,
          iconBackground: _notifications[i].iconBackground,
        ),
      );

      if (i < _notifications.length - 1) {
        notificationWidgets.add(const Divider());
      }
    }

    return notificationWidgets;
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String time,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.almostBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
