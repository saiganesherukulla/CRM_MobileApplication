import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_badge.dart';
import '../../widgets/layout/app_shell.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late Future<_InvoiceData> _future;
  String _status = 'All';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_InvoiceData> _load() async {
    final invoices = await CrmApi.instance.invoices();
    final clients =
        await CrmApi.instance.clients().catchError((_) => <Client>[]);
    return _InvoiceData(invoices, clients);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _openSheet(_InvoiceData data, [Invoice? invoice]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InvoiceSheet(clients: data.clients, invoice: invoice),
    );
    if (changed == true) _reload();
  }

  Future<void> _delete(Invoice invoice) async {
    await CrmApi.instance.deleteInvoice(invoice.id);
    _reload();
  }

  Future<void> _email(Invoice invoice) async {
    final user = CrmApi.instance.currentUser;
    await CrmApi.instance.sendEmail({
      'from': user?.name ?? 'CTRL F User',
      'fromEmail': user?.email ?? '',
      'to': '',
      'client': invoice.clientName,
      'clientId': invoice.clientId,
      'subject': 'Invoice ${invoice.invoiceNumber}',
      'preview':
          'Invoice ${invoice.invoiceNumber} total ${_money(invoice.total)}',
      'body': _invoiceBody(invoice),
      'time': DateTime.now().toIso8601String(),
      'unread': true,
      'status': 'Queued',
      'direction': 'outbound',
      'thread': 1,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice email queued')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(title: 'Invoices'),
      body: FutureBuilder<_InvoiceData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final data = snapshot.data!;
          final invoices = data.invoices
              .where((invoice) => _status == 'All' || invoice.status == _status)
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const ['All', 'Draft', 'Sent', 'Paid', 'Overdue']
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _status = value ?? 'All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _openSheet(data),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: invoices.isEmpty
                    ? const ApiEmpty('No invoices found.')
                    : RefreshIndicator(
                        onRefresh: () async => _reload(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: invoices.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final invoice = invoices[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          invoice.invoiceNumber,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.slate800,
                                          ),
                                        ),
                                      ),
                                      CrmBadge(invoice.status),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(invoice.clientName),
                                  Text(
                                    'Due ${invoice.dueDate} - ${_money(invoice.total)}',
                                    style: const TextStyle(
                                        color: AppColors.slate500),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () =>
                                            _openSheet(data, invoice),
                                        child: const Text('Edit'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => _email(invoice),
                                        child: const Text('Email'),
                                      ),
                                      TextButton(
                                        onPressed: () => _delete(invoice),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InvoiceSheet extends StatefulWidget {
  final List<Client> clients;
  final Invoice? invoice;

  const _InvoiceSheet({required this.clients, this.invoice});

  @override
  State<_InvoiceSheet> createState() => _InvoiceSheetState();
}

class _InvoiceSheetState extends State<_InvoiceSheet> {
  late String _clientId;
  late String _status;
  late final TextEditingController _number;
  late final TextEditingController _desc;
  late final TextEditingController _qty;
  late final TextEditingController _price;
  late final TextEditingController _tax;
  late final TextEditingController _discount;
  late final TextEditingController _notes;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    final firstItem =
        invoice?.items.isNotEmpty == true ? invoice!.items.first : null;
    _clientId = invoice?.clientId ??
        (widget.clients.isNotEmpty ? widget.clients.first.id : '');
    _status = invoice?.status ?? 'Draft';
    _number = TextEditingController(
      text: invoice?.invoiceNumber ??
          'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    _desc = TextEditingController(text: firstItem?.description ?? '');
    _qty = TextEditingController(text: (firstItem?.quantity ?? 1).toString());
    _price =
        TextEditingController(text: (firstItem?.unitPrice ?? 0).toString());
    _tax = TextEditingController(text: (invoice?.taxRate ?? 18).toString());
    _discount =
        TextEditingController(text: (invoice?.discountRate ?? 0).toString());
    _notes = TextEditingController(text: invoice?.notes ?? '');
  }

  @override
  void dispose() {
    for (final ctrl in [
      _number,
      _desc,
      _qty,
      _price,
      _tax,
      _discount,
      _notes
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    Client? client;
    for (final item in widget.clients) {
      if (item.id == _clientId) {
        client = item;
        break;
      }
    }
    if (client == null) {
      setState(() => _error = 'Client is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final qty = int.tryParse(_qty.text.trim()) ?? 1;
    final price = num.tryParse(_price.text.trim()) ?? 0;
    final subtotal = qty * price;
    final taxRate = num.tryParse(_tax.text.trim()) ?? 0;
    final discountRate = num.tryParse(_discount.text.trim()) ?? 0;
    final taxAmount = subtotal * taxRate / 100;
    final discountAmount = subtotal * discountRate / 100;
    final total = subtotal + taxAmount - discountAmount;
    try {
      await CrmApi.instance.saveInvoice({
        'invoiceNumber': _number.text.trim(),
        'clientId': client.id,
        'clientName': client.name,
        'issueDate': DateTime.now().toIso8601String().substring(0, 10),
        'dueDate': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .substring(0, 10),
        'status': _status,
        'items': [
          {
            'description':
                _desc.text.trim().isEmpty ? 'Service' : _desc.text.trim(),
            'quantity': qty,
            'unitPrice': price,
            'amount': subtotal,
          }
        ],
        'subtotal': subtotal,
        'taxRate': taxRate,
        'taxAmount': taxAmount,
        'discountRate': discountRate,
        'discountAmount': discountAmount,
        'total': total,
        'notes': _notes.text.trim(),
      }, id: widget.invoice?.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.96,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.invoice == null ? 'Create Invoice' : 'Edit Invoice',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            TextField(
                controller: _number,
                decoration: const InputDecoration(labelText: 'Invoice Number')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _clientId.isEmpty ? null : _clientId,
              decoration: const InputDecoration(labelText: 'Client'),
              items: widget.clients
                  .map((client) => DropdownMenuItem(
                      value: client.id, child: Text(client.name)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _clientId = value ?? _clientId),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const ['Draft', 'Sent', 'Paid', 'Overdue']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _desc,
                decoration:
                    const InputDecoration(labelText: 'Item Description')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _qty,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Qty'))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Unit Price'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _tax,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'GST %'))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: _discount,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Discount %'))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes')),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceData {
  final List<Invoice> invoices;
  final List<Client> clients;

  const _InvoiceData(this.invoices, this.clients);
}

String _money(num value) => 'INR ${value.toStringAsFixed(2)}';

String _invoiceBody(Invoice invoice) {
  final items = invoice.items
      .map((item) =>
          '- ${item.description}: ${item.quantity} x ${_money(item.unitPrice)} = ${_money(item.amount)}')
      .join('\n');
  return 'Invoice ${invoice.invoiceNumber}\nClient: ${invoice.clientName}\nDue: ${invoice.dueDate}\nTotal: ${_money(invoice.total)}\n\n$items\n\n${invoice.notes}';
}
