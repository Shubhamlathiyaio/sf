import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@HiveType(typeId: 4)
class Customer extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firmName;

  @HiveField(2)
  final String contactPersonName;

  @HiveField(3)
  final String mobileNumber;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String firmAddress;

  @HiveField(6)
  final String deliveryAddress;

  @HiveField(7)
  final String gstNumber;

  @HiveField(8)
  final String city;

  @HiveField(9)
  final String state;

  @HiveField(10)
  final String stateCode;

  @HiveField(11)
  final String pinCode;

  @HiveField(12)
  final String notes;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.firmName,
    required this.contactPersonName,
    required this.mobileNumber,
    required this.email,
    required this.firmAddress,
    required this.deliveryAddress,
    required this.gstNumber,
    required this.city,
    required this.state,
    required this.stateCode,
    required this.pinCode,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.create({
    required String firmName,
    required String contactPersonName,
    required String mobileNumber,
    String email = '',
    String firmAddress = '',
    String deliveryAddress = '',
    String gstNumber = '',
    String city = '',
    String state = '',
    String stateCode = '',
    String pinCode = '',
    String notes = '',
  }) {
    final uuid = const Uuid();
    final now = DateTime.now();

    return Customer(
      id: uuid.v4(),
      firmName: firmName,
      contactPersonName: contactPersonName,
      mobileNumber: mobileNumber,
      email: email,
      firmAddress: firmAddress,
      deliveryAddress: deliveryAddress.isEmpty ? firmAddress : deliveryAddress,
      gstNumber: gstNumber,
      city: city,
      state: state,
      stateCode: stateCode,
      pinCode: pinCode,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  Customer copyWith({
    String? id,
    String? firmName,
    String? contactPersonName,
    String? mobileNumber,
    String? email,
    String? firmAddress,
    String? deliveryAddress,
    String? gstNumber,
    String? city,
    String? state,
    String? stateCode,
    String? pinCode,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      firmName: firmName ?? this.firmName,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      firmAddress: firmAddress ?? this.firmAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      gstNumber: gstNumber ?? this.gstNumber,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      pinCode: pinCode ?? this.pinCode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    firmName,
    contactPersonName,
    mobileNumber,
    email,
    firmAddress,
    deliveryAddress,
    gstNumber,
    city,
    state,
    stateCode,
    pinCode,
    notes,
    createdAt,
    updatedAt,
  ];

  /// Get full firm address as a single string
  String get fullFirmAddress {
    final parts = [
      firmAddress ?? '',
      city ?? '',
      state ?? '',
      pinCode ?? '',
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Get full delivery address as a single string
  String get fullDeliveryAddress {
    final parts = [
      deliveryAddress ?? '',
      city ?? '',
      state ?? '',
      pinCode ?? '',
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Get initials for avatar display
  String get initials {
    final words = firmName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'F';
  }

  /// Check if customer has complete information
  bool get hasCompleteInfo {
    return firmName.isNotEmpty &&
        mobileNumber.isNotEmpty &&
        firmAddress.isNotEmpty;
  }

  /// Check if customer is GST registered
  bool get isGSTRegistered {
    return gstNumber.isNotEmpty && gstNumber.length == 15;
  }

  /// Get display name (firm name or contact person)
  String get displayName {
    return firmName.isNotEmpty ? firmName : contactPersonName;
  }

  /// Validate GST number format
  bool get isValidGST {
    if (gstNumber.isEmpty) return true; // Optional field
    if (gstNumber.length != 15) return false;

    // Basic GST format validation: 2 digits state code + 10 characters PAN + 1 character entity code + 1 character Z + 1 character checksum
    final gstPattern = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$',
    );
    return gstPattern.hasMatch(gstNumber);
  }
}
