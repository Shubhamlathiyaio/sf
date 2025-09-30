import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sf/bloc/base_bloc_state.dart';
import 'package:sf/bloc/bill_bloc.dart';
import 'bill_card.dart';
import 'empty_state_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RecentBillsList extends StatelessWidget {
  const RecentBillsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillBloc, BaseBlocState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return SizedBox(
            height: 200.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BillLoadedState) {
          final recentBills = state.bills.take(3).toList();

          if (recentBills.isEmpty) {
            return SizedBox(
              height: 200.h,
              child: EmptyStateWidget(
                icon: PhosphorIcons.receipt(),
                title: 'No bills yet',
                subtitle: 'Create your first bill to see it here',
              ),
            );
          }

          return Column(
            children: recentBills
                .map(
                  (bill) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: BillCard(
                      bill: bill,
                      onTap: () {
                        // TODO: Navigate to bill details
                      },
                    ),
                  ),
                )
                .toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
