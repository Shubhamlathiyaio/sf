import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'organization.g.dart';

@HiveType(typeId: 3)
class Organization extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String ownerId;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int currentChalanNumber;

  const Organization({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    required this.currentChalanNumber,
  });

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    int? currentChalanNumber,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      currentChalanNumber: currentChalanNumber ?? this.currentChalanNumber,
    );
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      currentChalanNumber: json['current_chalan_number'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    ownerId,
    createdAt,
    currentChalanNumber,
  ];
}
