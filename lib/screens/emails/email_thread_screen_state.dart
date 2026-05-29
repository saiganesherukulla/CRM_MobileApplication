part of 'emails_screen.dart';

class _EmailThreadScreenState extends State<_EmailThreadScreen> {
  final _replyCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final body = _replyCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final user = CrmApi.instance.currentUser;
      await CrmApi.instance.sendEmail({
        'to': widget.email.fromEmail,
        'from': user?.name ?? 'CRM User',
        'fromEmail': user?.email ?? '',
        'client': widget.email.client,
        'subject': widget.email.subject.startsWith('Re:')
            ? widget.email.subject
            : 'Re: ${widget.email.subject}',
        'body': body,
        'thread': widget.email.thread,
      });
      _replyCtrl.clear();
      widget.onSent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reply queued for delivery.')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteEmail() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete email?'),
        content: Text(widget.email.subject),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await CrmApi.instance.deleteEmail(widget.email.id);
      widget.onSent();
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: email.subject,
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: _deleteEmail,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBAE6FD))),
            child: Row(
              children: [
                Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Linked to: ${email.client}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CrmAvatar(_initials(email.from), size: AvatarSize.sm),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: AppColors.surfaceBorder)),
                            child: Text(
                                email.body.isNotEmpty
                                    ? email.body
                                    : email.preview,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.slate700,
                                    height: 1.4)),
                          ),
                          const SizedBox(height: 4),
                          Text('${email.from} - ${email.time}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.slate400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.slate100))),
            child: Column(
              children: [
                if (_error != null) ...[
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    CrmAvatar(CrmApi.instance.currentUser?.avatar ?? 'NA',
                        size: AvatarSize.sm),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                          controller: _replyCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Write a reply...',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10))),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send_rounded,
                              color: AppColors.primary),
                      onPressed: _sending ? null : _sendReply,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
