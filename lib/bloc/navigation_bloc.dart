import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc_event.dart';
import 'base_bloc_state.dart';

// Events
class NavigateToTabEvent extends BaseBlocEvent {
  final int tabIndex;

  const NavigateToTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

// States
class NavigationInitialState extends BaseBlocState {
  const NavigationInitialState();
}

class NavigationTabSelectedState extends BaseBlocState {
  final int selectedTabIndex;

  const NavigationTabSelectedState({required this.selectedTabIndex});

  @override
  List<Object?> get props => [selectedTabIndex];

  NavigationTabSelectedState copyWith({int? selectedTabIndex}) {
    return NavigationTabSelectedState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

// BLoC
class NavigationBloc extends Bloc<BaseBlocEvent, BaseBlocState> {
  NavigationBloc() : super(const NavigationInitialState()) {
    on<NavigateToTabEvent>(_onNavigateToTab);
  }

  void _onNavigateToTab(NavigateToTabEvent event, Emitter<BaseBlocState> emit) {
    emit(NavigationTabSelectedState(selectedTabIndex: event.tabIndex));
  }
}
