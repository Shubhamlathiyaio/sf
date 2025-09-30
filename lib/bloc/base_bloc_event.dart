import 'package:equatable/equatable.dart';

/// Base class for all BLoC events in the billing app
abstract class BaseBlocEvent extends Equatable {
  const BaseBlocEvent();

  @override
  List<Object?> get props => [];
}
