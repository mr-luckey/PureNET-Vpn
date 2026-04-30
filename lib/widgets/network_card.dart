import 'package:flutter/material.dart';
import '../main.dart';
import '../models/network_data.dart';
import '../services/theme_service.dart';

class NetworkCard extends StatelessWidget {
  final NetworkData data;

  const NetworkCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: mq.height * .012),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: AppTheme.cardBackground,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppTheme.cardBackground,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (data.icon.color ?? AppTheme.accentBlue)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data.icon.icon,
                  color: data.icon.color ?? AppTheme.accentBlue,
                  size: data.icon.size ?? 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: AppTheme.comfortaaTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: AppTheme.comfortaaTextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
