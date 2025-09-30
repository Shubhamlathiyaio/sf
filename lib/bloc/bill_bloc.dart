import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/bill.dart';
import '../services/hive_service.dart';
import '../services/bill_management_service.dart';
import 'base_bloc_event.dart';
import 'base_bloc_state.dart';

// Events
class LoadBillsEvent extends BaseBlocEvent {
  const LoadBillsEvent();
}

class AddBillEvent extends BaseBlocEvent {
  final Bill bill;

  const AddBillEvent(this.bill);

  @override
  List<Object?> get props => [bill];
}

class UpdateBillEvent extends BaseBlocEvent {
  final Bill bill;

  const UpdateBillEvent(this.bill);

  @override
  List<Object?> get props => [bill];
}

class DeleteBillEvent extends BaseBlocEvent {
  final String billId;

  const DeleteBillEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}

class SearchBillsEvent extends BaseBlocEvent {
  final String query;

  const SearchBillsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class MarkBillAsPaidEvent extends BaseBlocEvent {
  final String billId;

  const MarkBillAsPaidEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}

class MarkBillAsSentEvent extends BaseBlocEvent {
  final String billId;

  const MarkBillAsSentEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}

class DuplicateBillEvent extends BaseBlocEvent {
  final String billId;

  const DuplicateBillEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}

class LoadBillsByStatusEvent extends BaseBlocEvent {
  final BillStatus status;

  const LoadBillsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

// States
class BillInitialState extends BaseBlocState {
  const BillInitialState();
}

class BillLoadedState extends BaseBlocState {
  final List<Bill> bills;
  final List<Bill> filteredBills;
  final String searchQuery;

