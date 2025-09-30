import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/company_bloc.dart';
import 'package:sf/bloc/customer_bloc.dart';
import 'package:sf/bloc/invoice_bloc.dart';
import 'package:sf/core/configs/edge.dart';
import 'package:sf/models/company.dart';
import 'package:sf/models/customer.dart';
import 'package:sf/models/invoice.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/enhanced_app_localizations.dart';
import '../../core/configs/app_typography.dart';
import '../widgets/invoice_card.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/floating_action_button_extended.dart';
import '../widgets/empty_state_widget.dart';
import 'create_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Customer? _selectedCustomer;
  Company? _selectedCompany;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load the first available customer and company for invoices
    final customerState = context.read<CustomerBloc>().state;
    if (customerState is CustomerLoadedState &&
        customerState.customers.isNotEmpty) {
      _selectedCustomer = customerState.customers.first;
    }

    final companyState = context.read<CompanyBloc>().state;
    if (companyState is CompanyLoadedState &&
        companyState.companies.isNotEmpty) {
      _selectedCompany = companyState.companies.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerBloc, BaseBlocState>(
          listener: (context, state) {
            if (state is CustomerLoadedState && state.customers.isNotEmpty) {
              if (mounted) {
                setState(() {
                  _selectedCustomer = state.customers.first;
                });
              }
            }
          },
        ),
        BlocListener<CompanyBloc, BaseBlocState>(
          listener: (context, state) {
            if (state is CompanyLoadedState && state.companies.isNotEmpty) {
              if (mounted) {
                setState(() {
                  _selectedCompany = state.companies.first;
                });
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(localizations),
              _buildSearchBar(localizations),
              _buildStatusTabs(localizations),
              Expanded(child: _buildInvoicesList()),
            ],
          ),
        ),
        floatingActionButton: CustomFloatingActionButtonExtended(
          onPressed: () => _showCreateInvoiceDialog(),
          icon: PhosphorIcons.plus(),
          label: localizations?.create ?? 'Create Invoice',
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? localizations) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.invoices ?? 'Invoices',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                BlocBuilder<InvoiceBloc, BaseBlocState>(
                  builder: (context, state) {
                    if (state is InvoiceLoadedState) {
                      return Text(
                        '${state.invoices.length} total invoices',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      );
                    }
                    return Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildSearchBar(AppLocalizations? localizations) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: 'Search invoices by number, customer...',
        onChanged: (value) {
          context.read<InvoiceBloc>().add(SearchInvoicesEvent(value));
        },
      ),
    );
  }

  Widget _buildStatusTabs(AppLocalizations? localizations) {
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
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.7),
        labelStyle: poppins.fs12.w600,
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Padding(
            padding: edge.h16,
            child: Tab(text: 'All'),
          ),
          Padding(
            padding: edge.h16,
            child: Tab(text: localizations?.draft ?? 'Draft'),
          ),
          Padding(
            padding: edge.h16,
            child: Tab(text: localizations?.sent ?? 'Sent'),
          ),
          Padding(
            padding: edge.h16,
            child: Tab(text: localizations?.paid ?? 'Paid'),
          ),
          Padding(
            padding: edge.h16,
            child: Tab(text: localizations?.overdue ?? 'Overdue'),
          ),
          Padding(
            padding: edge.h16,
            child: Tab(text: localizations?.partiallyPaid ?? 'Partial'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    return BlocBuilder<InvoiceBloc, BaseBlocState>(
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
                SizedBox(height: 16.h),
                Text(
                  'Error loading invoices',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<InvoiceBloc>().add(const LoadInvoicesEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is InvoiceLoadedState) {
          if (state.filteredInvoices.isEmpty) {
            return EmptyStateWidget(
              icon: PhosphorIcons.receipt(),
              title: 'No invoices found',
              subtitle: state.searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Create your first invoice to get started',
              actionText: 'Create Invoice',
              onActionPressed: () => _showCreateInvoiceDialog(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInvoicesListView(state.filteredInvoices),
              _buildInvoicesListView(
                _filterInvoicesByStatus(
                  state.filteredInvoices,
                  InvoiceStatus.draft,
                ),
              ),
              _buildInvoicesListView(
                _filterInvoicesByStatus(
                  state.filteredInvoices,
                  InvoiceStatus.sent,
                ),
              ),
              _buildInvoicesListView(
                _filterInvoicesByStatus(
                  state.filteredInvoices,
                  InvoiceStatus.paid,
                ),
              ),
              _buildInvoicesListView(
                _filterInvoicesByStatus(
                  state.filteredInvoices,
                  InvoiceStatus.overdue,
                ),
              ),
              _buildInvoicesListView(
                _filterInvoicesByStatus(
                  state.filteredInvoices,
                  InvoiceStatus.partiallyPaid,
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInvoicesListView(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return EmptyStateWidget(
        icon: PhosphorIcons.receipt(),
        title: 'No invoices found',
        subtitle: 'No invoices match the current filter',
        actionText: 'Create Invoice',
        onActionPressed: () => _showCreateInvoiceDialog(),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];

        // If no customer data is available, show a simplified card
        if (_selectedCustomer == null) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Card(
              child: ListTile(
                title: Text('Invoice ${invoice.invoiceNumber}'),
                subtitle: Text(
                  'Amount: ₹${invoice.netAmount.toStringAsFixed(2)}',
                ),
                trailing: Text(invoice.status.displayName),
                onTap: () => _showInvoiceDetails(invoice),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: InvoiceCard(
            invoice: invoice,
            customer: _selectedCustomer!,
            onTap: () => _showInvoiceDetails(invoice),
            onEdit: () => _showEditInvoiceDialog(invoice),
            onDelete: () => _showDeleteInvoiceDialog(invoice),
            onGeneratePDF: () => _generatePDF(invoice),
            onShare: () => _shareInvoice(invoice),
            onPrint: () => _printInvoice(invoice),
            onMarkAsPaid: () => _markAsPaid(invoice),
            onMarkAsSent: () => _markAsSent(invoice),
          ),
        );
      },
    );
  }

  List<Invoice> _filterInvoicesByStatus(
    List<Invoice> invoices,
    InvoiceStatus status,
  ) {
    return invoices.where((invoice) => invoice.status == status).toList();
  }

  void _showCreateInvoiceDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Invoice Number: ${invoice.invoiceNumber}'),
              SizedBox(height: 8.h),
              Text(
                'Date: ${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
              ),
              SizedBox(height: 8.h),
              Text('Status: ${invoice.status.displayName}'),
              SizedBox(height: 8.h),
              Text('Net Amount: ₹${invoice.netAmount.toStringAsFixed(2)}'),
              SizedBox(height: 8.h),
              Text('Items: ${invoice.items.length}'),
              if (invoice.notes.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text('Notes: ${invoice.notes}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditInvoiceDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Invoice'),
        content: Text(
          'Edit form for ${invoice.invoiceNumber} will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteInvoiceDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete invoice ${invoice.invoiceNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<InvoiceBloc>().add(DeleteInvoiceEvent(invoice.id));
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _generatePDF(Invoice invoice) {
    if (_selectedCustomer == null || _selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer and Company data not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<InvoiceBloc>().add(
      GeneratePDFEvent(
        invoiceId: invoice.id,
        customer: _selectedCustomer!,
        company: _selectedCompany!,
      ),
    );
  }

  void _shareInvoice(Invoice invoice) {
    if (_selectedCustomer == null || _selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer and Company data not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<InvoiceBloc>().add(
      ShareInvoiceEvent(
        invoiceId: invoice.id,
        customer: _selectedCustomer!,
        company: _selectedCompany!,
      ),
    );
  }

  void _printInvoice(Invoice invoice) {
    if (_selectedCustomer == null || _selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer and Company data not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<InvoiceBloc>().add(
      PrintInvoiceEvent(
        invoiceId: invoice.id,
        customer: _selectedCustomer!,
        company: _selectedCompany!,
      ),
    );
  }

  void _markAsPaid(Invoice invoice) {
    context.read<InvoiceBloc>().add(MarkInvoiceAsPaidEvent(invoice.id));
  }

  void _markAsSent(Invoice invoice) {
    context.read<InvoiceBloc>().add(MarkInvoiceAsSentEvent(invoice.id));
  }
}
