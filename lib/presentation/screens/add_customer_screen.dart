import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/customer_bloc.dart';
import 'package:sf/bloc/ui_bloc.dart';
import 'package:sf/bloc/ui_state.dart';
import 'package:sf/models/customer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer; // For editing existing customer

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firmNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _mobileController = TextEditingController();
  final _officeAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  bool _sameAsOfficeAddress = true;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _populateFields(widget.customer!);
    }
  }

  void _populateFields(Customer customer) {
    _firmNameController.text = customer.firmName;
    _gstController.text = customer.gstNumber;
    _mobileController.text = customer.mobileNumber;
    _officeAddressController.text = customer.firmAddress;
    _deliveryAddressController.text = customer.deliveryAddress;
    _sameAsOfficeAddress = customer.firmAddress == customer.deliveryAddress;
  }

  @override
  void dispose() {
    _firmNameController.dispose();
    _gstController.dispose();
    _mobileController.dispose();
    _officeAddressController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  String? _validateGST(String? value) {
    if (value == null || value.isEmpty) return null;

    // GST format: 15 characters - 2 state code + 10 PAN + 1 entity code + 1 Z + 1 check digit
    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );

    if (!gstRegex.hasMatch(value)) {
      return 'Invalid GST format (e.g., 24AAAAA0000A1Z5)';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }

    // Remove any non-digit characters for validation
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    // Set loading state through UI Bloc
    context.read<UIBloc>().add(const SetLoadingEvent(true));

    try {
      final customer = Customer.create(
        firmName: _firmNameController.text.trim(),
        contactPersonName: '', // No longer needed
        mobileNumber: _mobileController.text.trim(),
        email: '', // No longer needed
        firmAddress: _officeAddressController.text.trim(),
        deliveryAddress: _sameAsOfficeAddress
            ? _officeAddressController.text.trim()
            : _deliveryAddressController.text.trim(),
        gstNumber: _gstController.text.trim(),
        city: 'Surat', // Default city
        state: 'Gujarat', // Default state
        stateCode: '24', // Gujarat state code
        pinCode: '395001', // Default pin code
        notes: '', // No longer needed
      );

      if (widget.customer != null) {
        // Update existing customer
        final updatedCustomer = customer.copyWith(
          id: widget.customer!.id,
          createdAt: widget.customer!.createdAt,
        );
        context.read<CustomerBloc>().add(UpdateCustomerEvent(updatedCustomer));
      } else {
        // Create new customer
        context.read<CustomerBloc>().add(CreateCustomerEvent(customer));
      }

      // Don't pop the screen here - let the BlocListener handle it
      // The screen will be popped when we receive a CustomerLoadedState
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        // Reset loading state
        context.read<UIBloc>().add(const SetLoadingEvent(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.customer != null ? 'Edit Customer' : 'Add Customer',
          style: poppins.fs20.w600,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.customer != null)
            IconButton(
              icon: Icon(PhosphorIcons.trash(), color: AppColors.error),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CustomerBloc, BaseBlocState>(
            listener: (context, state) {
              if (state is ErrorState) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  // Reset loading state
                  context.read<UIBloc>().add(const SetLoadingEvent(false));
                }
              } else if (state is CustomerLoadedState) {
                // Customer was successfully added/updated
                // We can close the screen now
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.customer != null
                            ? 'Customer updated successfully'
                            : 'Customer added successfully',
                      ),
                      backgroundColor: AppColors.accent2,
                    ),
                  );
                }
              }
            },
          ),
          BlocListener<UIBloc, BaseBlocState>(
            listener: (context, state) {
              // Handle UI state changes like messages
              if (state is UIMessageState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: state.type == MessageType.error
                        ? AppColors.error
                        : AppColors.accent2,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<UIBloc, BaseBlocState>(
          builder: (context, uiState) {
            final isLoading = uiState is UILoadingState && uiState.isLoading;

            return SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Customer Information'),
                      gap.h16,
                      _buildFirmNameField(),
                      gap.h16,
                      _buildMobileField(),
                      gap.h16,
                      _buildGSTField(),
                      gap.h24,

                      _buildSectionHeader('Address Information'),
                      gap.h16,
                      _buildOfficeAddressField(),
                      gap.h16,
                      _buildSameAddressCheckbox(),
                      if (!_sameAsOfficeAddress) ...[
                        gap.h16,
                        _buildDeliveryAddressField(),
                      ],
                      gap.h40,

                      _buildSaveButton(isLoading),
                      gap.h12,
                      _buildSaveCustomerForChalanButton(isLoading),
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

  Widget _buildSectionHeader(String title) {
    return Text(title, style: poppins.fs18.w600.primary);
  }

  Widget _buildFirmNameField() {
    return CustomTextField(
      controller: _firmNameController,
      label: 'Firm Name *',
      hint: 'Enter firm/company name',
      prefixIcon: PhosphorIcons.buildings(),
      validator: (value) => _validateRequired(value, 'Firm name'),
    );
  }

  Widget _buildMobileField() {
    return CustomTextField(
      controller: _mobileController,
      label: 'Mobile Number *',
      hint: '10 digit number',
      prefixIcon: PhosphorIcons.phone(),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      validator: _validateMobile,
    );
  }

  Widget _buildGSTField() {
    return CustomTextField(
      controller: _gstController,
      label: 'GST Number',
      hint: 'Enter GST number',
      prefixIcon: PhosphorIcons.receipt(),
      textCapitalization: TextCapitalization.characters,
      validator: _validateGST,
    );
  }

  Widget _buildOfficeAddressField() {
    return CustomTextField(
      controller: _officeAddressController,
      label: 'Office Address *',
      hint: 'Enter office address',
      prefixIcon: PhosphorIcons.mapPin(),
      maxLines: 3,
      validator: (value) => _validateRequired(value, 'Office address'),
    );
  }

  Widget _buildSameAddressCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _sameAsOfficeAddress,
          onChanged: (value) {
            setState(() {
              _sameAsOfficeAddress = value ?? true;
              if (_sameAsOfficeAddress) {
                _deliveryAddressController.text = _officeAddressController.text;
              }
            });
          },
          activeColor: AppColors.primary,
        ),
        gap.w8,
        Expanded(
          child: Text(
            'Delivery address same as office address',
            style: poppins.fs14.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressField() {
    return CustomTextField(
      controller: _deliveryAddressController,
      label: 'Delivery Address',
      hint: 'Enter delivery address',
      prefixIcon: PhosphorIcons.truck(),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return CustomButton(
      onPressed: isLoading ? null : _saveCustomer,
      text: isLoading
          ? 'Saving...'
          : (widget.customer != null ? 'Update Customer' : 'Save Customer'),
      icon: isLoading
          ? null
          : (widget.customer != null
                ? PhosphorIcons.check()
                : PhosphorIcons.plus()),
      isLoading: isLoading,
    );
  }

  Widget _buildSaveCustomerForChalanButton(bool isLoading) {
    if (widget.customer != null) {
      // Don't show this button when editing existing customer
      return const SizedBox.shrink();
    }

    return CustomSecondaryButton(
      onPressed: isLoading ? null : _saveCustomerAndCreateChalan,
      text: '+ Save Customer & Create Chalan',
      icon: PhosphorIcons.receipt(),
    );
  }

  void _saveCustomerAndCreateChalan() async {
    if (!_formKey.currentState!.validate()) return;

    // Set loading state through UI Bloc
    context.read<UIBloc>().add(const SetLoadingEvent(true));

    try {
      final customer = Customer.create(
        firmName: _firmNameController.text.trim(),
        contactPersonName: '', // No longer needed
        mobileNumber: _mobileController.text.trim(),
        email: '', // No longer needed
        firmAddress: _officeAddressController.text.trim(),
        deliveryAddress: _sameAsOfficeAddress
            ? _officeAddressController.text.trim()
            : _deliveryAddressController.text.trim(),
        gstNumber: _gstController.text.trim(),
        city: 'Surat', // Default city
        state: 'Gujarat', // Default state
        stateCode: '24', // Gujarat state code
        pinCode: '395001', // Default pin code
        notes: '', // No longer needed
      );

      // Create new customer
      context.read<CustomerBloc>().add(CreateCustomerEvent(customer));

      // Don't pop the screen here - let the BlocListener handle it
      // The screen will be popped when we receive a CustomerLoadedState
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        // Reset loading state
        context.read<UIBloc>().add(const SetLoadingEvent(false));
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Customer', style: poppins.fs18.w600),
        content: Text(
          'Are you sure you want to delete this customer? This action cannot be undone.',
          style: poppins.fs14.w400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: poppins.fs14.w500),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomerBloc>().add(
                DeleteCustomerEvent(widget.customer!.id),
              );
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: poppins.fs14.w500.error),
          ),
        ],
      ),
    );
  }
}
