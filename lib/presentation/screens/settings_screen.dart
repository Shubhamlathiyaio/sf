import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/app_bloc.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import 'company_config_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              Text('Settings', style: poppins.fs28.w700),
              gap.h32,
              _buildSection('Appearance', [_buildThemeToggle(context)]),
              gap.h24,
              _buildSection('General', [
                _buildSettingsItem(
                  'Organization',
                  'Manage your company details',
                  PhosphorIcons.buildings(),
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CompanyConfigScreen(),
                      ),
                    );
                  },
                ),
                _buildLanguageSelector(context),
                _buildSettingsItem(
                  'Export Data',
                  'Download your billing data',
                  PhosphorIcons.downloadSimple(),
                  () {},
                ),
                _buildSettingsItem(
                  'Backup & Sync',
                  'Manage your data backup',
                  PhosphorIcons.cloudArrowUp(),
                  () {},
                ),
              ]),
              gap.h24,
              _buildSection('Support', [
                _buildSettingsItem(
                  'Help Center',
                  'Get help and support',
                  PhosphorIcons.question(),
                  () {},
                ),
                _buildSettingsItem(
                  'Privacy Policy',
                  'Read our privacy policy',
                  PhosphorIcons.shieldCheck(),
                  () {},
                ),
                _buildSettingsItem(
                  'About',
                  'App version and information',
                  PhosphorIcons.info(),
                  () {},
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: poppins.fs18.w600),
        gap.h16,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.outline.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<AppBloc, BaseBlocState>(
      builder: (context, state) {
        bool isDarkMode = false;
        if (state is AppLoadedState) {
          isDarkMode = state.isDarkMode;
        }

        return Container(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isDarkMode ? PhosphorIcons.moon() : PhosphorIcons.sun(),
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
              gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dark Theme', style: poppins.fs16.w500),
                    gap.h4,
                    Text(
                      'Switch between light and dark mode',
                      style: poppins.fs12.textColor(AppColors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  context.read<AppBloc>().add(const ToggleThemeEvent());
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              PhosphorIcons.translate(),
              size: 20.sp,
              color: AppColors.primary,
            ),
          ),
          gap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Language', style: poppins.fs16.w500),
                gap.h4,
                Text(
                  'Choose your preferred language',
                  style: poppins.fs12.textColor(AppColors.grey),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: 'English',
            underline: const SizedBox(),
            icon: Icon(
              PhosphorIcons.caretDown(),
              size: 16.sp,
              color: AppColors.grey,
            ),
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'Hindi', child: Text('हिंदी')),
              DropdownMenuItem(value: 'Gujarati', child: Text('ગુજરાતી')),
            ],
            onChanged: (value) {
              // TODO: Implement language switching
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language switching coming soon'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.sp, color: AppColors.primary),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: poppins.fs16.w500),
                  gap.h4,
                  Text(subtitle, style: poppins.fs12.textColor(AppColors.grey)),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(),
              size: 16.sp,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
