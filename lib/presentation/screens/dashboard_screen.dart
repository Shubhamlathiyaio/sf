import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/bill_bloc.dart';
import 'package:sf/models/bill.dart';
import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_bills_list.dart';
import 'create_invoice_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              gap.h24,
              _buildStatsSection(),
              gap.h32,
              _buildQuickActions(context),
              gap.h32,
              _buildRecentBills(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good morning! 👋', style: poppins.fs16.textColor(AppColors.grey)),
        gap.h4,
        Text('Dashboard', style: poppins.fs28.w700),
      ],
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<BillBloc, BaseBlocState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return _buildLoadingStats();
        }

        if (state is ErrorState) {
          return _buildErrorStats(state.message);
        }

        if (state is BillLoadedState) {
          final bills = state.bills;
          final totalRevenue = bills
              .where((bill) => bill.status == BillStatus.paid)
              .fold(0.0, (sum, bill) => sum + bill.totalAmount);

          final pendingAmount = bills
              .where(
                (bill) =>
                    bill.status == BillStatus.sent ||
                    bill.status == BillStatus.overdue,
              )
              .fold(0.0, (sum, bill) => sum + bill.totalAmount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: poppins.fs18.w600),
              gap.h16,
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Bills',
                      value: bills.length.toString(),
                      icon: PhosphorIcons.receipt(),
                      color: AppColors.primary,
                    ),
                  ),
                  gap.w12,
                  Expanded(
                    child: StatCard(
                      title: 'Paid',
                      value: bills
                          .where((b) => b.status == BillStatus.paid)
                          .length
                          .toString(),
                      icon: PhosphorIcons.checkCircle(),
                      color: AppColors.accent2,
                    ),
                  ),
                ],
              ),
              gap.h12,
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Revenue',
                      value: '₹${totalRevenue.toStringAsFixed(0)}',
                      icon: PhosphorIcons.currencyInr(),
                      color: AppColors.accent2,
                    ),
                  ),
                  gap.w12,
                  Expanded(
                    child: StatCard(
                      title: 'Pending',
                      value: '₹${pendingAmount.toStringAsFixed(0)}',
                      icon: PhosphorIcons.clock(),
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return _buildLoadingStats();
      },
    );
  }

  Widget _buildLoadingStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: poppins.fs18.w600),
        gap.h16,
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Bills',
                value: '0',
                icon: PhosphorIcons.receipt(),
                color: AppColors.primary,
              ),
            ),
            gap.w12,
            Expanded(
              child: StatCard(
                title: 'Paid',
                value: '0',
                icon: PhosphorIcons.checkCircle(),
                color: AppColors.accent2,
              ),
            ),
          ],
        ),
        gap.h12,
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Revenue',
                value: '₹ 0',
                icon: PhosphorIcons.currencyInr(),
                color: AppColors.accent2,
              ),
            ),
            gap.w12,
            Expanded(
              child: StatCard(
                title: 'Pending',
                value: '₹ 0',
                icon: PhosphorIcons.clock(),
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorStats(String errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: poppins.fs18.w600),
        gap.h16,
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.error.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                PhosphorIcons.warning(),
                color: AppColors.error,
                size: 24.sp,
              ),
              gap.h8,
              Text(
                'Failed to load data',
                style: poppins.fs14.w600.textColor(AppColors.error),
              ),
              gap.h4,
              Text(
                errorMessage,
                style: poppins.fs12.textColor(AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    // TODO: Fix the UI with Add Cutomer Button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: poppins.fs18.w600),
        gap.h16,
        SizedBox(
          width: double.infinity,
          child: _buildActionCard(
            context,
            'Create Invoice',
            PhosphorIcons.receipt(),
            AppColors.primary,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateInvoiceScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.sp, color: color),
            ),
            gap.w12,
            Expanded(
              child: Text(title, style: poppins.fs14.w600.textColor(color)),
            ),
            Icon(PhosphorIcons.arrowRight(), size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Bills', style: poppins.fs18.w600),
        gap.h16,
        const RecentBillsList(),
      ],
    );
  }
}
