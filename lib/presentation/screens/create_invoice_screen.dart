import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../bloc/customer_bloc.dart';
import '../../bloc/company_bloc.dart';
import '../../bloc/bill_bloc.dart';
import '../../bloc/ui_bloc.dart';
import '../../bloc/ui_state.dart';
import '../../bloc/create_invoice_bloc.dart';
import '../../bloc/create_invoice_event.dart';
import '../../bloc/create_invoice_state.dart';
import '../../bloc/base_bloc_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import '../../models/customer.dart';
import '../../models/company.dart';
import '../../models/bill.dart' as CoreBill;
import '../../models/detailed_bill_item.dart';
import '../../models/invoice.dart';
import '../../services/bill_management_service.dart';
import '../../services/invoice_pdf_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'detailed_bill_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _billNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();
  final _customerSearchController = TextEditingController();

  // Customer search
  final bool _showCustomerList = false;

  @override
  void initState() {
    super.initState();
    // Load customers when screen initializes
    context.read<CustomerBloc>().add(const LoadCustomersEvent());
    context.read<CompanyBloc>().add(const LoadDefaultCompanyEvent());

    // Listen to CreateInvoiceBloc state changes for bill number
    _billNumberController.addListener(() {
      context.read<CreateInvoiceBloc>().add(
        SetBillNumberEvent(_billNumberController.text),
      );
    });

    // Listen to CreateInvoiceBloc state changes for notes
    _notesController.addListener(() {
      context.read<CreateInvoiceBloc>().add(
        SetNotesEvent(_notesController.text),
      );
    });

    // Listen to CreateInvoiceBloc state changes for discount
    _discountController.addListener(() {
      context.read<CreateInvoiceBloc>().add(
        SetDiscountEvent(_discountController.text),
      );
    });

    // Listen to CreateInvoiceBloc state changes for tax
    _taxController.addListener(() {
      context.read<CreateInvoiceBloc>().add(SetTaxEvent(_taxController.text));
    });
  }

  @override
  void dispose() {
    _billNumberController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  void _generateBillNumber() async {
    final nextNumber = await BillManagementService.generateNextBillNumber();
    _billNumberController.text = nextNumber;
  }

  void _loadDefaultCompany() {
    context.read<CompanyBloc>().add(const LoadDefaultCompanyEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Create Invoice', style: poppins.fs20.w600),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.filePdf()),
            onPressed: _previewPDF,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CompanyBloc, BaseBlocState>(
            listener: (context, state) {
              if (state is DefaultCompanyLoadedState) {
                context.read<CreateInvoiceBloc>().add(
                  SetDefaultCompanyEvent(state.defaultCompany),
                );
              }
            },
          ),
          BlocListener<BillBloc, BaseBlocState>(
            listener: (context, state) {
              if (state is BillLoadedState) {
                // Bill was successfully added
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bill created successfully'),
                    backgroundColor: AppColors.accent2,
                    duration: Duration(seconds: 2),
                  ),
                );
                // Navigate back to bills screen
                Navigator.of(context).pop();
              } else if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error creating bill: ${state.message}'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          BlocListener<CreateInvoiceBloc, CreateInvoiceState>(
            listener: (context, state) {
              // Update text controllers when state changes
              if (_billNumberController.text != state.billNumber) {
                _billNumberController.text = state.billNumber;
              }
              if (_notesController.text != state.notes) {
                _notesController.text = state.notes;
              }
              if (_discountController.text != state.discount) {
                _discountController.text = state.discount;
              }
              if (_taxController.text != state.tax) {
                _taxController.text = state.tax;
              }
            },
          ),
        ],
        child: BlocBuilder<CreateInvoiceBloc, CreateInvoiceState>(
          builder: (context, createInvoiceState) {
            return SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomerSelector(createInvoiceState),
                      gap.h24,
                      _buildInvoiceDetails(createInvoiceState),
                      gap.h24,
                      _buildItemsSection(createInvoiceState),
                      gap.h24,
                      _buildCalculationSection(createInvoiceState),
                      gap.h24,
                      _buildNotesSection(createInvoiceState),
                      gap.h40,
                      _buildActionButtons(createInvoiceState),
                      gap.h20,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerSelector(CreateInvoiceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Information', style: poppins.fs18.w600.primary),
        gap.h16,
        BlocBuilder<CustomerBloc, BaseBlocState>(
          builder: (context, customerState) {
            if (customerState is CustomerLoadedState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar for customer selection
                  GestureDetector(
                    onTap: () {
                      context.read<CreateInvoiceBloc>().add(
                        const SetShowCustomerListEvent(true),
                      );
                      context.read<CreateInvoiceBloc>().add(
                        SetFilteredCustomersEvent(customerState.customers),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.outline.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.magnifyingGlass(),
                            size: 20.sp,
                            color: AppColors.grey,
                          ),
                          gap.w12,
                          Expanded(
                            child: Text(
                              state.selectedCustomer?.firmName ??
                                  'Search and select customer...',
                              style: state.selectedCustomer != null
                                  ? poppins.fs16.w500
                                  : poppins.fs16.w400.textColor(AppColors.grey),
                            ),
                          ),
                          if (state.selectedCustomer != null)
                            GestureDetector(
                              onTap: () {
                                context.read<CreateInvoiceBloc>().add(
                                  const SetSelectedCustomerEvent(null),
                                );
                                _customerSearchController.clear();
                              },
                              child: Icon(
                                PhosphorIcons.x(),
                                size: 18.sp,
                                color: AppColors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Customer search and list overlay
                  if (state.showCustomerList) ...[
                    gap.h8,
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.outline.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Search input field
                          Padding(
                            padding: EdgeInsets.all(12.r),
                            child: TextField(
                              controller: _customerSearchController,
                              autofocus: true,
                              onChanged: (query) {
                                if (query.isEmpty) {
                                  context.read<CreateInvoiceBloc>().add(
                                    SetFilteredCustomersEvent(
                                      customerState.customers,
                                    ),
                                  );
                                } else {
                                  final filtered = customerState.customers
                                      .where((customer) {
                                        final searchQuery = query.toLowerCase();
                                        return customer.firmName
                                                .toLowerCase()
                                                .contains(searchQuery) ||
                                            customer.mobileNumber.contains(
                                              searchQuery,
                                            ) ||
                                            customer.gstNumber
                                                .toLowerCase()
                                                .contains(searchQuery);
                                      })
                                      .toList();
                                  context.read<CreateInvoiceBloc>().add(
                                    SetFilteredCustomersEvent(filtered),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Type to search customers...',
                                hintStyle: poppins.fs14.textColor(
                                  AppColors.grey,
                                ),
                                prefixIcon: Icon(
                                  PhosphorIcons.magnifyingGlass(),
                                  size: 20.sp,
                                  color: AppColors.grey,
                                ),
                                suffixIcon:
                                    _customerSearchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _customerSearchController.clear();
                                          context.read<CreateInvoiceBloc>().add(
                                            SetFilteredCustomersEvent(
                                              customerState.customers,
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          PhosphorIcons.x(),
                                          size: 18.sp,
                                          color: AppColors.grey,
                                        ),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: AppColors.outline.withOpacity(0.2),
                          ),

                          // Scrollable customer list
                          SizedBox(
                            height: 200.h, // Fixed height for scrolling
                            child: state.filteredCustomers.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(24.r),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          PhosphorIcons.user(),
                                          size: 32.sp,
                                          color: AppColors.grey,
                                        ),
                                        gap.h8,
                                        Text(
                                          'No customers found',
                                          style: poppins.fs14.textColor(
                                            AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount: state.filteredCustomers.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          height: 1,
                                          color: AppColors.outline.withOpacity(
                                            0.1,
                                          ),
                                        ),
                                    itemBuilder: (context, index) {
                                      final customer =
                                          state.filteredCustomers[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.primary
                                              .withOpacity(0.1),
                                          radius: 20.r,
                                          child: Text(
                                            customer.initials,
                                            style: poppins.fs14.w600.primary,
                                          ),
                                        ),
                                        title: Text(
                                          customer.firmName,
                                          style: poppins.fs16.w600,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer.mobileNumber,
                                              style: poppins.fs14.w400,
                                            ),
                                            if (customer.gstNumber.isNotEmpty)
                                              Text(
                                                'GST: ${customer.gstNumber}',
                                                style: poppins.fs12.textColor(
                                                  AppColors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                        onTap: () {
                                          context.read<CreateInvoiceBloc>().add(
                                            SetSelectedCustomerEvent(customer),
                                          );
                                          context.read<CreateInvoiceBloc>().add(
                                            const SetShowCustomerListEvent(
                                              false,
                                            ),
                                          );
                                          _customerSearchController.clear();
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildInvoiceDetails(CreateInvoiceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invoice Details', style: poppins.fs18.w600.primary),
        gap.h16,
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _billNumberController,
                label: 'Bill Number *',
                hint: 'Enter bill number',
                prefixIcon: PhosphorIcons.hash(),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Bill number is required'
                    : null,
              ),
            ),
            gap.w12,
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context, true, state),
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'Bill Date *',
                    hint: 'Select date',
                    prefixIcon: PhosphorIcons.calendar(),
                    controller: TextEditingController()
                      ..text = DateFormat('dd/MM/yyyy').format(state.billDate),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Bill date is required'
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        gap.h16,
        GestureDetector(
          onTap: () => _selectDate(context, false, state),
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Due Date *',
              hint: 'Select due date',
              prefixIcon: PhosphorIcons.calendarCheck(),
              controller: TextEditingController()
                ..text = DateFormat('dd/MM/yyyy').format(state.dueDate),
              validator: (value) => value == null || value.isEmpty
                  ? 'Due date is required'
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(CreateInvoiceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Items', style: poppins.fs18.w600.primary),
            IconButton(
              onPressed: () => _showAddItemDialog(context, state),
              icon: Icon(PhosphorIcons.plusCircle(), color: AppColors.primary),
            ),
          ],
        ),
        gap.h16,
        if (state.billItems.isEmpty)
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12.r),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIcons.receipt(),
                  size: 32.sp,
                  color: AppColors.grey,
                ),
                gap.h8,
                Text(
                  'No items added yet',
                  style: poppins.fs14.textColor(AppColors.grey),
                ),
                gap.h8,
                Text(
                  'Tap + icon to add items',
                  style: poppins.fs12.textColor(AppColors.grey),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12.r),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outline.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Description', style: poppins.fs14.w600),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Qty',
                          style: poppins.fs14.w600,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Rate',
                          style: poppins.fs14.w600,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Amount',
                          style: poppins.fs14.w600,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      SizedBox(width: 40.w), // For delete icon
                    ],
                  ),
                ),
                // Table rows
                ...state.billItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    key: ValueKey(index),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.outline.withOpacity(0.1),
                          width: 1.w,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.description,
                            style: poppins.fs14.w400,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.meter.toStringAsFixed(2),
                            style: poppins.fs14.w400,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.rate.toStringAsFixed(2),
                            style: poppins.fs14.w400,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.amount.toStringAsFixed(2),
                            style: poppins.fs14.w600,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        SizedBox(
                          width: 40.w,
                          child: IconButton(
                            onPressed: () {
                              context.read<CreateInvoiceBloc>().add(
                                RemoveBillItemEvent(index),
                              );
                            },
                            icon: Icon(PhosphorIcons.trash(), size: 16.sp),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCalculationSection(CreateInvoiceState state) {
    final subtotal = state.billItems.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    final discount = double.tryParse(state.discount) ?? 0;
    final tax = double.tryParse(state.tax) ?? 0;
    final total = subtotal - discount + tax;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: poppins.fs14.w400),
              Text('₹${subtotal.toStringAsFixed(2)}', style: poppins.fs14.w400),
            ],
          ),
          gap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount', style: poppins.fs14.w400),
              SizedBox(
                width: 100.w,
                child: CustomTextField(
                  controller: _discountController,
                  label: 'Discount',
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          gap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax', style: poppins.fs14.w400),
              SizedBox(
                width: 100.w,
                child: CustomTextField(
                  controller: _taxController,
                  label: 'Tax',
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Divider(height: 24.h, color: AppColors.outline.withOpacity(0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: poppins.fs16.w600),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: poppins.fs16.w600.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Text(label, style: isTotal ? poppins.fs16.w600 : poppins.fs14.w400),
        const Spacer(),
        Text(
          value,
          style: isTotal
              ? poppins.fs18.w700.textColor(AppColors.accent2)
              : poppins.fs14.w500,
        ),
      ],
    );
  }

  Widget _buildNotesSection(CreateInvoiceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes', style: poppins.fs18.w600.primary),
        gap.h16,
        CustomTextField(
          controller: _notesController,
          label: 'Additional Notes',
          hint: 'Enter any additional notes...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActionButtons(CreateInvoiceState state) {
    return Row(
      children: [
        Expanded(
          child: CustomSecondaryButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Cancel',
          ),
        ),
        gap.w12,
        Expanded(
          child: CustomButton(
            onPressed: () => _saveBill(state),
            text: 'Save Bill',
            icon: PhosphorIcons.floppyDisk(),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isBillDate,
    CreateInvoiceState state,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBillDate ? state.billDate : state.dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.primary, // Calendar text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isBillDate) {
        context.read<CreateInvoiceBloc>().add(SetBillDateEvent(picked));
        // Update due date to be 30 days after bill date
        final newDueDate = picked.add(const Duration(days: 30));
        context.read<CreateInvoiceBloc>().add(SetDueDateEvent(newDueDate));
      } else {
        context.read<CreateInvoiceBloc>().add(SetDueDateEvent(picked));
      }
    }
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    CreateInvoiceState state,
  ) async {
    final newItem = await showModalBottomSheet<DetailedBillItem>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _AddItemDialog(itemsCount: state.billItems.length),
    );

    if (newItem != null) {
      context.read<CreateInvoiceBloc>().add(AddBillItemEvent(newItem));
    }
  }

  List<String> _getDescriptionTemplates() {
    return [
      'Cotton Fabric',
      'Silk Material',
      'Polyester Cloth',
      'Woolen Fabric',
      'Linen Material',
      'Denim Fabric',
      'Chiffon Cloth',
      'Georgette Material',
      'Velvet Fabric',
      'Rayon Cloth',
      'Jute Material',
      'Canvas Fabric',
      'Satin Cloth',
      'Crepe Material',
      'Organza Fabric',
      'Twill Cloth',
    ];
  }

  void _previewPDF() {
    // Get current state from CreateInvoiceBloc
    final state = context.read<CreateInvoiceBloc>().state;

    if (state.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (state.billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Directly generate and preview the PDF instead of navigating to another screen
    _generateAndPreviewPDF(state);
  }

  void _generateAndPreviewPDF(CreateInvoiceState state) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Validate required data before generating PDF
      if (state.selectedCustomer == null) {
        throw Exception('Customer information is missing');
      }

      if (state.defaultCompany == null) {
        throw Exception('Company information is missing');
      }

      if (state.billItems.isEmpty) {
        throw Exception('No items added to the invoice');
      }

      // Create temporary invoice items
      final invoiceItems = <InvoiceItem>[];
      for (int i = 0; i < state.billItems.length; i++) {
        final item = state.billItems[i];
        invoiceItems.add(
          InvoiceItem.create(
            srNo: i + 1,
            description: item.description,
            taka: item.taka.toDouble(),
            meter: item.meter.toDouble(),
            rate: item.rate.toDouble(),
            gstRate: 5.0, // Default GST rate
            chalanNo: (i + 1).toString(),
            hsnCode: item.hsn.toString(),
          ),
        );
      }

      // Create a temporary invoice object for PDF generation
      final invoice = Invoice.create(
        customerId: state.selectedCustomer!.id,
        companyId: state.defaultCompany!.id,
        items: invoiceItems,
        invoiceNumber: state.billNumber,
        invoiceDate: state.billDate,
        discount: double.tryParse(state.discount) ?? 0.0,
        otherDeductions: 0.0,
        freight: double.tryParse(state.tax) ?? 0.0,
        dueDays: state.dueDate.difference(state.billDate).inDays,
        broker: '',
        notes: state.notes,
      );

      // Generate PDF
      final pdfBytes = await InvoicePDFService.generateInvoicePDF(
        invoice: invoice,
        customer: state.selectedCustomer!,
        company: state.defaultCompany!,
      );

      // Preview the PDF directly
      await InvoicePDFService.previewPDF(
        pdfBytes,
        'Invoice_${state.billNumber}',
      );
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error generating PDF: ${e.toString().contains('null') ? 'Missing required data' : e}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _saveBill(CreateInvoiceState state) async {
    if (!_formKey.currentState!.validate()) return;
    if (state.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (state.billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Set loading state through UI Bloc
    context.read<UIBloc>().add(const SetLoadingEvent(true));

    try {
      final subtotal = state.billItems.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );

      final discount = double.tryParse(state.discount) ?? 0;
      final tax = double.tryParse(state.tax) ?? 0;
      final total = subtotal - discount + tax;

      final billItems = state.billItems
          .map(
            (item) => CoreBill.BillItem.create(
              name: item.description,
              description: item.description,
              quantity: item.meter.toDouble(),
              unitPrice: item.rate.toDouble(),
              unit: 'meters',
            ),
          )
          .toList();

      final bill = CoreBill.Bill.create(
        billNumber: state.billNumber,
        customerName: state.selectedCustomer!.firmName,
        customerPhone: state.selectedCustomer!.mobileNumber,
        customerEmail: '',
        billDate: state.billDate,
        dueDate: state.dueDate,
        items: billItems,
        taxAmount: tax,
        discountAmount: discount,
        notes: state.notes,
      );

      context.read<BillBloc>().add(AddBillEvent(bill));

      // Reset the form after successful save
      context.read<CreateInvoiceBloc>().add(const ResetCreateInvoiceEvent());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bill: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        // Set loading state through UI Bloc
        context.read<UIBloc>().add(const SetLoadingEvent(false));
      }
    }
  }
}

// Separate widget to maintain state properly
class _AddItemDialog extends StatefulWidget {
  final int itemsCount;

  const _AddItemDialog({required this.itemsCount});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  // Controllers for the add item dialog
  final _chalanController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _takaController = TextEditingController();
  final _hsnController = TextEditingController();
  final _meterController = TextEditingController();
  final _rateController = TextEditingController();

  // List to store taka values
  final List<double> _takaValues = [];

  @override
  void dispose() {
    _chalanController.dispose();
    _descriptionController.dispose();
    _takaController.dispose();
    _hsnController.dispose();
    _meterController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  // Method to update taka values from the stored list
  void _updateTakaValues() {
    _takaController.text = _takaValues.length.toString();
    final totalMeter = _takaValues.fold(0.0, (sum, value) => sum + value);
    _meterController.text = totalMeter.toStringAsFixed(2);
  }

  // Method to parse taka and meter values from existing fields
  void _parseExistingValues() {
    // Clear existing values
    _takaValues.clear();

    // Parse taka count
    final takaCount = int.tryParse(_takaController.text) ?? 0;

    // Parse meter value
    final meterValue = double.tryParse(_meterController.text) ?? 0.0;

    // If we have taka count > 0, create that many entries with average meter values
    if (takaCount > 0) {
      final averageMeter = meterValue / takaCount;
      for (int i = 0; i < takaCount; i++) {
        _takaValues.add(averageMeter);
      }
    }
  }

  bool _validateInputs() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a fabric name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_takaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter taka value'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_meterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter meter value'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter rate value'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final taka = int.tryParse(_takaController.text);
    if (taka == null || taka <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid taka value (must be a positive number)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final meter = double.tryParse(_meterController.text);
    if (meter == null || meter <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid meter value (must be a positive number)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final rate = double.tryParse(_rateController.text);
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid rate value (must be a positive number)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Text('Add Item', style: poppins.fs18.w600),
                const Spacer(),
                IconButton(
                  icon: Icon(PhosphorIcons.x()),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.outline.withOpacity(0.2)),

          // Content
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // First Row: Sr Number + Chalan Number
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sr Number', style: poppins.fs14.w500),
                              gap.h4,
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 16.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.outline.withOpacity(0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: AppColors.grey.withOpacity(0.05),
                                ),
                                child: Text(
                                  (widget.itemsCount + 1).toString(),
                                  style: poppins.fs14.w400.textColor(
                                    AppColors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        gap.w12,
                        Expanded(
                          child: CustomTextField(
                            controller: _chalanController,
                            label: 'Chalan Number',
                            hint: 'Enter chalan number',
                            keyboardType: TextInputType.number,
                            maxLength: 20, // Limit chalan number length
                          ),
                        ),
                      ],
                    ),
                    gap.h12,

                    // Description (Fabric Name)
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Fabric Name',
                      hint: 'Enter fabric name',
                      keyboardType: TextInputType.text,
                    ),
                    gap.h12,

                    // Second Row: Taka + HSN
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _takaController,
                            label: 'Taka',
                            hint: 'Enter taka value',
                            keyboardType: TextInputType.number,
                            suffixIcon: PhosphorIcons.plus(),
                            onSuffixTap: () {
                              // Show taka input bottom sheet
                              _showTakaInputDialog();
                            },
                          ),
                        ),
                        gap.w12,
                        Expanded(
                          child: CustomTextField(
                            controller: _hsnController,
                            label: 'HSN Code',
                            hint: 'Enter HSN code',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    gap.h12,

                    // Third Row: Meter + Rate
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _meterController,
                            label: 'Meter',
                            hint: 'Enter meter value',
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        gap.w12,
                        Expanded(
                          child: CustomTextField(
                            controller: _rateController,
                            label: 'Rate',
                            hint: 'Enter rate',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    gap.h20,

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                side: BorderSide(
                                  color: AppColors.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: poppins.fs14.w600.textColor(
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        gap.w12,
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_validateInputs()) {
                                  final taka =
                                      int.tryParse(_takaController.text) ?? 0;
                                  final meter =
                                      double.tryParse(_meterController.text) ??
                                      0;
                                  final rate =
                                      double.tryParse(_rateController.text) ??
                                      0;
                                  final amount = meter * rate;

                                  final newItem = DetailedBillItem(
                                    description: _descriptionController.text,
                                    taka: taka,
                                    hsn: int.tryParse(_hsnController.text) ?? 0,
                                    meter: meter.toInt(),
                                    rate: rate.toInt(),
                                    amount: amount,
                                  );

                                  Navigator.pop(context, newItem);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                'Add Item',
                                style: poppins.fs14.w600.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    gap.h20,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTakaInputDialog() {
    // Parse existing values when opening the dialog
    _parseExistingValues();

    // Create a local copy of taka values for the dialog
    final List<Map<String, dynamic>> takaList = [];
    for (int i = 0; i < _takaValues.length; i++) {
      takaList.add({'id': i, 'meter': _takaValues[i]});
    }

    final meterController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20.r),
                    child: Row(
                      children: [
                        Text('Add Taka Values', style: poppins.fs18.w600),
                        const Spacer(),
                        IconButton(
                          icon: Icon(PhosphorIcons.x()),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColors.outline.withOpacity(0.2)),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input field for meter value
                        Text('Enter Meter Value', style: poppins.fs16.w600),
                        gap.h12,
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: meterController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'e.g., 25.50',
                                  hintStyle: poppins.fs14.textColor(
                                    AppColors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: AppColors.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: AppColors.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                            ),
                            gap.w8,
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.plus(),
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                if (meterController.text.trim().isEmpty) {
                                  // Show error message for empty input
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a meter value',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                final meterValue = double.tryParse(
                                  meterController.text.trim(),
                                );
                                if (meterValue == null) {
                                  // Show error message for invalid input
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid meter value',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                if (meterValue <= 0) {
                                  // Show error message for non-positive values
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Meter value must be greater than 0',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                // Add the valid meter value to the list
                                setState(() {
                                  takaList.add({
                                    'id': DateTime.now().millisecondsSinceEpoch,
                                    'meter': meterValue,
                                  });
                                });
                                meterController.clear();

                                // Request focus back to the text field for continuous entry
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    FocusScope.of(context).requestFocus();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        gap.h16,

                        // Display entered taka values
                        if (takaList.isNotEmpty) ...[
                          Text('Taka List:', style: poppins.fs16.w600),
                          gap.h8,
                          Container(
                            height: 200.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.outline.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: ListView.builder(
                              itemCount: takaList.length,
                              itemBuilder: (context, index) {
                                final takaItem = takaList[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Index number
                                      Container(
                                        width: 24.r,
                                        height: 24.r,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: poppins.fs12.w600.white,
                                          ),
                                        ),
                                      ),
                                      gap.w8,
                                      Text(
                                        '${takaItem['meter']}',
                                        style: poppins.fs14.w500,
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            takaList.removeAt(index);
                                          });
                                        },
                                        child: Icon(
                                          PhosphorIcons.trash(),
                                          size: 16.sp,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            height: 200.h,
                            child: Center(
                              child: Text(
                                'No taka values added yet',
                                style: poppins.fs14.textColor(AppColors.grey),
                              ),
                            ),
                          ),
                        ],
                        gap.h16,

                        // Summary
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Taka:', style: poppins.fs14.w600),
                              Text(
                                '${takaList.length}',
                                style: poppins.fs14.w600.primary,
                              ),
                            ],
                          ),
                        ),
                        gap.h8,
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Meter:', style: poppins.fs14.w600),
                              Text(
                                takaList
                                    .fold<double>(
                                      0.0,
                                      (sum, item) =>
                                          sum + (item['meter'] as double),
                                    )
                                    .toStringAsFixed(2),
                                style: poppins.fs14.w600.primary,
                              ),
                            ],
                          ),
                        ),
                        gap.h16,

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48.h,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    side: BorderSide(
                                      color: AppColors.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: poppins.fs14.w600.textColor(
                                      Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            gap.w12,
                            Expanded(
                              child: SizedBox(
                                height: 48.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Update the taka values list
                                    _takaValues.clear();
                                    for (final item in takaList) {
                                      _takaValues.add(item['meter'] as double);
                                    }

                                    // Update the taka and meter fields
                                    _updateTakaValues();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Apply',
                                    style: poppins.fs14.w600.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
