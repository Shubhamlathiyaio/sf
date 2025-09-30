import 'package:flutter_bloc/flutter_bloc.dart';

import 'ui_state.dart';
import 'base_bloc_state.dart';

class UIBloc extends Bloc<UIStateEvent, BaseBlocState> {
  UIBloc() : super(const UIInitialState()) {
    on<SetLoadingEvent>(_onSetLoading);
    on<ShowMessageEvent>(_onShowMessage);
  }

  void _onSetLoading(SetLoadingEvent event, Emitter<BaseBlocState> emit) {
    emit(UILoadingState(isLoading: event.isLoading));
  }

  void _onShowMessage(ShowMessageEvent event, Emitter<BaseBlocState> emit) {
    emit(UIMessageState(message: event.message, type: event.type));
  }
}
