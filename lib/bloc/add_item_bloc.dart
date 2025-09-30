import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_item_event.dart';
import 'add_item_state.dart';

/// BLoC for managing the Add Item dialog state
class AddItemBloc extends Bloc<AddItemEvent, AddItemState> {
  AddItemBloc() : super(const AddItemInitialState()) {
    on<UpdateChalanEvent>(_onUpdateChalan);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<UpdateTakaEvent>(_onUpdateTaka);
    on<UpdateHsnEvent>(_onUpdateHsn);
    on<UpdateMeterEvent>(_onUpdateMeter);
    on<UpdateRateEvent>(_onUpdateRate);
    on<ResetFieldsEvent>(_onResetFields);
  }

  void _onUpdateChalan(UpdateChalanEvent event, Emitter<AddItemState> emit) {
    if (state is AddItemInitialState) {
      final currentState = state as AddItemInitialState;
      emit(
        AddItemUpdatedState(
          chalan: event.chalan,
          description: currentState.description,
          taka: currentState.taka,
          hsn: currentState.hsn,
          meter: currentState.meter,
          rate: currentState.rate,
        ),
      );
    } else if (state is AddItemUpdatedState) {
      final currentState = state as AddItemUpdatedState;
      emit(currentState.copyWith(chalan: event.chalan));
    } else {
      emit(
        AddItemUpdatedState(
          chalan: event.chalan,
          description: '',
          taka: '',
          hsn: '',
          meter: '',
          rate: '',
        ),
      );
    }
  }

  void _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<AddItemState> emit,
  ) {
    if (state is AddItemInitialState) {
      final currentState = state as AddItemInitialState;
      emit(
        AddItemUpdatedState(
          chalan: currentState.chalan,
          description: event.description,
          taka: currentState.taka,
          hsn: currentState.hsn,
          meter: currentState.meter,
          rate: currentState.rate,
        ),
      );
    } else if (state is AddItemUpdatedState) {
      final currentState = state as AddItemUpdatedState;
      emit(currentState.copyWith(description: event.description));
    } else {
      emit(
        AddItemUpdatedState(
          chalan: '',
          description: event.description,
          taka: '',
          hsn: '',
          meter: '',
          rate: '',
        ),
      );
    }
  }

  void _onUpdateTaka(UpdateTakaEvent event, Emitter<AddItemState> emit) {
    if (state is AddItemInitialState) {
      final currentState = state as AddItemInitialState;
      emit(
        AddItemUpdatedState(
          chalan: currentState.chalan,
          description: currentState.description,
          taka: event.taka,
          hsn: currentState.hsn,
          meter: currentState.meter,
          rate: currentState.rate,
        ),
      );
    } else if (state is AddItemUpdatedState) {
      final currentState = state as AddItemUpdatedState;
      emit(currentState.copyWith(taka: event.taka));
    } else {
      emit(
        AddItemUpdatedState(
          chalan: '',
          description: '',
          taka: event.taka,
          hsn: '',
          meter: '',
          rate: '',
        ),
      );
    }
  }

  void _onUpdateHsn(UpdateHsnEvent event, Emitter<AddItemState> emit) {
    if (state is AddItemInitialState) {
      final currentState = state as AddItemInitialState;
      emit(
        AddItemUpdatedState(
          chalan: currentState.chalan,
          description: currentState.description,
          taka: currentState.taka,
          hsn: event.hsn,
          meter: currentState.meter,
          rate: currentState.rate,
        ),
      );
    } else if (state is AddItemUpdatedState) {
      final currentState = state as AddItemUpdatedState;
      emit(currentState.copyWith(hsn: event.hsn));
    } else {
      emit(
        AddItemUpdatedState(
          chalan: '',
          description: '',
          taka: '',
          hsn: event.hsn,
          meter: '',
          rate: '',
        ),
      );
    }
  }

  void _onUpdateMeter(UpdateMeterEvent event, Emitter<AddItemState> emit) {
    if (state is AddItemInitialState) {
      final currentState = state as AddItemInitialState;
      emit(
        AddItemUpdatedState(
          chalan: currentState.chalan,
          description: currentState.description,
          taka: currentState.taka,
          hsn: currentState.hsn,
          meter: event.meter,
          rate: currentState.rate,
        ),
      );
    } else if (state is AddItemUpdatedState) {
      final currentState = state as AddItemUpdatedState;
      emit(currentState.copyWith(meter: event.meter));
    } else {
      emit(
        AddItemUpdatedState(
          chalan: '',
          description: '',
          taka: '',
          hsn: '',
          meter: event.meter,
          rate: '',
        ),
      );
    }
  }

  void _onUpdateRate(UpdateRateEvent event, Emitter<AddItemState> emit) {
    if (state is AddItemInitialState) {
      final currentState = state as AddItemInitialState;
      emit(
        AddItemUpdatedState(
          chalan: currentState.chalan,
          description: currentState.description,
          taka: currentState.taka,
          hsn: currentState.hsn,
          meter: currentState.meter,
          rate: event.rate,
        ),
      );
    } else if (state is AddItemUpdatedState) {
      final currentState = state as AddItemUpdatedState;
      emit(currentState.copyWith(rate: event.rate));
    } else {
      emit(
        AddItemUpdatedState(
          chalan: '',
          description: '',
          taka: '',
          hsn: '',
          meter: '',
          rate: event.rate,
        ),
      );
    }
  }

  void _onResetFields(ResetFieldsEvent event, Emitter<AddItemState> emit) {
    emit(const AddItemInitialState());
  }
}
