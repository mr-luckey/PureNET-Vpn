import 'package:flutter/material.dart';
import '../main.dart';
import '../services/theme_service.dart';

class HomeCard extends StatelessWidget {
  final String title, subtitle;
  final Widget icon;

  const HomeCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mq.width * .42,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTheme.comfortaaTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTheme.comfortaaTextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
