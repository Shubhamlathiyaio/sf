import 'package:equatable/equatable.dart';

/// Events for the Add Item dialog BLoC
abstract class AddItemEvent extends Equatable {
  const AddItemEvent();

  @override
  List<Object?> get props => [];
}

/// Event to update the chalan number field
class UpdateChalanEvent extends AddItemEvent {
  final String chalan;

  const UpdateChalanEvent(this.chalan);

  @override
  List<Object?> get props => [chalan];
}

/// Event to update the description field
class UpdateDescriptionEvent extends AddItemEvent {
  final String description;

  const UpdateDescriptionEvent(this.description);

  @override
  List<Object?> get props => [description];
}

/// Event to update the taka field
class UpdateTakaEvent extends AddItemEvent {
  final String taka;

  const UpdateTakaEvent(this.taka);

  @override
  List<Object?> get props => [taka];
}

/// Event to update the HSN field
class UpdateHsnEvent extends AddItemEvent {
  final String hsn;

  const UpdateHsnEvent(this.hsn);

  @override
  List<Object?> get props => [hsn];
}

/// Event to update the meter field
class UpdateMeterEvent extends AddItemEvent {
  final String meter;

  const UpdateMeterEvent(this.meter);

  @override
  List<Object?> get props => [meter];
}

/// Event to update the rate field
class UpdateRateEvent extends AddItemEvent {
  final String rate;

  const UpdateRateEvent(this.rate);

  @override
  List<Object?> get props => [rate];
}

/// Event to reset all fields
class ResetFieldsEvent extends AddItemEvent {
  const ResetFieldsEvent();
}
