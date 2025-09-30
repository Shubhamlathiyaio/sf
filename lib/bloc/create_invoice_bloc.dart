import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_invoice_event.dart';
import 'create_invoice_state.dart';
import 'base_bloc_state.dart';
import '../models/detailed_bill_item.dart';
import '../services/bill_management_service.dart';

class CreateInvoiceBloc extends Bloc<CreateInvoiceEvent, CreateInvoiceState> {
  CreateInvoiceBloc() : super(CreateInvoiceInitialState()) {
    on<SetSelectedCustomerEvent>(_onSetSelectedCustomer);
    on<SetDefaultCompanyEvent>(_onSetDefaultCompany);
    on<SetBillDateEvent>(_onSetBillDate);
    on<SetDueDateEvent>(_onSetDueDate);
    on<SetShowCustomerListEvent>(_onSetShowCustomerList);
    on<SetFilteredCustomersEvent>(_onSetFilteredCustomers);
    on<AddBillItemEvent>(_onAddBillItem);
    on<UpdateBillItemEvent>(_onUpdateBillItem);
    on<RemoveBillItemEvent>(_onRemoveBillItem);
    on<ClearBillItemsEvent>(_onClearBillItems);
    on<SetNotesEvent>(_onSetNotes);
    on<SetDiscountEvent>(_onSetDiscount);
    on<SetTaxEvent>(_onSetTax);
    on<SetBillNumberEvent>(_onSetBillNumber);
    on<CreateBillEvent>(_onCreateBill);
    on<ResetCreateInvoiceEvent>(_onResetCreateInvoice);
  }

  void _onSetSelectedCustomer(
    SetSelectedCustomerEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(selectedCustomer: event.customer));
  }

  void _onSetDefaultCompany(
    SetDefaultCompanyEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(defaultCompany: event.company));
  }

  void _onSetBillDate(
    SetBillDateEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(billDate: event.date));
  }

  void _onSetDueDate(SetDueDateEvent event, Emitter<CreateInvoiceState> emit) {
    emit(state.copyWith(dueDate: event.date));
  }

  void _onSetShowCustomerList(
    SetShowCustomerListEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(showCustomerList: event.show));
  }

  void _onSetFilteredCustomers(
    SetFilteredCustomersEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(filteredCustomers: event.customers));
  }

  void _onAddBillItem(
    AddBillItemEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    final updatedItems = List<DetailedBillItem>.from(state.billItems)
      ..add(event.item);
    emit(state.copyWith(billItems: updatedItems));
  }

  void _onUpdateBillItem(
    UpdateBillItemEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    final updatedItems = List<DetailedBillItem>.from(state.billItems);
    if (event.index >= 0 && event.index < updatedItems.length) {
      updatedItems[event.index] = event.item;
      emit(state.copyWith(billItems: updatedItems));
    }
  }

  void _onRemoveBillItem(
    RemoveBillItemEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    final updatedItems = List<DetailedBillItem>.from(state.billItems);
    if (event.index >= 0 && event.index < updatedItems.length) {
      updatedItems.removeAt(event.index);
      emit(state.copyWith(billItems: updatedItems));
    }
  }

  void _onClearBillItems(
    ClearBillItemsEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(billItems: []));
  }

  void _onSetNotes(SetNotesEvent event, Emitter<CreateInvoiceState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onSetDiscount(
    SetDiscountEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(discount: event.discount));
  }

  void _onSetTax(SetTaxEvent event, Emitter<CreateInvoiceState> emit) {
    emit(state.copyWith(tax: event.tax));
  }

  void _onSetBillNumber(
    SetBillNumberEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(state.copyWith(billNumber: event.billNumber));
  }

  void _onCreateBill(CreateBillEvent event, Emitter<CreateInvoiceState> emit) {
    // This event is typically handled by the BillBloc, not this bloc
    // We just emit the current state unchanged
    emit(state);
  }

  void _onResetCreateInvoice(
    ResetCreateInvoiceEvent event,
    Emitter<CreateInvoiceState> emit,
  ) {
    emit(CreateInvoiceInitialState());
  }

  Future<void> generateBillNumber() async {
    final nextNumber = await BillManagementService.generateNextBillNumber();
    add(SetBillNumberEvent(nextNumber));
  }
}
