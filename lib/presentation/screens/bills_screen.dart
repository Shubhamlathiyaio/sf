import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/bill_bloc.dart';
import 'package:sf/models/bill.dart';
import 'package:sf/models/company.dart';
import 'package:sf/models/customer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/bill_card.dart';
import '../widgets/floating_action_button_extended.dart';
import '../widgets/empty_state_widget.dart';
import 'create_invoice_screen.dart';
import 'edit_invoice_screen.dart';
import 'detailed_bill_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Load bills when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final billBloc = context.read<BillBloc>();
      billBloc.add(const LoadBillsEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<BillBloc, BaseBlocState>(
        listener: (context, state) {
          if (state is BillLoadedState) {
            final previousState = context.read<BillBloc>().state;
            if (previousState is LoadingState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Operation completed successfully'),
                  backgroundColor: AppColors.accent2,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else if (state is SuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Operation successful'),
                backgroundColor: AppColors.accent2,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildStatusTabs(),
                Expanded(child: _buildBillsList()),
              ],
            ),
          );
        },
      ),
      floatingActionButton: CustomFloatingActionButtonExtended(
        onPressed: () => _showCreateBillDialog(),
        icon: PhosphorIcons.plus(),
        label: 'New Bill',
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bills',
                  style: poppins.fs28.w700.textColor(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                gap.h4,
                BlocBuilder<BillBloc, BaseBlocState>(
                  builder: (context, state) {
                    if (state is BillLoadedState) {
                      return Text(
                        '${state.bills.length} total bills',
                        style: poppins.fs14.textColor(
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      );
                    }
                    return Text(
                      'Loading...',
                      style: poppins.fs14.textColor(
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateInvoiceScreen(),
                  ),
                );
              },
              child: Icon(
                PhosphorIcons.plus(),
                size: 20.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          gap.w12,
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Icon(
              PhosphorIcons.funnelSimple(),
              size: 20.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: 'Search bills by customer, number...',
        onChanged: (value) {
          context.read<BillBloc>().add(SearchBillsEvent(value));
        },
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        labelStyle: poppins.fs12.w600,
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text('All'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text('Draft'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text('Sent'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text('Paid'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text('Overdue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList() {
    return BlocBuilder<BillBloc, BaseBlocState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.warning(),
                  size: 48.sp,
                  color: AppColors.error,
                ),
                gap.h16,
                Text(
                  'Error loading bills',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                gap.h8,
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                gap.h24,
                ElevatedButton(
                  onPressed: () {
                    context.read<BillBloc>().add(const LoadBillsEvent());
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is BillLoadedState) {
          if (state.filteredBills.isEmpty) {
            return EmptyStateWidget(
              icon: PhosphorIcons.receipt(),
              title: 'No bills found',
              subtitle: state.searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Create your first bill to get started',
              actionText: 'Create Bill',
              onActionPressed: () => _showCreateBillDialog(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBillsListView(state.filteredBills),
              _buildBillsListView(
                _filterBillsByStatus(state.filteredBills, BillStatus.draft),
              ),
              _buildBillsListView(
                _filterBillsByStatus(state.filteredBills, BillStatus.sent),
              ),
              _buildBillsListView(
                _filterBillsByStatus(state.filteredBills, BillStatus.paid),
              ),
              _buildBillsListView(
                _filterBillsByStatus(state.filteredBills, BillStatus.overdue),
              ),
            ],
          );
        }

        // Handle initial state - load bills
        if (state is BillInitialState) {
          context.read<BillBloc>().add(const LoadBillsEvent());
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBillsListView(List<Bill> bills) {
    if (bills.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.receipt(),
        title: 'No bills found',
        subtitle: 'No bills match the current filter',
        actionText: 'Create Bill',
        onActionPressed: () => _showCreateBillDialog(),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: BillCard(
            bill: bill,
            onTap: () => _showBillDetails(bill),
            onEdit: () => _showEditBillScreen(bill),
            onDelete: () => _showDeleteBillDialog(bill),
          ),
        );
      },
    );
  }

  List<Bill> _filterBillsByStatus(List<Bill> bills, BillStatus status) {
    return bills.where((bill) => bill.status == status).toList();
  }

  void _showCreateBillDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
    );
  }

  void _showBillDetails(Bill bill) {
    // Navigate to detailed bill screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailedBillScreen(
          billNumber: bill.billNumber,
          billDate: bill.billDate,
          dueDate: bill.dueDate,
          customer: Customer.create(
            contactPersonName: "",
            firmName: bill.customerName,
            mobileNumber: bill.customerPhone,
            firmAddress: 'Address not available',
            deliveryAddress: 'Delivery address not available',
            gstNumber: '',
          ),
          company: Company.create(
            city: "",
            pinCode: "",
            state: "",
            stateCode: "24",
            email: "",
            logoPath: "",
            ownerName: "",
            signaturePath: "",
            termsAndConditions: "",
            companyName: 'SHUBHAM FASHION',
            address: 'U 7106 Radhakrishna Textiles Market Ring Road Surat',
            mobileNumber: '98796 71385',
            gstNumber: '24ACYPL1289J1ZY',
            bankName: 'HDFC BANK',
            branchName: 'Nanpura',
            accountNumber: '50500000000000.0',
            ifscCode: 'HDFC0001026',
          ),
          items: bill.items.map((item) => BillItem(
            id: item.id,
            name: item.name,     
            description: item.description,
            quantity: item.quantity,
            totalPrice: item.totalPrice,
            unit: item.unit,
            unitPrice: item.unitPrice,
            // taka: item.quantity.toInt(),
            // hsn: 0, // Default HSN if not available
            // meter: item.quantity.toInt(),
            // rate: item.unitPrice.toInt(),
            // amount: item.quantity * item.unitPrice,
          )).toList(),
        ),
      ),
    );
  }

  void _showEditBillScreen(Bill bill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditInvoiceScreen(bill: bill),
      ),
    );
  }

  void _showDeleteBillDialog(Bill bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              PhosphorIcons.warning(),
              color: AppColors.error,
              size: 24.sp,
            ),
            gap.w12,
            Text(
              'Delete Bill',
              style: poppins.fs18.w600,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this bill?',
              style: poppins.fs14.w400,
            ),
            gap.h8,
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill #${bill.billNumber}',
                    style: poppins.fs14.w600.textColor(AppColors.error),
                  ),
                  Text(
                    'Customer: ${bill.customerName}',
                    style: poppins.fs12.w400,
                  ),
                  Text(
                    'Amount: ₹${bill.totalAmount.toStringAsFixed(2)}',
                    style: poppins.fs12.w400,
                  ),
                ],
              ),
            ),
            gap.h12,
            Text(
              'This action cannot be undone.',
              style: poppins.fs12.w400.textColor(AppColors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: poppins.fs14.w600.textColor(
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<BillBloc>().add(DeleteBillEvent(bill.id));
              Navigator.pop(context);
              
              // Show confirmation message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bill #${bill.billNumber} deleted successfully'),
                  backgroundColor: AppColors.accent2,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      // Implement undo functionality if needed
                      context.read<BillBloc>().add(AddBillEvent(bill));
                    },
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: poppins.fs14.w600.textColor(AppColors.error),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}