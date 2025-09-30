import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/customer_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import 'add_customer_screen.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Customers', style: poppins.fs20.w600),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<CustomerBloc, BaseBlocState>(
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
                    PhosphorIcons.warningCircle(),
                    size: 48.sp,
                    color: AppColors.error,
                  ),
                  gap.h16,
                  Text(
                    'Error: ${state.message}',
                    style: poppins.fs16.error,
                    textAlign: TextAlign.center,
                  ),
                  gap.h16,
                  ElevatedButton(
                    onPressed: () {
                      context.read<CustomerBloc>().add(
                        const LoadCustomersEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CustomerLoadedState) {
            if (state.customers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.users(),
                      size: 64.sp,
                      color: AppColors.grey,
                    ),
                    gap.h16,
                    Text('No customers yet', style: poppins.fs18.w600),
                    gap.h8,
                    Text(
                      'Add your first customer to get started',
                      style: poppins.fs14.textColor(AppColors.grey),
                    ),
                    gap.h24,
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddCustomerScreen(),
                          ),
                        );
                      },
                      icon: Icon(PhosphorIcons.plus()),
                      label: const Text('Add Customer'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerBloc>().add(const LoadCustomersEvent());
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final customer = state.customers[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          customer.initials,
                          style: poppins.fs14.w600.white,
                        ),
                      ),
                      title: Text(customer.firmName, style: poppins.fs16.w600),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.mobileNumber,
                            style: poppins.fs14.textColor(AppColors.grey),
                          ),
                          if (customer.gstNumber.isNotEmpty)
                            Text(
                              'GST: ${customer.gstNumber}',
                              style: poppins.fs12.textColor(AppColors.grey),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(PhosphorIcons.pencil()),
                                gap.w8,
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.trash(),
                                  color: AppColors.error,
                                ),
                                gap.w8,
                                Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddCustomerScreen(customer: customer),
                              ),
                            );
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, customer);
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddCustomerScreen(customer: customer),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Customer', style: poppins.fs18.w600),
        content: Text(
          'Are you sure you want to delete ${customer.firmName}? This action cannot be undone.',
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
                DeleteCustomerEvent(customer.id),
              );
            },
            child: Text('Delete', style: poppins.fs14.w500.error),
          ),
        ],
      ),
    );
  }
}
