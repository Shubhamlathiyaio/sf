import 'package:equatable/equatable.dart';

import '../models/customer.dart';
import '../models/company.dart';
import '../models/bill.dart' as core_bill;
import '../models/detailed_bill_item.dart';
import 'base_bloc_event.dart';

abstract class CreateInvoiceEvent extends Equatable {
  const CreateInvoiceEvent();

  @override
  List<Object?> get props => [];
}

class SetSelectedCustomerEvent extends CreateInvoiceEvent {
  final Customer? customer;

  const SetSelectedCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class SetDefaultCompanyEvent extends CreateInvoiceEvent {
  final Company? company;

  const SetDefaultCompanyEvent(this.company);

  @override
  List<Object?> get props => [company];
}

class SetBillDateEvent extends CreateInvoiceEvent {
  final DateTime date;

  const SetBillDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SetDueDateEvent extends CreateInvoiceEvent {
  final DateTime date;

  const SetDueDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SetShowCustomerListEvent extends CreateInvoiceEvent {
  final bool show;

  const SetShowCustomerListEvent(this.show);

  @override
  List<Object?> get props => [show];
}

class SetFilteredCustomersEvent extends CreateInvoiceEvent {
  final List<Customer> customers;

  const SetFilteredCustomersEvent(this.customers);

  @override
  List<Object?> get props => [customers];
}

class AddBillItemEvent extends CreateInvoiceEvent {
  final DetailedBillItem item;

  const AddBillItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateBillItemEvent extends CreateInvoiceEvent {
  final int index;
  final DetailedBillItem item;

  const UpdateBillItemEvent(this.index, this.item);

  @override
  List<Object?> get props => [index, item];
}

class RemoveBillItemEvent extends CreateInvoiceEvent {
  final int index;

  const RemoveBillItemEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ClearBillItemsEvent extends CreateInvoiceEvent {
  const ClearBillItemsEvent();

  @override
  List<Object?> get props => [];
}

class SetNotesEvent extends CreateInvoiceEvent {
  final String notes;

  const SetNotesEvent(this.notes);

  @override
  List<Object?> get props => [notes];
}

class SetDiscountEvent extends CreateInvoiceEvent {
  final String discount;

  const SetDiscountEvent(this.discount);

  @override
  List<Object?> get props => [discount];
}

class SetTaxEvent extends CreateInvoiceEvent {
  final String tax;

  const SetTaxEvent(this.tax);

  @override
  List<Object?> get props => [tax];
}

class SetBillNumberEvent extends CreateInvoiceEvent {
  final String billNumber;

  const SetBillNumberEvent(this.billNumber);

  @override
  List<Object?> get props => [billNumber];
}

class CreateBillEvent extends CreateInvoiceEvent {
  final core_bill.Bill bill;

  const CreateBillEvent(this.bill);

  @override
  List<Object?> get props => [bill];
}

class ResetCreateInvoiceEvent extends CreateInvoiceEvent {
  const ResetCreateInvoiceEvent();

  @override
  List<Object?> get props => [];
}
