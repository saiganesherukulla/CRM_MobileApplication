part of 'client_detail_screen.dart';

class _Emails extends StatelessWidget {
  final List<EmailMessage> emails;

  const _Emails({required this.emails});

  @override
  Widget build(BuildContext context) {
    if (emails.isEmpty) {
      return const ApiEmpty('No emails linked to this client.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: emails.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final email = emails[index];
        return _CompactRow(
          leadingColor: email.unread ? AppColors.primary : AppColors.slate200,
          title: email.subject,
          subtitle: '${email.from} - ${email.time}',
          badge: email.status,
        );
      },
    );
  }
}
