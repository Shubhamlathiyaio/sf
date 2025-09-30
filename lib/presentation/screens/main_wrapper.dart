import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/navigation_bloc.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'customers_list_screen.dart';
import 'bills_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, BaseBlocState>(
      builder: (context, state) {
        int selectedIndex = 0;

        if (state is NavigationTabSelectedState) {
          selectedIndex = state.selectedTabIndex;
        }

        return Scaffold(
          body: _buildBody(selectedIndex),
          bottomNavigationBar: _buildBottomNavigationBar(
            context,
            selectedIndex,
          ),
        );
      },
    );
  }

  Widget _buildBody(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const CustomersListScreen();
      case 2:
        return const BillsScreen();
      case 3:
        return const ReportsScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildNavItem(
                  context: context,
                  icon: PhosphorIcons.house(),
                  activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                  label: 'Dashboard',
                  index: 0,
                  isSelected: selectedIndex == 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  icon: PhosphorIcons.users(),
                  activeIcon: PhosphorIcons.users(PhosphorIconsStyle.fill),
                  label: 'Customers',
                  index: 1,
                  isSelected: selectedIndex == 1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  icon: PhosphorIcons.receipt(),
                  activeIcon: PhosphorIcons.receipt(PhosphorIconsStyle.fill),
                  label: 'Bills',
                  index: 2,
                  isSelected: selectedIndex == 2,
                ),
              ),

              Expanded(
                child: _buildNavItem(
                  context: context,
                  icon: PhosphorIcons.chartPie(),
                  activeIcon: PhosphorIcons.chartPie(PhosphorIconsStyle.fill),
                  label: 'Reports',
                  index: 3,
                  isSelected: selectedIndex == 3,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  icon: PhosphorIcons.gear(),
                  activeIcon: PhosphorIcons.gear(PhosphorIconsStyle.fill),
                  label: 'Settings',
                  index: 4,
                  isSelected: selectedIndex == 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<NavigationBloc>().add(NavigateToTabEvent(index));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22.sp,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            SizedBox(height: 2.h),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
