// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 4;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      id: fields[0] as String,
      firmName: fields[1] as String,
      contactPersonName: fields[2] as String,
      mobileNumber: fields[3] as String,
      email: fields[4] as String,
      firmAddress: fields[5] as String,
      deliveryAddress: fields[6] as String,
      gstNumber: fields[7] as String,
      city: fields[8] as String,
      state: fields[9] as String,
      stateCode: fields[10] as String,
      pinCode: fields[11] as String,
      notes: fields[12] as String,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firmName)
      ..writeByte(2)
      ..write(obj.contactPersonName)
      ..writeByte(3)
      ..write(obj.mobileNumber)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.firmAddress)
      ..writeByte(6)
      ..write(obj.deliveryAddress)
      ..writeByte(7)
      ..write(obj.gstNumber)
      ..writeByte(8)
      ..write(obj.city)
      ..writeByte(9)
      ..write(obj.state)
      ..writeByte(10)
      ..write(obj.stateCode)
      ..writeByte(11)
      ..write(obj.pinCode)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
