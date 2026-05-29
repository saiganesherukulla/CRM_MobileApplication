part of 'client_detail_screen.dart';

class _Contacts extends StatelessWidget {
  final List<Contact> contacts;

  const _Contacts({required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const ApiEmpty('No contacts have been added for this client.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: contacts.map((contact) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder)),
          child: Row(
            children: [
              CrmAvatar(_initials(contact.name), size: AvatarSize.md),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(contact.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.slate800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)),
                        if (contact.primary) const CrmBadge('Primary'),
                      ],
                    ),
                    Text(contact.designation,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.slate400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(contact.email,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (contact.phone.isNotEmpty)
                      Text(contact.phone,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate500)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
