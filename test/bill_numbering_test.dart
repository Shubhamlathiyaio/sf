import 'package:flutter_test/flutter_test.dart';
import 'package:sf/core/models/bill.dart';
import 'package:sf/core/services/bill_management_service.dart';
import 'package:sf/core/services/hive_service.dart';

void main() {
  group('Bill Sequential Numbering Tests', () {
    setUpAll(() async {
      // Initialize Hive service for testing
      await HiveService.init();
    });

    test('should generate sequential bill numbers starting from 1', () async {
      // Clear any existing bills
      final existingBills = await HiveService.getAllBills();
      for (final bill in existingBills) {
        await HiveService.deleteBill(bill.id);
      }

      // Generate first bill number
      final firstNumber = await BillManagementService.generateNextBillNumber();
      expect(firstNumber, '1');

      // Create a bill and save it
      final bill1 = Bill.create(
        billNumber: firstNumber,
        customerName: 'Test Customer 1',
        customerPhone: '1234567890',
        customerEmail: 'test@example.com',
        billDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [],
        taxAmount: 0.0,
        discountAmount: 0.0,
      );
      await HiveService.saveBill(bill1);

      // Generate second bill number
      final secondNumber = await BillManagementService.generateNextBillNumber();
      expect(secondNumber, '2');

      // Create another bill and save it
      final bill2 = Bill.create(
        billNumber: secondNumber,
        customerName: 'Test Customer 2',
        customerPhone: '1234567890',
        customerEmail: 'test2@example.com',
        billDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [],
        taxAmount: 0.0,
        discountAmount: 0.0,
      );
      await HiveService.saveBill(bill2);

      // Generate third bill number
      final thirdNumber = await BillManagementService.generateNextBillNumber();
      expect(thirdNumber, '3');

      // Verify the bills have correct numbers
      final allBills = await HiveService.getAllBills();
      expect(allBills.length, 2);
      expect(allBills.first.billNumber, '1');
      expect(allBills.last.billNumber, '2');
    });

    test('should handle Bill.create with and without bill number', () {
      // Test with bill number
      final billWithNumber = Bill.create(
        billNumber: '5',
        customerName: 'Test Customer',
        customerPhone: '1234567890',
        customerEmail: 'test@example.com',
        billDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [],
        taxAmount: 0.0,
        discountAmount: 0.0,
      );
      expect(billWithNumber.billNumber, '5');

      // Test without bill number (should default to '1')
      final billWithoutNumber = Bill.create(
        customerName: 'Test Customer',
        customerPhone: '1234567890',
        customerEmail: 'test@example.com',
        billDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [],
        taxAmount: 0.0,
        discountAmount: 0.0,
      );
      expect(billWithoutNumber.billNumber, '1');
    });
  });
}
