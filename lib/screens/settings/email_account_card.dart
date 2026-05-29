part of 'settings_screen.dart';

class _EmailAccountCard extends StatelessWidget {
  final EmailAccountInfo account;
  final VoidCallback onSync;
  final VoidCallback onDisconnect;

  const _EmailAccountCard(this.account,
      {required this.onSync, required this.onDisconnect});

  @override
  Widget build(BuildContext context) {
    final connected = account.status == 'Connected';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder)),
      child: Row(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.mail_outline_rounded,
                  color: AppColors.slate500, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.email,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(account.provider,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Chip(connected ? 'Connected' : account.status,
                  connected ? AppColors.success : AppColors.slate400),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Sync mailbox',
                    onPressed: connected ? onSync : null,
                    icon: const Icon(Icons.sync_rounded, size: 18),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Disconnect mailbox',
                    onPressed: onDisconnect,
                    icon: const Icon(Icons.link_off_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
