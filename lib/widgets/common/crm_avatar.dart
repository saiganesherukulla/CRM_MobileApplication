import 'package:flutter/material.dart';

// ============================================================
// CrmAvatar — Colored initials avatar
// ============================================================

const _colors = [
  Color(0xFF0EA5E9), // sky
  Color(0xFF10B981), // emerald
  Color(0xFFF59E0B), // amber
  Color(0xFFEF4444), // red
  Color(0xFF14B8A6), // teal
  Color(0xFFF97316), // orange
  Color(0xFF06B6D4), // cyan
  Color(0xFF8B5CF6), // violet
];

Color _colorForInitials(String initials) {
  final code = initials.codeUnitAt(0) +
      (initials.length > 1 ? initials.codeUnitAt(1) : 0);
  return _colors[code % _colors.length];
}

enum AvatarSize { xs, sm, md, lg }

double _diameter(AvatarSize size) {
  switch (size) {
    case AvatarSize.xs:
      return 24;
    case AvatarSize.sm:
      return 32;
    case AvatarSize.md:
      return 38;
    case AvatarSize.lg:
      return 48;
  }
}

double _fontSize(AvatarSize size) {
  switch (size) {
    case AvatarSize.xs:
      return 9;
    case AvatarSize.sm:
      return 11;
    case AvatarSize.md:
      return 13;
    case AvatarSize.lg:
      return 16;
  }
}

class CrmAvatar extends StatelessWidget {
  final String initials;
  final AvatarSize size;

  const CrmAvatar(this.initials, {super.key, this.size = AvatarSize.sm});

  @override
  Widget build(BuildContext context) {
    final d = _diameter(size);
    final text = initials.length >= 2
        ? initials.substring(0, 2).toUpperCase()
        : initials.toUpperCase();
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: _colorForInitials(initials),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: _fontSize(size),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
