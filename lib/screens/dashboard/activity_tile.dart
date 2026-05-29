part of 'dashboard_screen.dart';

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.slate50))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmAvatar(item.avatar, size: AvatarSize.sm),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.slate600),
                    children: [
                      TextSpan(
                          text: item.user,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate800)),
                      TextSpan(text: ' ${item.action} '),
                      TextSpan(
                          text: item.target,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(item.time,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