  const BillLoadedState({
    required this.bills,
    required this.filteredBills,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [bills, filteredBills, searchQuery];

  BillLoadedState copyWith({
    List<Bill>? bills,
    List<Bill>? filteredBills,
    String? searchQuery,
  }) {
    return BillLoadedState(
      bills: bills ?? this.bills,
      filteredBills: filteredBills ?? this.filteredBills,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// BLoC
class BillBloc extends Bloc<BaseBlocEvent, BaseBlocState> {
  BillBloc() : super(const BillInitialState()) {
    on<LoadBillsEvent>(_onLoadBills);
    on<AddBillEvent>(_onAddBill);
    on<UpdateBillEvent>(_onUpdateBill);
    on<DeleteBillEvent>(_onDeleteBill);
    on<SearchBillsEvent>(_onSearchBills);
    on<MarkBillAsPaidEvent>(_onMarkBillAsPaid);
    on<MarkBillAsSentEvent>(_onMarkBillAsSent);
    on<DuplicateBillEvent>(_onDuplicateBill);
    on<LoadBillsByStatusEvent>(_onLoadBillsByStatus);
  }

  void _onLoadBills(LoadBillsEvent event, Emitter<BaseBlocState> emit) async {
    emit(const LoadingState());

    try {
      // Ensure HiveService is initialized before loading bills
      if (!Hive.isBoxOpen(HiveService.billsBoxName)) {
        throw Exception('Bills box is not initialized');
      }

      // Load bills from Hive database
      final bills = await HiveService.getAllBills();
      emit(BillLoadedState(bills: bills, filteredBills: bills));
    } catch (e) {
      emit(ErrorState(message: 'Failed to load bills: ${e.toString()}'));
    }
  }

  void _onAddBill(AddBillEvent event, Emitter<BaseBlocState> emit) async {
    if (state is BillLoadedState) {
      final currentState = state as BillLoadedState;
      emit(const LoadingState());

      try {
        // Generate sequential bill number if not already set
        Bill billToAdd = event.bill;
        if (billToAdd.billNumber == '1' || billToAdd.billNumber.isEmpty) {
          final nextNumber =
              await BillManagementService.generateNextBillNumber();
          billToAdd = billToAdd.copyWith(billNumber: nextNumber);
        }

        // Save bill to Hive database
        await HiveService.saveBill(billToAdd);

        final updatedBills = [...currentState.bills, billToAdd];
        emit(
          currentState.copyWith(
            bills: updatedBills,
            filteredBills: updatedBills,
          ),
        );
        // Note: Success state will be handled by the UI listener
      } catch (e) {
        emit(ErrorState(message: 'Failed to add bill: ${e.toString()}'));
      }
    } else {
      // Handle case where state is not BillLoadedState
      emit(ErrorState(message: 'Bill data not loaded. Please try again.'));
    }
  }

  void _onUpdateBill(UpdateBillEvent event, Emitter<BaseBlocState> emit) async {
    if (state is BillLoadedState) {
      final currentState = state as BillLoadedState;
      emit(const LoadingState());

      try {
        // Update bill in Hive database
        await HiveService.updateBill(event.bill);

        final updatedBills = currentState.bills.map((bill) {
          return bill.id == event.bill.id ? event.bill : bill;
        }).toList();

        emit(
          currentState.copyWith(
            bills: updatedBills,
            filteredBills: updatedBills,
          ),
        );
        // Note: Success state will be handled by the UI listener
      } catch (e) {
        emit(ErrorState(message: 'Failed to update bill: ${e.toString()}'));
      }
    } else {
      // Handle case where state is not BillLoadedState
      emit(ErrorState(message: 'Bill data not loaded. Please try again.'));
    }
  }

  void _onDeleteBill(DeleteBillEvent event, Emitter<BaseBlocState> emit) async {
    if (state is BillLoadedState) {
      final currentState = state as BillLoadedState;
      emit(const LoadingState());

      try {
        // Delete bill from Hive database
        await HiveService.deleteBill(event.billId);

        final updatedBills = currentState.bills
            .where((bill) => bill.id != event.billId)
            .toList();

        emit(
          currentState.copyWith(
            bills: updatedBills,
            filteredBills: updatedBills,
          ),
        );
        // Note: Success state will be handled by the UI listener
      } catch (e) {
        emit(ErrorState(message: 'Failed to delete bill: ${e.toString()}'));
      }
    } else {
      // Handle case where state is not BillLoadedState
      emit(ErrorState(message: 'Bill data not loaded. Please try again.'));
    }
  }

  void _onSearchBills(SearchBillsEvent event, Emitter<BaseBlocState> emit) {
    if (state is BillLoadedState) {
      final currentState = state as BillLoadedState;

      if (event.query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredBills: currentState.bills,
            searchQuery: event.query,
          ),
        );
      } else {
        final filteredBills = currentState.bills.where((bill) {
          return bill.customerName.toLowerCase().contains(
                event.query.toLowerCase(),
              ) ||
              bill.billNumber.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        emit(
          currentState.copyWith(
            filteredBills: filteredBills,
            searchQuery: event.query,
          ),
        );
      }
    } else {
      // Handle case where state is not BillLoadedState
      emit(ErrorState(message: 'Bill data not loaded. Please try again.'));
    }
  }

  void _onMarkBillAsPaid(
    MarkBillAsPaidEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is BillLoadedState) {
      final currentState = state as BillLoadedState;
      emit(const LoadingState());

      try {
        await BillManagementService.markBillAsPaid(event.billId);

        final updatedBills = currentState.bills.map((bill) {
          if (bill.id == event.billId) {
            return bill.copyWith(status: BillStatus.paid);
          }
          return bill;
        }).toList();

        emit(
          currentState.copyWith(
            bills: updatedBills,
            filteredBills: updatedBills,
          ),
        );
        // Note: Success state will be handled by the UI listener
      } catch (e) {
        emit(
          ErrorState(message: 'Failed to mark bill as paid: ${e.toString()}'),
        );
      }
    } else {
      // Handle case where state is not BillLoadedState
      emit(ErrorState(message: 'Bill data not loaded. Please try again.'));
    }
  }

  void _onMarkBillAsSent(
    MarkBillAsSentEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is BillLoadedState) {
      final currentState = state as BillLoadedState;
      emit(const LoadingState());

      try {
        await BillManagementService.markBillAsSent(event.billId);

        final updatedBills = currentState.bills.map((bill) {
          if (bill.id == event.billId) {
            return bill.copyWith(status: BillStatus.sent);
          }
          return bill;
        }).toList();

        emit(
          currentState.copyWith(
            bills: updatedBills,
            filteredBills: updatedBills,
          ),
        );
        // Note: Success state will be handled by the UI listener
      } catch (e) {
        emit(
          ErrorState(message: 'Failed to mark bill as sent: ${e.toString()}'),
        );
      }
    } else {
      // Handle case where state is not BillLoadedState
      emit(ErrorState(message: 'Bill data not loaded. Please try again.'));
    }
  }

  void _onDuplicateBill(
    DuplicateBillEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    if (state is BillLoadedState) {
      final currentState = state as BillLoadedState;
      emit(const LoadingState());

      try {
        final duplicatedBill = await BillManagementService.duplicateBill(
          event.billId,
        );

        final updatedBills = [...currentState.bills, duplicatedBill];

        emit(
          currentState.copyWith(
            bills: updatedBills,
            filteredBills: updatedBills,
          ),
        );
        // Note: Success state will be handled by the UI listener
      } catch (e) {
        emit(ErrorState(message: 'Failed to duplicate bill: ${e.toString()}'));
      }
    } else {
      // Handle case where state is not BillLoadedState
      emit(ErrorState(message: 'Bill data not loaded. Please try again.'));
    }
  }

  void _onLoadBillsByStatus(
    LoadBillsByStatusEvent event,
    Emitter<BaseBlocState> emit,
  ) async {
    emit(const LoadingState());

    try {
      final bills = await BillManagementService.getBillsByStatus(event.status);
      emit(BillLoadedState(bills: bills, filteredBills: bills));
    } catch (e) {
      emit(
        ErrorState(message: 'Failed to load bills by status: ${e.toString()}'),
      );
    }
  }
}
