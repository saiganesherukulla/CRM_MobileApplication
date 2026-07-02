part of 'models.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String issueDate;
  final String dueDate;
  final String status;
  final List<InvoiceItem> items;
  final num subtotal;
  final num taxRate;
  final num taxAmount;
  final num discountRate;
  final num discountAmount;
  final num total;
  final String notes;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discountRate,
    required this.discountAmount,
    required this.total,
    required this.notes,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: _string(json['id']),
      invoiceNumber: _string(json['invoiceNumber'], 'INV'),
      clientId: _string(json['clientId']),
      clientName: _string(json['clientName'], 'Client'),
      issueDate: _date(json['issueDate']),
      dueDate: _date(json['dueDate']),
      status: _string(json['status'], 'Draft'),
      items: _mapList(json['items']).map(InvoiceItem.fromJson).toList(),
      subtotal: _num(json['subtotal']),
      taxRate: _num(json['taxRate']),
      taxAmount: _num(json['taxAmount']),
      discountRate: _num(json['discountRate']),
      discountAmount: _num(json['discountAmount']),
      total: _num(json['total']),
      notes: _string(json['notes']),
    );
  }
}

class InvoiceItem {
  final String description;
  final int quantity;
  final num unitPrice;
  final num amount;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: _string(json['description'], 'Service'),
      quantity: _int(json['quantity'], 1),
      unitPrice: _num(json['unitPrice']),
      amount: _num(json['amount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'amount': amount,
      };
}

num _num(dynamic value, [num fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? fallback;
}
