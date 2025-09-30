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

class EditInvoiceScreen extends StatefulWidget {
  final CoreBill.Bill bill;

  const EditInvoiceScreen({
    super.key,
    required this.bill,
  });

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _billNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();
  final _customerSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Initialize form with existing bill data
    _initializeFormData();
    
    // Load necessary data
    context.read<CustomerBloc>().add(const LoadCustomersEvent());
    context.read<CompanyBloc>().add(const LoadDefaultCompanyEvent());
  }

  void _initializeFormData() {
    final createInvoiceBloc = context.read<CreateInvoiceBloc>();
    
    // Set form data from existing bill
    _billNumberController.text = widget.bill.billNumber;
    _notesController.text = widget.bill.notes;
    _discountController.text = widget.bill.discountAmount.toString();
    _taxController.text = widget.bill.taxAmount.toString();
    
    // Convert bill items to DetailedBillItem
    final billItems = widget.bill.items.map((item) => DetailedBillItem(
      description: item.name,
      taka: item.quantity.toInt(),
      hsn: 0, // Default HSN if not available
      meter: item.quantity.toInt(),
      rate: item.unitPrice.toInt(),
      amount: item.quantity * item.unitPrice,
    )).toList();
    
    // Set initial state
    createInvoiceBloc.add(SetBillNumberEvent(widget.bill.billNumber));
    createInvoiceBloc.add(SetBillDateEvent(widget.bill.billDate));
    createInvoiceBloc.add(SetDueDateEvent(widget.bill.dueDate));
    createInvoiceBloc.add(SetNotesEvent(widget.bill.notes));
    createInvoiceBloc.add(SetDiscountEvent(widget.bill.discountAmount.toString()));
    createInvoiceBloc.add(SetTaxEvent(widget.bill.taxAmount.toString()));
    
    // Add bill items
    for (final item in billItems) {
      createInvoiceBloc.add(AddBillItemEvent(item));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Edit Invoice', style: poppins.fs20.w600),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bill updated successfully'),
                    backgroundColor: AppColors.accent2,
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              } else if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating bill: ${state.message}'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
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
                  // Display current customer
                  Container(
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
                          PhosphorIcons.user(),
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                        gap.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.bill.customerName,
                                style: poppins.fs16.w600,
                              ),
                              Text(
                                widget.bill.customerPhone,
                                style: poppins.fs14.w400.textColor(AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      SizedBox(width: 80.w), // For edit and delete icons
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
                          width: 80.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showEditItemDialog(context, index, item);
                                },
                                icon: Icon(PhosphorIcons.pencilSimple(), size: 16.sp),
                                padding: EdgeInsets.zero,
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<CreateInvoiceBloc>().add(
                                    RemoveBillItemEvent(index),
                                  );
                                },
                                icon: Icon(PhosphorIcons.trash(), size: 16.sp),
                                padding: EdgeInsets.zero,
                              ),
                            ],
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
    final subtotal = state.billItems.fold(
      0.0,
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
            onPressed: () => _updateBill(state),
            text: 'Update Bill',
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
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

  Future<void> _showEditItemDialog(
    BuildContext context,
    int index,
    DetailedBillItem item,
  ) async {
    final updatedItem = await showModalBottomSheet<DetailedBillItem>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _EditItemDialog(item: item, index: index),
    );

    if (updatedItem != null) {
      context.read<CreateInvoiceBloc>().add(UpdateBillItemEvent(index, updatedItem));
    }
  }

  void _previewPDF() {
    final state = context.read<CreateInvoiceBloc>().state;
    if (state.billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    _generateAndPreviewPDF(state);
  }

  void _generateAndPreviewPDF(CreateInvoiceState state) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

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
            gstRate: 5.0,
            chalanNo: (i + 1).toString(),
            hsnCode: item.hsn.toString(),
          ),
        );
      }

      // Create a temporary invoice object for PDF generation
      final invoice = Invoice.create(
        customerId: 'temp_customer',
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
        customer: Customer.create(
          contactPersonName: "",
          firmName: widget.bill.customerName,
          mobileNumber: widget.bill.customerPhone,
          firmAddress: 'Address',
          deliveryAddress: 'Delivery Address',
          gstNumber: '',
        ),
        company: state.defaultCompany!,
      );

      await InvoicePDFService.previewPDF(
        pdfBytes,
        'Invoice_${state.billNumber}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _updateBill(CreateInvoiceState state) async {
    if (!_formKey.currentState!.validate()) return;

    if (state.billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<UIBloc>().add(const SetLoadingEvent(true));
    try {
      final subtotal = state.billItems.fold(
        0.0,
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

      final updatedBill = widget.bill.copyWith(
        billNumber: state.billNumber,
        billDate: state.billDate,
        dueDate: state.dueDate,
        items: billItems,
        taxAmount: tax,
        discountAmount: discount,
        notes: state.notes,
        totalAmount: total,
      );

      context.read<BillBloc>().add(UpdateBillEvent(updatedBill));
      
      // Reset the form after successful update
      context.read<CreateInvoiceBloc>().add(const ResetCreateInvoiceEvent());
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating bill: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        context.read<UIBloc>().add(const SetLoadingEvent(false));
      }
    }
  }
}

