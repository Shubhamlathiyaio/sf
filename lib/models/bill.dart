import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bill.g.dart';

@HiveType(typeId: 0)
class Bill extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String billNumber;

  @HiveField(2)
  final String customerName;

  @HiveField(3)
  final String customerPhone;

  @HiveField(4)
  final String customerEmail;

  @HiveField(5)
  final DateTime billDate;

  @HiveField(6)
  final DateTime dueDate;

  @HiveField(7)
  final List<BillItem> items;

  @HiveField(8)
  final double subtotal;

  @HiveField(9)
  final double taxAmount;

  @HiveField(10)
  final double discountAmount;

  @HiveField(11)
  final double totalAmount;

  @HiveField(12)
  final BillStatus status;

  @HiveField(13)
  final String notes;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  const Bill({
    required this.id,
    required this.billNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.billDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.create({
    String? billNumber,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required DateTime billDate,
    required DateTime dueDate,
    required List<BillItem> items,
    required double taxAmount,
    required double discountAmount,
    String notes = '',
  }) {
    final uuid = const Uuid();
    final now = DateTime.now();
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final totalAmount = subtotal + taxAmount - discountAmount;

    return Bill(
      id: uuid.v4(),
      billNumber: billNumber ?? '1', // Default to '1' if not provided
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      billDate: billDate,
      dueDate: dueDate,
      items: items,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      status: BillStatus.draft,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  Bill copyWith({
    String? id,
    String? billNumber,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    DateTime? billDate,
    DateTime? dueDate,
    List<BillItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    BillStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      billDate: billDate ?? this.billDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    billNumber,
    customerName,
    customerPhone,
    customerEmail,
    billDate,
    dueDate,
    items,
    subtotal,
    taxAmount,
    discountAmount,
    totalAmount,
    status,
    notes,
    createdAt,
    updatedAt,
  ];
}

@HiveType(typeId: 1)
class BillItem extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double quantity;

  @HiveField(4)
  final double unitPrice;

  @HiveField(5)
  final double totalPrice;

  @HiveField(6)
  final String unit;

  const BillItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.unit,
  });

  factory BillItem.create({
    required String name,
    required String description,
    required double quantity,
    required double unitPrice,
    required String unit,
  }) {
    final uuid = const Uuid();
    return BillItem(
      id: uuid.v4(),
      name: name,
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: quantity * unitPrice,
      unit: unit,
    );
  }

  BillItem copyWith({
    String? id,
    String? name,
    String? description,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    String? unit,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    quantity,
    unitPrice,
    totalPrice,
    unit,
  ];
}

@HiveType(typeId: 2)
enum BillStatus {
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
}

extension BillStatusExtension on BillStatus {
  String get displayName {
    switch (this) {
      case BillStatus.draft:
        return 'Draft';
      case BillStatus.sent:
        return 'Sent';
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.overdue:
        return 'Overdue';
      case BillStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get colorName {
    switch (this) {
      case BillStatus.draft:
        return 'grey';
      case BillStatus.sent:
        return 'blue';
      case BillStatus.paid:
        return 'green';
      case BillStatus.overdue:
        return 'red';
      case BillStatus.cancelled:
        return 'orange';
    }
  }
}
