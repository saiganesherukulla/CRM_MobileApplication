part of 'emails_screen.dart';

class _EmailTile extends StatelessWidget {
  final EmailMessage email;
  final VoidCallback onTap;

  const _EmailTile({required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CrmAvatar(_initials(email.from), size: AvatarSize.md),
          if (email.unread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5)),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              email.from,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: email.unread ? FontWeight.w800 : FontWeight.w500,
                  color: AppColors.slate800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(email.time,
              style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            email.subject,
            style: TextStyle(
                fontSize: 13,
                fontWeight: email.unread ? FontWeight.w600 : FontWeight.normal,
                color: AppColors.slate600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              CrmBadge(email.status),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(email.client,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.slate400),
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}
