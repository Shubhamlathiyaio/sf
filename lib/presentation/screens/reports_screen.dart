import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/configs/app_typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
              Text('Reports', style: poppins.fs28.w700),
              SizedBox(height: 24.h),
              _buildReportCard(
                'Revenue Report',
                'Track your income over time',
                PhosphorIcons.trendUp(),
                AppColors.accent2,
              ),
              SizedBox(height: 16.h),
              _buildReportCard(
                'Bills Summary',
                'Overview of all your bills',
                PhosphorIcons.receipt(),
                AppColors.primary,
              ),
              SizedBox(height: 16.h),
              _buildReportCard(
                'Customer Analysis',
                'Insights about your customers',
                PhosphorIcons.users(),
                AppColors.accent1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 24.sp, color: color),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(PhosphorIcons.arrowRight(), size: 16.sp, color: color),
        ],
      ),
    );
  }
}
