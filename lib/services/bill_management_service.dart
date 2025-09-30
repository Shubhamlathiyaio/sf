import '../models/bill.dart';
import 'hive_service.dart';

/// Comprehensive service for managing bills with advanced operations
class BillManagementService {
  /// Get all bills
  static Future<List<Bill>> getAllBills() async {
    return await HiveService.getAllBills();
  }

  /// Get bill by ID
  static Future<Bill?> getBillById(String id) async {
    return await HiveService.getBill(id);
  }

  /// Create a new bill
  static Future<void> createBill(Bill bill) async {
    await HiveService.saveBill(bill);
  }

  /// Update an existing bill
  static Future<void> updateBill(Bill bill) async {
    final updatedBill = bill.copyWith(updatedAt: DateTime.now());
    await HiveService.updateBill(updatedBill);
  }

  /// Delete a bill
  static Future<void> deleteBill(String billId) async {
    await HiveService.deleteBill(billId);
  }

  /// Search bills by query
  static Future<List<Bill>> searchBills(String query) async {
    if (query.isEmpty) {
      return await getAllBills();
    }

    final allBills = await getAllBills();
    return allBills.where((bill) {
      return bill.customerName.toLowerCase().contains(query.toLowerCase()) ||
          bill.billNumber.toLowerCase().contains(query.toLowerCase()) ||
          bill.customerEmail.toLowerCase().contains(query.toLowerCase()) ||
          bill.notes.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get bills by status
  static Future<List<Bill>> getBillsByStatus(BillStatus status) async {
    return await HiveService.getBillsByStatus(status);
  }

  /// Get bills by date range
  static Future<List<Bill>> getBillsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await HiveService.getBillsByDateRange(startDate, endDate);
  }

  /// Get overdue bills
  static Future<List<Bill>> getOverdueBills() async {
    final allBills = await getAllBills();
    final now = DateTime.now();

    return allBills.where((bill) {
      return bill.dueDate.isBefore(now) &&
          (bill.status == BillStatus.sent || bill.status == BillStatus.draft);
    }).toList();
  }

  /// Get bills due in next X days
  static Future<List<Bill>> getBillsDueInDays(int days) async {
    final allBills = await getAllBills();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return allBills.where((bill) {
      return bill.dueDate.isAfter(now) &&
          bill.dueDate.isBefore(futureDate) &&
          bill.status != BillStatus.paid &&
          bill.status != BillStatus.cancelled;
    }).toList();
  }

  /// Get revenue statistics
  static Future<Map<String, double>> getRevenueStats() async {
    final allBills = await getAllBills();

    double totalRevenue = 0;
    double paidRevenue = 0;
    double pendingRevenue = 0;
    double overdueRevenue = 0;

    for (final bill in allBills) {
      totalRevenue += bill.totalAmount;

      switch (bill.status) {
        case BillStatus.paid:
          paidRevenue += bill.totalAmount;
          break;
        case BillStatus.sent:
          pendingRevenue += bill.totalAmount;
          break;
        case BillStatus.overdue:
          overdueRevenue += bill.totalAmount;
          break;
        default:
          break;
      }
    }

    return {
      'total': totalRevenue,
      'paid': paidRevenue,
      'pending': pendingRevenue,
      'overdue': overdueRevenue,
    };
  }

  /// Get bill count by status
  static Future<Map<BillStatus, int>> getBillCountByStatus() async {
    final allBills = await getAllBills();
    final Map<BillStatus, int> counts = {};

    for (final status in BillStatus.values) {
      counts[status] = allBills.where((bill) => bill.status == status).length;
    }

    return counts;
  }

  /// Mark bill as paid
  static Future<void> markBillAsPaid(String billId) async {
    final bill = await getBillById(billId);
    if (bill != null) {
      final updatedBill = bill.copyWith(status: BillStatus.paid);
      await updateBill(updatedBill);
    }
  }

  /// Mark bill as sent
  static Future<void> markBillAsSent(String billId) async {
    final bill = await getBillById(billId);
    if (bill != null) {
      final updatedBill = bill.copyWith(status: BillStatus.sent);
      await updateBill(updatedBill);
    }
  }

  /// Mark bill as overdue (automatically called by system)
  static Future<void> markOverdueBills() async {
    final allBills = await getAllBills();
    final now = DateTime.now();

    for (final bill in allBills) {
      if (bill.dueDate.isBefore(now) && bill.status == BillStatus.sent) {
        final updatedBill = bill.copyWith(status: BillStatus.overdue);
        await updateBill(updatedBill);
      }
    }
  }

  /// Duplicate a bill
  static Future<Bill> duplicateBill(String billId) async {
    final originalBill = await getBillById(billId);
    if (originalBill == null) {
      throw Exception('Bill not found');
    }

    final nextNumber = await generateNextBillNumber();
    final duplicatedBill = Bill.create(
      billNumber: nextNumber,
      customerName: originalBill.customerName,
      customerPhone: originalBill.customerPhone,
      customerEmail: originalBill.customerEmail,
      billDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      items: originalBill.items,
      taxAmount: originalBill.taxAmount,
      discountAmount: originalBill.discountAmount,
      notes: '${originalBill.notes} (Copy)',
    );

    await createBill(duplicatedBill);
    return duplicatedBill;
  }

  /// Get monthly revenue data for charts
  static Future<Map<String, double>> getMonthlyRevenue(int year) async {
    final allBills = await getAllBills();
    final Map<String, double> monthlyData = {};

    // Initialize all months to 0
    for (int month = 1; month <= 12; month++) {
      final monthName = _getMonthName(month);
      monthlyData[monthName] = 0.0;
    }

    // Calculate revenue for each month
    for (final bill in allBills) {
      if (bill.billDate.year == year && bill.status == BillStatus.paid) {
        final monthName = _getMonthName(bill.billDate.month);
        monthlyData[monthName] =
            (monthlyData[monthName] ?? 0) + bill.totalAmount;
      }
    }

    return monthlyData;
  }

  /// Get top customers by revenue
  static Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 10,
  }) async {
    final allBills = await getAllBills();
    final Map<String, double> customerRevenue = {};

    for (final bill in allBills) {
      if (bill.status == BillStatus.paid) {
        customerRevenue[bill.customerName] =
            (customerRevenue[bill.customerName] ?? 0) + bill.totalAmount;
      }
    }

    final sortedCustomers = customerRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCustomers
        .take(limit)
        .map((entry) => {'name': entry.key, 'revenue': entry.value})
        .toList();
  }

