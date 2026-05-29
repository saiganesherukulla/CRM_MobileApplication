import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ============================================================
// StatCard — KPI summary card
// ============================================================

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool? changeUp;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.changeUp,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.slate400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
                if (change != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        changeUp == true
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 13,
                        color: changeUp == true
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '$change vs last month',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: changeUp == true
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}
