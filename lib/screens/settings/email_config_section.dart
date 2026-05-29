part of 'settings_screen.dart';

class _EmailConfigSection extends StatefulWidget {
  final List<EmailAccountInfo> accounts;
  final List<EmailProviderInfo> providers;
  final VoidCallback onChanged;

  const _EmailConfigSection({
    required this.accounts,
    required this.providers,
    required this.onChanged,
  });

  @override
  State<_EmailConfigSection> createState() => _EmailConfigSectionState();
}