  /// Generate next bill number
  static Future<String> generateNextBillNumber() async {
    final allBills = await getAllBills();
    final nextNumber = allBills.length + 1;
    return nextNumber.toString();
  }

  /// Helper method to get month name
  static String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  /// Export bills to JSON format
  static Future<Map<String, dynamic>> exportBillsToJson() async {
    final allBills = await getAllBills();
    final stats = await getRevenueStats();

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'totalBills': allBills.length,
      'statistics': stats,
      'bills': allBills
          .map(
            (bill) => {
              'id': bill.id,
              'billNumber': bill.billNumber,
              'customerName': bill.customerName,
              'customerPhone': bill.customerPhone,
              'customerEmail': bill.customerEmail,
              'billDate': bill.billDate.toIso8601String(),
              'dueDate': bill.dueDate.toIso8601String(),
              'items': bill.items
                  .map(
                    (item) => {
                      'id': item.id,
                      'name': item.name,
                      'description': item.description,
                      'quantity': item.quantity,
                      'unitPrice': item.unitPrice,
                      'totalPrice': item.totalPrice,
                      'unit': item.unit,
                    },
                  )
                  .toList(),
              'subtotal': bill.subtotal,
              'taxAmount': bill.taxAmount,
              'discountAmount': bill.discountAmount,
              'totalAmount': bill.totalAmount,
              'status': bill.status.name,
              'notes': bill.notes,
              'createdAt': bill.createdAt.toIso8601String(),
              'updatedAt': bill.updatedAt.toIso8601String(),
            },
          )
          .toList(),
    };
  }
}
