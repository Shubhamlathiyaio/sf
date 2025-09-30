import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sf/models/customer.dart';
import 'package:sf/models/invoice.dart';

import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final Customer? customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onGeneratePDF;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onMarkAsSent;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onGeneratePDF,
    this.onShare,
    this.onPrint,
    this.onMarkAsPaid,
    this.onMarkAsSent,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.1),
          radius: 20.r,
          child: Icon(
            PhosphorIcons.receipt(),
            color: _getStatusColor(),
            size: 16.sp,
          ),
        ),
        title: Row(
          children: [
            Text(invoice.invoiceNumber, style: poppins.fs16.w600),
            gap.w8,
            _buildStatusBadge(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gap.h4,
            Text(
              customer?.firmName ?? 'Unknown Customer',
              style: poppins.fs14.w400,
            ),
            gap.h4,
            Text(
              DateFormat('MMM dd, yyyy').format(invoice.invoiceDate),
              style: poppins.fs12.textColor(AppColors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: '₹').format(invoice.netAmount),
                  style: poppins.fs16.w700.textColor(AppColors.accent2),
                ),
              ],
            ),
            gap.w8,
            PopupMenuButton<String>(
              icon: Icon(
                PhosphorIcons.dotsThreeVertical(),
                size: 16.sp,
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
                if (invoice.status != InvoiceStatus.paid)
                  PopupMenuItem(
                    value: 'mark_paid',
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.checkCircle(),
                          size: 16.sp,
                          color: AppColors.accent2,
                        ),
                        gap.w8,
                        const Text('Mark as Paid'),
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
                  case 'pdf':
                    onGeneratePDF?.call();
                    break;
                  case 'mark_paid':
                    onMarkAsPaid?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        invoice.status.displayName,
        style: poppins.fs10.w600.textColor(_getStatusColor()),
      ),
    );
  }

  Color _getStatusColor() {
    switch (invoice.status) {
      case InvoiceStatus.draft:
        return AppColors.grey;
      case InvoiceStatus.sent:
        return AppColors.primary;
      case InvoiceStatus.paid:
        return AppColors.accent2;
      case InvoiceStatus.overdue:
        return AppColors.error;
      case InvoiceStatus.cancelled:
        return Colors.orange;
      case InvoiceStatus.partiallyPaid:
        return Colors.amber.shade700;
    }
  }
}
