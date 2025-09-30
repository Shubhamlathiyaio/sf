// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceAdapter extends TypeAdapter<Invoice> {
  @override
  final int typeId = 6;

  @override
  Invoice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Invoice(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      invoiceDate: fields[2] as DateTime,
      customerId: fields[3] as String,
      companyId: fields[4] as String,
      items: (fields[5] as List).cast<InvoiceItem>(),
      subtotal: fields[6] as double,
      discount: fields[7] as double,
      otherDeductions: fields[8] as double,
      freight: fields[9] as double,
      taxableValue: fields[10] as double,
      igstAmount: fields[11] as double,
      sgstAmount: fields[12] as double,
      cgstAmount: fields[13] as double,
      totalTaxAmount: fields[14] as double,
      netAmount: fields[15] as double,
      dueDays: fields[16] as int,
      dueDate: fields[17] as DateTime,
      broker: fields[18] as String,
      amountInWords: fields[19] as String,
      notes: fields[20] as String,
      status: fields[21] as InvoiceStatus,
      createdAt: fields[22] as DateTime,
      updatedAt: fields[23] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Invoice obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.invoiceDate)
      ..writeByte(3)
      ..write(obj.customerId)
      ..writeByte(4)
      ..write(obj.companyId)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.subtotal)
      ..writeByte(7)
      ..write(obj.discount)
      ..writeByte(8)
      ..write(obj.otherDeductions)
      ..writeByte(9)
      ..write(obj.freight)
      ..writeByte(10)
      ..write(obj.taxableValue)
      ..writeByte(11)
      ..write(obj.igstAmount)
      ..writeByte(12)
      ..write(obj.sgstAmount)
      ..writeByte(13)
      ..write(obj.cgstAmount)
      ..writeByte(14)
      ..write(obj.totalTaxAmount)
      ..writeByte(15)
      ..write(obj.netAmount)
      ..writeByte(16)
      ..write(obj.dueDays)
      ..writeByte(17)
      ..write(obj.dueDate)
      ..writeByte(18)
      ..write(obj.broker)
      ..writeByte(19)
      ..write(obj.amountInWords)
      ..writeByte(20)
      ..write(obj.notes)
      ..writeByte(21)
      ..write(obj.status)
      ..writeByte(22)
      ..write(obj.createdAt)
      ..writeByte(23)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceItemAdapter extends TypeAdapter<InvoiceItem> {
  @override
  final int typeId = 7;

  @override
  InvoiceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItem(
      id: fields[0] as String,
      srNo: fields[1] as int,
      chalanNo: fields[2] as String,
      description: fields[3] as String,
      taka: fields[4] as double,
      hsnCode: fields[5] as String,
      meter: fields[6] as double,
      rate: fields[7] as double,
      amount: fields[8] as double,
      gstRate: fields[9] as double,
      unit: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.srNo)
      ..writeByte(2)
      ..write(obj.chalanNo)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.taka)
      ..writeByte(5)
      ..write(obj.hsnCode)
      ..writeByte(6)
      ..write(obj.meter)
      ..writeByte(7)
      ..write(obj.rate)
      ..writeByte(8)
      ..write(obj.amount)
      ..writeByte(9)
      ..write(obj.gstRate)
      ..writeByte(10)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceStatusAdapter extends TypeAdapter<InvoiceStatus> {
  @override
  final int typeId = 8;

  @override
  InvoiceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvoiceStatus.draft;
      case 1:
        return InvoiceStatus.sent;
      case 2:
        return InvoiceStatus.paid;
      case 3:
        return InvoiceStatus.overdue;
      case 4:
        return InvoiceStatus.cancelled;
      case 5:
        return InvoiceStatus.partiallyPaid;
      default:
        return InvoiceStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, InvoiceStatus obj) {
    switch (obj) {
      case InvoiceStatus.draft:
        writer.writeByte(0);
        break;
      case InvoiceStatus.sent:
        writer.writeByte(1);
        break;
      case InvoiceStatus.paid:
        writer.writeByte(2);
        break;
      case InvoiceStatus.overdue:
        writer.writeByte(3);
        break;
      case InvoiceStatus.cancelled:
        writer.writeByte(4);
        break;
      case InvoiceStatus.partiallyPaid:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
