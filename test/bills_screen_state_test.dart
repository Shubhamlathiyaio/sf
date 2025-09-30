import 'package:flutter_test/flutter_test.dart';
import 'package:sf/core/models/bill.dart';
import 'package:sf/core/bloc/bill_bloc.dart';
import 'package:sf/core/bloc/base_bloc_state.dart';
import 'package:sf/core/services/hive_service.dart';

void main() {
  group('Bills Screen State Management Tests', () {
    setUpAll(() async {
      // Initialize Hive service for testing
      await HiveService.init();
    });

    test('should show empty state when no bills exist', () async {
      // Clear any existing bills
      final existingBills = await HiveService.getAllBills();
      for (final bill in existingBills) {
        await HiveService.deleteBill(bill.id);
      }

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
            0,
          ),
        ]),
      );

      billBloc.close();
    });

    test('should update list immediately after adding bill', () async {
      // Clear any existing bills
      final existingBills = await HiveService.getAllBills();
      for (final bill in existingBills) {
        await HiveService.deleteBill(bill.id);
      }

      // Initialize BillBloc and load bills
      final billBloc = BillBloc();
      billBloc.add(const LoadBillsEvent());

      // Wait for initial load
      await expectLater(
        billBloc.stream,
        emitsInOrder([
          isA<LoadingState>(),
          isA<BillLoadedState>().having(
            (state) => state.bills.length,
            'initial bills count',
            0,
          ),
        ]),
      );

      // Add a new bill
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

      billBloc.add(AddBillEvent(testBill));

      // Verify the bill is added immediately
      await expectLater(
        billBloc.stream,
        emitsInOrder([
          isA<LoadingState>(),
          isA<BillLoadedState>().having(
            (state) => state.bills.length,
            'bills count after add',
            1,
          ),
        ]),
      );

      billBloc.close();
    });

    test('should update list immediately after deleting bill', () async {
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

      // Wait for initial load
      await expectLater(
        billBloc.stream,
        emitsInOrder([
          isA<LoadingState>(),
          isA<BillLoadedState>().having(
            (state) => state.bills.length,
            'initial bills count',
            1,
          ),
        ]),
      );

      // Delete the bill
      billBloc.add(DeleteBillEvent(testBill.id));

      // Verify the bill is removed immediately
      await expectLater(
        billBloc.stream,
        emitsInOrder([
          isA<LoadingState>(),
          isA<BillLoadedState>().having(
            (state) => state.bills.length,
            'bills count after delete',
            0,
          ),
        ]),
      );

      billBloc.close();
    });
  });
}
