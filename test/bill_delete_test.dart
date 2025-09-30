import 'package:flutter_test/flutter_test.dart';
import 'package:sf/core/models/bill.dart';
import 'package:sf/core/bloc/bill_bloc.dart';
import 'package:sf/core/bloc/base_bloc_state.dart';
import 'package:sf/core/services/hive_service.dart';

void main() {
  group('Bill Delete Functionality Tests', () {
    setUpAll(() async {
      // Initialize Hive service for testing
      await HiveService.init();
    });

    test('should delete bill without type casting error', () async {
      // Clear any existing bills
      final existingBills = await HiveService.getAllBills();
      for (final bill in existingBills) {
        await HiveService.deleteBill(bill.id);
      }

      // Create and save a test bill
      final testBill = Bill.create(
        billNumber: '1',
        customerName: 'Test Customer',
        customerPhone: '1234567890',
        customerEmail: 'test@example.com',
        billDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [],
        taxAmount: 0.0,
        discountAmount: 0.0,
      );
      await HiveService.saveBill(testBill);

      // Initialize BillBloc and load bills
      final billBloc = BillBloc();
      billBloc.add(const LoadBillsEvent());

      // Wait for bills to load
      await expectLater(
        billBloc.stream,
        emitsInOrder([
          isA<LoadingState>(),
          isA<BillLoadedState>().having(
            (state) => state.bills.length,
            'bills count',
            1,
          ),
        ]),
      );

      // Now delete the bill
      billBloc.add(DeleteBillEvent(testBill.id));

      // Verify the deletion works without type casting error
      await expectLater(
        billBloc.stream,
        emitsInOrder([
          isA<LoadingState>(),
          isA<BillLoadedState>().having(
            (state) => state.bills.length,
            'bills count after delete',
            0,
          ),
          isA<SuccessState>().having(
            (state) => state.message,
            'success message',
            'Bill deleted successfully',
          ),
        ]),
      );

      billBloc.close();
    });

    test('should handle delete bill error gracefully', () async {
      // Initialize BillBloc and load bills
      final billBloc = BillBloc();
      billBloc.add(const LoadBillsEvent());

      // Wait for bills to load
      await expectLater(
        billBloc.stream,
        emitsInOrder([isA<LoadingState>(), isA<BillLoadedState>()]),
      );

      // Try to delete a non-existent bill
      billBloc.add(const DeleteBillEvent('non-existent-id'));

      // Should emit error state
      await expectLater(
        billBloc.stream,
        emitsInOrder([
          isA<LoadingState>(),
          isA<ErrorState>().having(
            (state) => state.message.contains('Failed to delete bill'),
            'error message contains expected text',
            true,
          ),
        ]),
      );

      billBloc.close();
    });
  });
}
