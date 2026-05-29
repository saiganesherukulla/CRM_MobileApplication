part of 'emails_screen.dart';

class _ComposeSheetState extends State<_ComposeSheet> {
  final _toCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _toCtrl.dispose();
    _subjectCtrl.dispose();
    _clientCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_toCtrl.text.trim().isEmpty || _subjectCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Recipient and subject are required.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final user = CrmApi.instance.currentUser;
      await CrmApi.instance.sendEmail({
        'to': _toCtrl.text.trim(),
        'from': user?.name ?? 'CRM User',
        'fromEmail': user?.email ?? '',
        'client': _clientCtrl.text.trim(),
        'subject': _subjectCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('New Email',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                      controller: _toCtrl,
                      decoration: const InputDecoration(
                          labelText: 'To', hintText: 'recipient@client.com')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _subjectCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Subject', hintText: 'Email subject')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _clientCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Link to Client')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _bodyCtrl,
                      maxLines: 10,
                      decoration: const InputDecoration(
                          hintText: 'Write your message here...')),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'File attachments require a configured storage provider.')),
                      );
                    },
                    icon: const Icon(Icons.attach_file_rounded, size: 16),
                    label: const Text('Attach'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
