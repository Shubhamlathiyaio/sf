import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc_event.dart';
import 'base_bloc_state.dart';

// Events
class ToggleThemeEvent extends BaseBlocEvent {
  const ToggleThemeEvent();
}

class InitializeAppEvent extends BaseBlocEvent {
  const InitializeAppEvent();
}

// States
class AppInitialState extends BaseBlocState {
  const AppInitialState();
}

class AppLoadedState extends BaseBlocState {
  final bool isDarkMode;

  const AppLoadedState({required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];

  AppLoadedState copyWith({bool? isDarkMode}) {
    return AppLoadedState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}

// BLoC
class AppBloc extends Bloc<BaseBlocEvent, BaseBlocState> {
  AppBloc() : super(const AppInitialState()) {
    on<InitializeAppEvent>(_onInitializeApp);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  void _onInitializeApp(InitializeAppEvent event, Emitter<BaseBlocState> emit) {
    // Initialize app with default settings
    emit(const AppLoadedState(isDarkMode: false));
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<BaseBlocState> emit) {
    if (state is AppLoadedState) {
      final currentState = state as AppLoadedState;
      emit(currentState.copyWith(isDarkMode: !currentState.isDarkMode));
    }
  }
}
