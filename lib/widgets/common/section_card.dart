import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

part 'crm_divider.dart';
part 'crm_progress_bar.dart';

// ============================================================
// SectionCard — Generic white card with title
// ============================================================

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets? padding;

  const SectionCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) Flexible(flex: 0, child: trailing!),
                ],
              ),
            ),
          Padding(
            padding: padding ??
                EdgeInsets.fromLTRB(16, title != null ? 12 : 16, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Thin divider

// Progress bar
