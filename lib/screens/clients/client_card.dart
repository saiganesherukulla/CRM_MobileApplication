part of 'clients_screen.dart';

class _ClientCard extends StatelessWidget {
  final Client client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final canViewFinancials = CrmApi.instance.canViewFinancials();
    return GestureDetector(
      onTap: () => context.push('/clients/${client.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CrmAvatar(client.avatar, size: AvatarSize.md),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${client.industry} - ${client.country}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                CrmBadge(client.status, dot: true),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Owner',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.slate400)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CrmAvatar(_initials(client.owner),
                              size: AvatarSize.xs),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(client.owner,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: canViewFinancials ? 118 : 126,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(canViewFinancials ? client.revenue : 'Internal work',
                          style: TextStyle(
                              fontSize: canViewFinancials ? 14 : 12,
                              fontWeight: FontWeight.w700,
                              color: canViewFinancials
                                  ? AppColors.slate800
                                  : AppColors.slate500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(client.activity,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.slate400),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.public_rounded,
                    size: 14, color: AppColors.slate300),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(
                        client.website.isEmpty
                            ? 'No website added'
                            : client.website,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.slate500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppColors.slate300),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
