import '../models/customer.dart';
import '../models/company.dart';
import '../models/bill.dart' as core_bill;
import '../models/detailed_bill_item.dart';
import 'base_bloc_state.dart';

class CreateInvoiceState extends BaseBlocState {
  final Customer? selectedCustomer;
  final Company? defaultCompany;
  final DateTime billDate;
  final DateTime dueDate;
  final List<DetailedBillItem> billItems;
  final List<Customer> filteredCustomers;
  final bool showCustomerList;
  final String notes;
  final String discount;
  final String tax;
  final String billNumber;

  CreateInvoiceState({
    this.selectedCustomer,
    this.defaultCompany,
    DateTime? billDate,
    DateTime? dueDate,
    List<DetailedBillItem>? billItems,
    List<Customer>? filteredCustomers,
    this.showCustomerList = false,
    this.notes = '',
    this.discount = '',
    this.tax = '',
    this.billNumber = '',
  }) : billDate = billDate ?? DateTime.now(),
       dueDate = dueDate ?? DateTime.now().add(const Duration(days: 30)),
       billItems = billItems ?? [],
       filteredCustomers = filteredCustomers ?? [];

  @override
  List<Object?> get props => [
    selectedCustomer,
    defaultCompany,
    billDate,
    dueDate,
    billItems,
    filteredCustomers,
    showCustomerList,
    notes,
    discount,
    tax,
    billNumber,
  ];

  CreateInvoiceState copyWith({
    Customer? selectedCustomer,
    Company? defaultCompany,
    DateTime? billDate,
    DateTime? dueDate,
    List<DetailedBillItem>? billItems,
    List<Customer>? filteredCustomers,
    bool? showCustomerList,
    String? notes,
    String? discount,
    String? tax,
    String? billNumber,
  }) {
    return CreateInvoiceState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      defaultCompany: defaultCompany ?? this.defaultCompany,
      billDate: billDate ?? this.billDate,
      dueDate: dueDate ?? this.dueDate,
      billItems: billItems ?? this.billItems,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      showCustomerList: showCustomerList ?? this.showCustomerList,
      notes: notes ?? this.notes,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      billNumber: billNumber ?? this.billNumber,
    );
  }
}

class CreateInvoiceInitialState extends CreateInvoiceState {
  CreateInvoiceInitialState()
    : super(
        billDate: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
      );
}
