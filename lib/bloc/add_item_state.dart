import 'package:equatable/equatable.dart';

/// States for the Add Item dialog BLoC
abstract class AddItemState extends Equatable {
  const AddItemState();

  @override
  List<Object?> get props => [];
}

/// Initial state with empty fields
class AddItemInitialState extends AddItemState {
  final String chalan;
  final String description;
  final String taka;
  final String hsn;
  final String meter;
  final String rate;

  const AddItemInitialState({
    this.chalan = '',
    this.description = '',
    this.taka = '',
    this.hsn = '',
    this.meter = '',
    this.rate = '',
  });

  AddItemInitialState copyWith({
    String? chalan,
    String? description,
    String? taka,
    String? hsn,
    String? meter,
    String? rate,
  }) {
    return AddItemInitialState(
      chalan: chalan ?? this.chalan,
      description: description ?? this.description,
      taka: taka ?? this.taka,
      hsn: hsn ?? this.hsn,
      meter: meter ?? this.meter,
      rate: rate ?? this.rate,
    );
  }

  @override
  List<Object?> get props => [chalan, description, taka, hsn, meter, rate];
}

/// State when fields are updated
class AddItemUpdatedState extends AddItemState {
  final String chalan;
  final String description;
  final String taka;
  final String hsn;
  final String meter;
  final String rate;

  const AddItemUpdatedState({
    required this.chalan,
    required this.description,
    required this.taka,
    required this.hsn,
    required this.meter,
    required this.rate,
  });

  AddItemUpdatedState copyWith({
    String? chalan,
    String? description,
    String? taka,
    String? hsn,
    String? meter,
    String? rate,
  }) {
    return AddItemUpdatedState(
      chalan: chalan ?? this.chalan,
      description: description ?? this.description,
      taka: taka ?? this.taka,
      hsn: hsn ?? this.hsn,
      meter: meter ?? this.meter,
      rate: rate ?? this.rate,
    );
  }

  @override
  List<Object?> get props => [chalan, description, taka, hsn, meter, rate];
}
