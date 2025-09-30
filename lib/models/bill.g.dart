// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 0;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      id: fields[0] as String,
      billNumber: fields[1] as String,
      customerName: fields[2] as String,
      customerPhone: fields[3] as String,
      customerEmail: fields[4] as String,
      billDate: fields[5] as DateTime,
      dueDate: fields[6] as DateTime,
      items: (fields[7] as List).cast<BillItem>(),
      subtotal: fields[8] as double,
      taxAmount: fields[9] as double,
      discountAmount: fields[10] as double,
      totalAmount: fields[11] as double,
      status: fields[12] as BillStatus,
      notes: fields[13] as String,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.billNumber)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.customerPhone)
      ..writeByte(4)
      ..write(obj.customerEmail)
      ..writeByte(5)
      ..write(obj.billDate)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.items)
      ..writeByte(8)
      ..write(obj.subtotal)
      ..writeByte(9)
      ..write(obj.taxAmount)
      ..writeByte(10)
      ..write(obj.discountAmount)
      ..writeByte(11)
      ..write(obj.totalAmount)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillItemAdapter extends TypeAdapter<BillItem> {
  @override
  final int typeId = 1;

  @override
  BillItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      quantity: fields[3] as double,
      unitPrice: fields[4] as double,
      totalPrice: fields[5] as double,
      unit: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BillItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.totalPrice)
      ..writeByte(6)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillStatusAdapter extends TypeAdapter<BillStatus> {
  @override
  final int typeId = 2;

  @override
  BillStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillStatus.draft;
      case 1:
        return BillStatus.sent;
      case 2:
        return BillStatus.paid;
      case 3:
        return BillStatus.overdue;
      case 4:
        return BillStatus.cancelled;
      default:
        return BillStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, BillStatus obj) {
    switch (obj) {
      case BillStatus.draft:
        writer.writeByte(0);
        break;
      case BillStatus.sent:
        writer.writeByte(1);
        break;
      case BillStatus.paid:
        writer.writeByte(2);
        break;
      case BillStatus.overdue:
        writer.writeByte(3);
        break;
      case BillStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
