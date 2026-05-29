import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ============================================================
// CrmBadge — Status / priority pill
// ============================================================

class CrmBadge extends StatelessWidget {
  final String label;
  final bool dot;
  final double fontSize;

  const CrmBadge(this.label, {super.key, this.dot = false, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(label);
    final bg = statusBgColor(label);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 118),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
