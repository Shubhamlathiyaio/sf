import 'package:equatable/equatable.dart';

/// Base class for all BLoC states in the billing app
abstract class BaseBlocState extends Equatable {
  const BaseBlocState();

  @override
  List<Object?> get props => [];
}

/// Loading state for async operations
class LoadingState extends BaseBlocState {
  const LoadingState();
}

/// Error state with message
class ErrorState extends BaseBlocState {
  final String message;
  final String? details;

  const ErrorState({required this.message, this.details});

  @override
  List<Object?> get props => [message, details];
}

/// Success state for operations
class SuccessState extends BaseBlocState {
  final String? message;

  const SuccessState({this.message});

  @override
  List<Object?> get props => [message];
}
