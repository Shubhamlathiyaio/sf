import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sf/models/bill.dart';

import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          radius: 22.r,
          child: Text(
            bill.billNumber,
            style: poppins.fs14.w700.textColor(AppColors.primary),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                bill.customerName,
                style: poppins.fs16.w600,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            _buildStatusBadge(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gap.h4,
            Text(
              DateFormat('MMM dd, yyyy').format(bill.billDate),
              style: poppins.fs12.textColor(AppColors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            gap.h4,
            Text(
              NumberFormat.currency(symbol: '₹').format(bill.totalAmount),
              style: poppins.fs16.w700.textColor(AppColors.accent2),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 40.w,
          child: PopupMenuButton<String>(
            icon: Icon(
              PhosphorIcons.dotsThreeVertical(),
              size: 20.sp,
              color: AppColors.grey,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.pencil(), size: 16.sp),
                    gap.w8,
                    const Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.filePdf(), size: 16.sp),
                    gap.w8,
                    const Text('Export PDF'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.trash(),
                      size: 16.sp,
                      color: AppColors.error,
                    ),
                    gap.w8,
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
                case 'pdf':
                  // TODO: Implement PDF export
                  break;
              }
            },
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        bill.status.displayName,
        style: poppins.fs9.w600.textColor(_getStatusColor()),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Color _getStatusColor() {
    switch (bill.status) {
      case BillStatus.draft:
        return AppColors.grey;
      case BillStatus.sent:
        return AppColors.primary;
      case BillStatus.paid:
        return AppColors.accent2;
      case BillStatus.overdue:
        return AppColors.error;
      case BillStatus.cancelled:
        return Colors.orange;
    }
  }
}
