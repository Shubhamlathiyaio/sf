import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'company.g.dart';

@HiveType(typeId: 5)
class Company extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String companyName;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final String state;

  @HiveField(5)
  final String stateCode;

  @HiveField(6)
  final String pinCode;

  @HiveField(7)
  final String gstNumber;

  @HiveField(8)
  final String mobileNumber;

  @HiveField(9)
  final String email;

  @HiveField(10)
  final String logoPath;

  @HiveField(11)
  final String termsAndConditions;

  @HiveField(12)
  final String ownerName;

  @HiveField(13)
  final String signaturePath;

  @HiveField(14)
  final String bankName;

  @HiveField(15)
  final String accountNumber;

  @HiveField(16)
  final String ifscCode;

  @HiveField(17)
  final String branchName;

  @HiveField(18)
  final DateTime createdAt;

  @HiveField(19)
  final DateTime updatedAt;

  const Company({
    required this.id,
    required this.companyName,
    required this.address,
    required this.city,
    required this.state,
    required this.stateCode,
    required this.pinCode,
    required this.gstNumber,
    required this.mobileNumber,
    required this.email,
    required this.logoPath,
    required this.termsAndConditions,
    required this.ownerName,
    required this.signaturePath,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branchName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.create({
    required String companyName,
    required String address,
    required String city,
    required String state,
    required String stateCode,
    required String pinCode,
    required String gstNumber,
    required String mobileNumber,
    String email = '',
    String logoPath = '',
    String termsAndConditions = '',
    String ownerName = '',
    String signaturePath = '',
    String bankName = '',
    String accountNumber = '',
    String ifscCode = '',
    String branchName = '',
  }) {
    final uuid = const Uuid();
    final now = DateTime.now();

    return Company(
      id: uuid.v4(),
      companyName: companyName,
      address: address,
      city: city,
      state: state,
      stateCode: stateCode,
      pinCode: pinCode,
      gstNumber: gstNumber,
      mobileNumber: mobileNumber,
      email: email,
      logoPath: logoPath,
      termsAndConditions: termsAndConditions,
      ownerName: ownerName,
      signaturePath: signaturePath,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      branchName: branchName,
      createdAt: now,
      updatedAt: now,
    );
  }

  Company copyWith({
    String? id,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? stateCode,
    String? pinCode,
    String? gstNumber,
    String? mobileNumber,
    String? email,
    String? logoPath,
    String? termsAndConditions,
    String? ownerName,
    String? signaturePath,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      pinCode: pinCode ?? this.pinCode,
      gstNumber: gstNumber ?? this.gstNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      ownerName: ownerName ?? this.ownerName,
      signaturePath: signaturePath ?? this.signaturePath,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyName,
    address,
    city,
    state,
    stateCode,
    pinCode,
    gstNumber,
    mobileNumber,
    email,
    logoPath,
    termsAndConditions,
    ownerName,
    signaturePath,
    bankName,
    accountNumber,
    ifscCode,
    branchName,
    createdAt,
    updatedAt,
  ];

  /// Get full company address
  String get fullAddress {
    final parts = [
      address ?? '',
      city ?? '',
      state ?? '',
      pinCode ?? '',
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Check if company has complete information
  bool get hasCompleteInfo {
    return companyName.isNotEmpty &&
        address.isNotEmpty &&
        gstNumber.isNotEmpty &&
        mobileNumber.isNotEmpty &&
        stateCode.isNotEmpty;
  }

  /// Validate GST number format
  bool get isValidGST {
    if (gstNumber.length != 15) return false;

    final gstPattern = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$',
    );
    return gstPattern.hasMatch(gstNumber);
  }

  /// Check if company has logo
  bool get hasLogo {
    return logoPath.isNotEmpty;
  }

  /// Check if company has signature
  bool get hasSignature {
    return signaturePath.isNotEmpty;
  }

  /// Get default terms and conditions
  static String get defaultTermsAndConditions {
    return '''1. Payment is due within 30 days of invoice date.
2. Interest @ 2% per month will be charged on overdue amounts.
3. All disputes are subject to local jurisdiction only.
4. Goods once sold will not be taken back.
5. Our responsibility ceases once the goods leave our premises.''';
  }
}
