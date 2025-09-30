import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/company_bloc.dart';
import 'package:sf/bloc/ui_bloc.dart';
import 'package:sf/bloc/ui_state.dart';
import 'package:sf/models/company.dart';
import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CompanyConfigScreen extends StatefulWidget {
  final Company? company; // For editing existing company

  const CompanyConfigScreen({super.key, this.company});

  @override
  State<CompanyConfigScreen> createState() => _CompanyConfigScreenState();
}

class _CompanyConfigScreenState extends State<CompanyConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();
  final _termsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _populateFields(widget.company!);
    } else {
      // Set default terms and conditions
      _termsController.text = Company.defaultTermsAndConditions;
      // Set default location
      _cityController.text = 'Surat';
      _stateController.text = 'Gujarat';
      _pinCodeController.text = '395001';
    }
  }

  void _populateFields(Company company) {
    _companyNameController.text = company.companyName;
    _gstController.text = company.gstNumber;
    _mobileController.text = company.mobileNumber;
    _emailController.text = company.email;
    _addressController.text = company.address;
    _cityController.text = company.city;
    _stateController.text = company.state;
    _pinCodeController.text = company.pinCode;
    _ownerNameController.text = company.ownerName;
    _bankNameController.text = company.bankName;
    _accountNumberController.text = company.accountNumber;
    _ifscController.text = company.ifscCode;
    _branchController.text = company.branchName;
    _termsController.text = company.termsAndConditions;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _gstController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _ownerNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateGST(String? value) {
    if (value == null || value.isEmpty) return 'GST number is required';

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

    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }

  String _getStateCode(String state) {
    final stateCodes = {
      'Gujarat': '24',
      'Maharashtra': '27',
      'Karnataka': '29',
      'Tamil Nadu': '33',
      'Rajasthan': '08',
      'Uttar Pradesh': '09',
      'West Bengal': '19',
      'Haryana': '06',
      'Punjab': '03',
      'Delhi': '07',
    };

    return stateCodes[state] ?? '24'; // Default to Gujarat
  }

  void _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    // Set loading state through UI Bloc
    context.read<UIBloc>().add(const SetLoadingEvent(true));

    try {
      final company = Company.create(
        companyName: _companyNameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        stateCode: _getStateCode(_stateController.text.trim()),
        pinCode: _pinCodeController.text.trim(),
        gstNumber: _gstController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        branchName: _branchController.text.trim(),
        termsAndConditions: _termsController.text.trim(),
      );

      if (widget.company != null) {
        // Update existing company
        final updatedCompany = company.copyWith(
          id: widget.company!.id,
          createdAt: widget.company!.createdAt,
        );
        context.read<CompanyBloc>().add(UpdateCompanyEvent(updatedCompany));
      } else {
        // Create new company
        context.read<CompanyBloc>().add(CreateCompanyEvent(company));
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.company != null
                  ? 'Company updated successfully'
                  : 'Company configuration saved successfully',
            ),
            backgroundColor: AppColors.accent2,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.company != null ? 'Edit Company' : 'Company Configuration',
          style: poppins.fs20.w600,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CompanyBloc, BaseBlocState>(
            listener: (context, state) {
              if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
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
                      _buildSectionHeader('Company Information'),
                      gap.h16,
                      _buildCompanyNameField(),
                      gap.h16,
                      _buildOwnerNameField(),
                      gap.h16,
                      _buildMobileField(),
                      gap.h16,
                      _buildGSTField(),
                      gap.h16,
                      _buildEmailField(),
                      gap.h24,

                      _buildSectionHeader('Address Information'),
                      gap.h16,
                      _buildAddressField(),
                      gap.h16,
                      Row(
                        children: [
                          Expanded(child: _buildCityField()),
                          gap.w12,
                          Expanded(child: _buildStateField()),
                          gap.w12,
                          SizedBox(width: 100.w, child: _buildPinCodeField()),
                        ],
                      ),
                      gap.h24,

                      _buildSectionHeader('Banking Information (Optional)'),
                      gap.h16,
                      _buildBankNameField(),
                      gap.h16,
                      _buildAccountNumberField(),
                      gap.h16,
                      Row(
                        children: [
                          Expanded(child: _buildIFSCField()),
                          gap.w12,
                          Expanded(child: _buildBranchField()),
                        ],
                      ),
                      gap.h24,

                      _buildSectionHeader('Terms & Conditions'),
                      gap.h16,
                      _buildTermsField(),
                      gap.h40,

                      _buildSaveButton(isLoading),
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

  Widget _buildCompanyNameField() {
    return CustomTextField(
      controller: _companyNameController,
      label: 'Company Name *',
      hint: 'Enter company name',
      prefixIcon: PhosphorIcons.buildings(),
      validator: (value) => _validateRequired(value, 'Company name'),
    );
  }

  Widget _buildOwnerNameField() {
    return CustomTextField(
      controller: _ownerNameController,
      label: 'Owner Name',
      hint: 'Enter owner name',
      prefixIcon: PhosphorIcons.user(),
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
      label: 'GST Number *',
      hint: 'Enter GST number',
      prefixIcon: PhosphorIcons.receipt(),
      textCapitalization: TextCapitalization.characters,
      validator: _validateGST,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      label: 'Email',
      hint: 'Enter email address',
      prefixIcon: PhosphorIcons.envelope(),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildAddressField() {
    return CustomTextField(
      controller: _addressController,
      label: 'Address *',
      hint: 'Enter company address',
      prefixIcon: PhosphorIcons.mapPin(),
      maxLines: 3,
      validator: (value) => _validateRequired(value, 'Address'),
    );
  }

  Widget _buildCityField() {
    return CustomTextField(
      controller: _cityController,
      label: 'City *',
      hint: 'City',
      validator: (value) => _validateRequired(value, 'City'),
    );
  }

  Widget _buildStateField() {
    return CustomTextField(
      controller: _stateController,
      label: 'State *',
      hint: 'State',
      validator: (value) => _validateRequired(value, 'State'),
    );
  }

  Widget _buildPinCodeField() {
    return CustomTextField(
      controller: _pinCodeController,
      label: 'Pin Code *',
      hint: 'Pin Code',
      keyboardType: TextInputType.number,
      validator: (value) => _validateRequired(value, 'Pin Code'),
    );
  }

  Widget _buildBankNameField() {
    return CustomTextField(
      controller: _bankNameController,
      label: 'Bank Name',
      hint: 'Enter bank name',
      prefixIcon: PhosphorIcons.bank(),
    );
  }

  Widget _buildAccountNumberField() {
    return CustomTextField(
      controller: _accountNumberController,
      label: 'Account Number',
      hint: 'Enter account number',
      prefixIcon: PhosphorIcons.creditCard(),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildIFSCField() {
    return CustomTextField(
      controller: _ifscController,
      label: 'IFSC Code',
      hint: 'Enter IFSC code',
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildBranchField() {
    return CustomTextField(
      controller: _branchController,
      label: 'Branch',
      hint: 'Enter branch name',
    );
  }

  Widget _buildTermsField() {
    return CustomTextField(
      controller: _termsController,
      label: 'Terms & Conditions',
      hint: 'Enter terms and conditions',
      prefixIcon: PhosphorIcons.fileText(),
      maxLines: 6,
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return CustomButton(
      onPressed: isLoading ? null : _saveCompany,
      text: isLoading
          ? 'Saving...'
          : (widget.company != null ? 'Update Company' : 'Save Configuration'),
      icon: isLoading
          ? null
          : (widget.company != null
                ? PhosphorIcons.check()
                : PhosphorIcons.floppyDisk()),
      isLoading: isLoading,
    );
  }
}
