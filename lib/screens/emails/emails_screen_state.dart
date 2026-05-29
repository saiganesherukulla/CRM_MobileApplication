part of 'emails_screen.dart';

class _EmailsScreenState extends State<EmailsScreen> {
  String _folder = 'Inbox';
  String _search = '';
  bool _syncing = false;
  late Future<List<EmailMessage>> _future;

  final _folders = ['Inbox', 'Sent', 'Follow-up', 'No Response'];

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.emails();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.emails();
    });
  }

  List<EmailMessage> _filtered(List<EmailMessage> emails) {
    return emails.where((email) {
      final query = _search.toLowerCase();
      final matchesSearch = email.subject.toLowerCase().contains(query) ||
          email.from.toLowerCase().contains(query) ||
          email.client.toLowerCase().contains(query);
      final matchesFolder = switch (_folder) {
        'Sent' => email.direction.toLowerCase() == 'outbound',
        'Follow-up' => email.status.toLowerCase().contains('follow'),
        'No Response' => email.status.toLowerCase().contains('no response'),
        _ => email.direction.toLowerCase() != 'outbound',
      };
      return matchesSearch && matchesFolder;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'Emails',
        actions: [
          IconButton(
              icon: Icon(_syncing ? Icons.hourglass_top_rounded : Icons.sync_rounded,
                  color: AppColors.primary),
              onPressed: _syncing ? null : _syncMailbox),
          IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: _showComposeSheet),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Search emails...',
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 18, color: AppColors.slate400),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _folders.map((folder) {
                      final selected = _folder == folder;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _folder = folder),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.slate100,
                                borderRadius: BorderRadius.circular(999)),
                            child: Text(folder,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.slate600)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<EmailMessage>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ApiLoading();
                }
                if (snapshot.hasError) {
                  return ApiErrorView(error: snapshot.error, onRetry: _reload);
                }
                final emails = _filtered(snapshot.data ?? const []);
                if (emails.isEmpty) {
                  return const ApiEmpty('No emails found for this folder.');
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    itemCount: emails.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, index) => _EmailTile(
                        email: emails[index],
                        onTap: () => _showEmailDetail(emails[index])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailDetail(EmailMessage email) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => _EmailThreadScreen(email: email, onSent: _reload)));
  }

  Future<void> _showComposeSheet() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ComposeSheet(),
    );
    if (sent == true) _reload();
  }

  Future<void> _syncMailbox() async {
    setState(() => _syncing = true);
    try {
      final accounts = await CrmApi.instance.emailAccounts();
      final connected = accounts.where((account) => account.status == 'Connected');
      if (connected.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Connect an email account from Settings first.')));
        }
        return;
      }
      final result = await CrmApi.instance.syncEmailAccount(connected.first.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }
}
