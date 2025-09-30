import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'invoice.g.dart';

@HiveType(typeId: 6)
class Invoice extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invoiceNumber;

  @HiveField(2) 
  final DateTime invoiceDate;

  @HiveField(3)
  final String customerId;

  @HiveField(4)
  final String companyId;

  @HiveField(5)
  final List<InvoiceItem> items;

  @HiveField(6)
  final double subtotal;

  @HiveField(7)
  final double discount;

  @HiveField(8)
  final double otherDeductions;

  @HiveField(9)
  final double freight;

  @HiveField(10)
  final double taxableValue;

  @HiveField(11)
  final double igstAmount;

  @HiveField(12)
  final double sgstAmount;

  @HiveField(13)
  final double cgstAmount;

  @HiveField(14)
  final double totalTaxAmount;

  @HiveField(15)
  final double netAmount;

  @HiveField(16)
  final int dueDays;

  @HiveField(17)
  final DateTime dueDate;

  @HiveField(18)
  final String broker;

  @HiveField(19)
  final String amountInWords;

  @HiveField(20)
  final String notes;

  @HiveField(21)
  final InvoiceStatus status;

  @HiveField(22)
  final DateTime createdAt;

  @HiveField(23)
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerId,
    required this.companyId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.otherDeductions,
    required this.freight,
    required this.taxableValue,
    required this.igstAmount,
    required this.sgstAmount,
    required this.cgstAmount,
    required this.totalTaxAmount,
    required this.netAmount,
    required this.dueDays,
    required this.dueDate,
    required this.broker,
    required this.amountInWords,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.create({
    required String customerId,
    required String companyId,
    required List<InvoiceItem> items,
    String invoiceNumber = '',
    DateTime? invoiceDate,
    double discount = 0.0,
    double otherDeductions = 0.0,
    double freight = 0.0,
    int dueDays = 30,
    String broker = '',
    String notes = '',
  }) {
    final uuid = const Uuid();
    final now = DateTime.now();
    final date = invoiceDate ?? now;

    // Calculate subtotal
    final subtotal = items.fold(0.0, (sum, item) => sum + item.amount);

    // Calculate taxable value
    final taxableValue = subtotal - discount - otherDeductions + freight;

    // Calculate GST amounts
    final totalTaxRate = items.fold(0.0, (sum, item) => sum + item.gstRate);
    final avgTaxRate = items.isNotEmpty ? totalTaxRate / items.length : 0.0;

    // For inter-state transactions, use IGST; for intra-state, use SGST + CGST
    double igstAmount = 0.0;
    double sgstAmount = 0.0;
    double cgstAmount = 0.0;

    // This would be determined by comparing company and customer state codes
    // For now, assuming intra-state transaction
    final gstAmount = taxableValue * (avgTaxRate / 100);
    sgstAmount = gstAmount / 2;
    cgstAmount = gstAmount / 2;

    final totalTaxAmount = igstAmount + sgstAmount + cgstAmount;
    final netAmount = taxableValue + totalTaxAmount;

    return Invoice(
      id: uuid.v4(),
      invoiceNumber: invoiceNumber.isEmpty
          ? _generateInvoiceNumber(date)
          : invoiceNumber,
      invoiceDate: date,
      customerId: customerId,
      companyId: companyId,
      items: items,
      subtotal: subtotal,
      discount: discount,
      otherDeductions: otherDeductions,
      freight: freight,
      taxableValue: taxableValue,
      igstAmount: igstAmount,
      sgstAmount: sgstAmount,
      cgstAmount: cgstAmount,
      totalTaxAmount: totalTaxAmount,
      netAmount: netAmount,
      dueDays: dueDays,
      dueDate: date.add(Duration(days: dueDays)),
      broker: broker,
      amountInWords: _convertAmountToWords(netAmount),
      notes: notes,
      status: InvoiceStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? customerId,
    String? companyId,
    List<InvoiceItem>? items,
    double? subtotal,
    double? discount,
    double? otherDeductions,
    double? freight,
    double? taxableValue,
    double? igstAmount,
    double? sgstAmount,
    double? cgstAmount,
    double? totalTaxAmount,
    double? netAmount,
    int? dueDays,
    DateTime? dueDate,
    String? broker,
    String? amountInWords,
    String? notes,
    InvoiceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      customerId: customerId ?? this.customerId,
      companyId: companyId ?? this.companyId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      freight: freight ?? this.freight,
      taxableValue: taxableValue ?? this.taxableValue,
      igstAmount: igstAmount ?? this.igstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      totalTaxAmount: totalTaxAmount ?? this.totalTaxAmount,
      netAmount: netAmount ?? this.netAmount,
      dueDays: dueDays ?? this.dueDays,
      dueDate: dueDate ?? this.dueDate,
      broker: broker ?? this.broker,
      amountInWords: amountInWords ?? this.amountInWords,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    invoiceDate,
    customerId,
    companyId,
    items,
    subtotal,
    discount,
    otherDeductions,
    freight,
    taxableValue,
    igstAmount,
    sgstAmount,
    cgstAmount,
    totalTaxAmount,
    netAmount,
    dueDays,
    dueDate,
    broker,
    amountInWords,
    notes,
    status,
    createdAt,
    updatedAt,
  ];

  static String _generateInvoiceNumber(DateTime date) {
    return 'INV-${date.year}-${date.millisecondsSinceEpoch.toString().substring(8)}';
  }

  static String _convertAmountToWords(double amount) {
    // Simplified version - in production, use a proper number-to-words library
    final rupees = amount.floor();
    final paise = ((amount - rupees) * 100).round();

    if (paise > 0) {
      return 'Rupees $rupees and $paise Paise Only';
    } else {
      return 'Rupees $rupees Only';
    }
  }
}

