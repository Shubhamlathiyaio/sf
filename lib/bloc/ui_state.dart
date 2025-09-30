import 'package:equatable/equatable.dart';

import 'base_bloc_state.dart';

/// UI State Events
abstract class UIStateEvent extends Equatable {
  const UIStateEvent();

  @override
  List<Object?> get props => [];
}

class SetLoadingEvent extends UIStateEvent {
  final bool isLoading;

  const SetLoadingEvent(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class ShowMessageEvent extends UIStateEvent {
  final String message;
  final MessageType type;

  const ShowMessageEvent(this.message, this.type);

  @override
  List<Object?> get props => [message, type];
}

enum MessageType { info, success, warning, error }

/// UI State States
class UIInitialState extends BaseBlocState {
  const UIInitialState();
}

class UILoadingState extends BaseBlocState {
  final bool isLoading;

  const UILoadingState({required this.isLoading});

  @override
  List<Object?> get props => [isLoading];

  UILoadingState copyWith({bool? isLoading}) {
    return UILoadingState(isLoading: isLoading ?? this.isLoading);
  }
}

class UIMessageState extends BaseBlocState {
  final String message;
  final MessageType type;

  const UIMessageState({required this.message, required this.type});

  @override
  List<Object?> get props => [message, type];

  UIMessageState copyWith({String? message, MessageType? type}) {
    return UIMessageState(
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }
}