// Edit Item Dialog Widget
class _EditItemDialog extends StatefulWidget {
  final DetailedBillItem item;
  final int index;

  const _EditItemDialog({
    required this.item,
    required this.index,
  });

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  final _descriptionController = TextEditingController();
  final _takaController = TextEditingController();
  final _hsnController = TextEditingController();
  final _meterController = TextEditingController();
  final _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing item data
    _descriptionController.text = widget.item.description;
    _takaController.text = widget.item.taka.toString();
    _hsnController.text = widget.item.hsn.toString();
    _meterController.text = widget.item.meter.toString();
    _rateController.text = widget.item.rate.toString();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _takaController.dispose();
    _hsnController.dispose();
    _meterController.dispose();
    _rateController.dispose();
    super.dispose();
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
                Text('Edit Item', style: poppins.fs18.w600),
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
                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Fabric Name',
                      hint: 'Enter fabric name',
                      keyboardType: TextInputType.text,
                    ),
                    gap.h12,
                    // Taka and HSN
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _takaController,
                            label: 'Taka',
                            hint: 'Enter taka value',
                            keyboardType: TextInputType.number,
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
                    // Meter and Rate
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
                                  final updatedItem = DetailedBillItem(
                                    description: _descriptionController.text,
                                    taka: int.tryParse(_takaController.text) ?? 0,
                                    hsn: int.tryParse(_hsnController.text) ?? 0,
                                    meter: int.tryParse(_meterController.text) ?? 0,
                                    rate: int.tryParse(_rateController.text) ?? 0,
                                    amount: (double.tryParse(_meterController.text) ?? 0) *
                                        (double.tryParse(_rateController.text) ?? 0),
                                  );
                                  Navigator.pop(context, updatedItem);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                'Update Item',
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
          content: Text('Please enter a valid taka value'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final meter = double.tryParse(_meterController.text);
    if (meter == null || meter <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid meter value'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final rate = double.tryParse(_rateController.text);
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid rate value'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }
}

// Add Item Dialog (reused from original create invoice screen)
class _AddItemDialog extends StatefulWidget {
  final int itemsCount;

  const _AddItemDialog({required this.itemsCount});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _chalanController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _takaController = TextEditingController();
  final _hsnController = TextEditingController();
  final _meterController = TextEditingController();
  final _rateController = TextEditingController();

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
                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Fabric Name',
                      hint: 'Enter fabric name',
                      keyboardType: TextInputType.text,
                    ),
                    gap.h12,
                    // Taka and HSN
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _takaController,
                            label: 'Taka',
                            hint: 'Enter taka value',
                            keyboardType: TextInputType.number,
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
                    // Meter and Rate
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
                                  final newItem = DetailedBillItem(
                                    description: _descriptionController.text,
                                    taka: int.tryParse(_takaController.text) ?? 0,
                                    hsn: int.tryParse(_hsnController.text) ?? 0,
                                    meter: int.tryParse(_meterController.text) ?? 0,
                                    rate: int.tryParse(_rateController.text) ?? 0,
                                    amount: (double.tryParse(_meterController.text) ?? 0) *
                                        (double.tryParse(_rateController.text) ?? 0),
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

    return true;
  }
}