@HiveType(typeId: 7)
class InvoiceItem extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int srNo;

  @HiveField(2)
  final String chalanNo;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double taka;

  @HiveField(5)
  final String hsnCode;

  @HiveField(6)
  final double meter;

  @HiveField(7)
  final double rate;

  @HiveField(8)
  final double amount;

  @HiveField(9)
  final double gstRate;

  @HiveField(10)
  final String unit;

  const InvoiceItem({
    required this.id,
    required this.srNo,
    required this.chalanNo,
    required this.description,
    required this.taka,
    required this.hsnCode,
    required this.meter,
    required this.rate,
    required this.amount,
    required this.gstRate,
    required this.unit,
  });

  factory InvoiceItem.create({
    required int srNo,
    required String description,
    required double taka,
    required double meter,
    required double rate,
    required double gstRate,
    String chalanNo = '',
    String hsnCode = '',
    String unit = 'Nos',
  }) {
    final uuid = const Uuid();
    final amount = taka * meter * rate;

    return InvoiceItem(
      id: uuid.v4(),
      srNo: srNo,
      chalanNo: chalanNo,
      description: description,
      taka: taka,
      hsnCode: hsnCode,
      meter: meter,
      rate: rate,
      amount: amount,
      gstRate: gstRate,
      unit: unit,
    );
  }

  InvoiceItem copyWith({
    String? id,
    int? srNo,
    String? chalanNo,
    String? description,
    double? taka,
    String? hsnCode,
    double? meter,
    double? rate,
    double? amount,
    double? gstRate,
    String? unit,
  }) {
    final newAmount =
        amount ??
        ((taka ?? this.taka) * (meter ?? this.meter) * (rate ?? this.rate));

    return InvoiceItem(
      id: id ?? this.id,
      srNo: srNo ?? this.srNo,
      chalanNo: chalanNo ?? this.chalanNo,
      description: description ?? this.description,
      taka: taka ?? this.taka,
      hsnCode: hsnCode ?? this.hsnCode,
      meter: meter ?? this.meter,
      rate: rate ?? this.rate,
      amount: newAmount,
      gstRate: gstRate ?? this.gstRate,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props => [
    id,
    srNo,
    chalanNo,
    description,
    taka,
    hsnCode,
    meter,
    rate,
    amount,
    gstRate,
    unit,
  ];
}

@HiveType(typeId: 8)
enum InvoiceStatus {
  @HiveField(0)
  draft,

  @HiveField(1)
  sent,

  @HiveField(2)
  paid,

  @HiveField(3)
  overdue,

  @HiveField(4)
  cancelled,

  @HiveField(5)
  partiallyPaid,
}

extension InvoiceStatusExtension on InvoiceStatus {
  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
    }
  }

  String get colorName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'grey';
      case InvoiceStatus.sent:
        return 'blue';
      case InvoiceStatus.paid:
        return 'green';
      case InvoiceStatus.overdue:
        return 'red';
      case InvoiceStatus.cancelled:
        return 'orange';
      case InvoiceStatus.partiallyPaid:
        return 'yellow';
    }
  }
}
