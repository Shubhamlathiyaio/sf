import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/configs/app_typography.dart';
import '../../core/configs/gap.dart';
import '../../models/customer.dart';
import '../../models/company.dart';
import '../../models/invoice.dart';
import '../../services/invoice_pdf_service.dart';

class DetailedBillScreen extends StatelessWidget {
  final String billNumber;
  final DateTime billDate;
  final DateTime dueDate;
  final Customer customer;
  final Company company;
  final List items;

  const DetailedBillScreen({
    super.key,
    required this.billNumber,
    required this.billDate,
    required this.dueDate,
    required this.customer,
    required this.company,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Invoice #$billNumber', style: poppins.fs18.w600),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: Icon(PhosphorIcons.pencilSimple()),
            onPressed: () => _editBill(context),
            tooltip: 'Edit Bill',
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: Icon(PhosphorIcons.dotsThreeVertical()),
            onSelected: (value) {
              switch (value) {
                case 'print':
                  _generatePDF(context);
                  break;
                case 'share':
                  _shareBill(context);
                  break;
                case 'duplicate':
                  _duplicateBill(context);
                  break;
                case 'delete':
                  _deleteBill(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.printer(), size: 16.sp),
                    gap.w8,
                    Text('Print PDF'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.shareNetwork(), size: 16.sp),
                    gap.w8,
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.copy(), size: 16.sp),
                    gap.w8,
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
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
          ),
        ],
      ),
      body: Column(
        children: [
          // Action buttons bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Edit',
                    PhosphorIcons.pencilSimple(),
                    AppColors.primary,
                    () => _editBill(context),
                  ),
                ),
                gap.w12,
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Share',
                    PhosphorIcons.shareNetwork(),
                    AppColors.accent2,
                    () => _shareBill(context),
                  ),
                ),
                gap.w12,
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Print',
                    PhosphorIcons.printer(),
                    AppColors.grey,
                    () => _generatePDF(context),
                  ),
                ),
              ],
            ),
          ),
          // Bill content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildInvoiceTitle(),
                    _buildInvoiceInfo(),
                    _buildBillingDetails(),
                    _buildItemsTable(),
                    _buildTotalsSection(),
                    _buildTermsAndConditions(),
                    _buildSignature(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: color),
            gap.w6,
            Text(label, style: poppins.fs12.w600.textColor(color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('|| Shree Ganeshay Namah ||', style: poppins.fs12.w600),
              gap.h8,
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Center(
                      child: Text(
                        'SF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  gap.w12,
                  Text('SHUBHAM FASHION', style: poppins.fs20.w700),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('|| Jay Yogeshwar ||', style: poppins.fs12.w600),
              gap.h8,
              Text('98796 71385', style: poppins.fs16.w600),
              Text(
                'U 7106 Radhakrishna Textiles Market Ring Road Surat',
                style: poppins.fs10.w400,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTitle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Center(child: Text('INVOICE', style: poppins.fs24.w700)),
    );
  }

  Widget _buildInvoiceInfo() {
    final dueDays = dueDate.difference(billDate).inDays;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Row(
        children: [
          // Left side - GST Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'GST No: ',
                        style: poppins.fs12.w600.black,
                      ),
                      TextSpan(
                        text: '24ACYPL1289J1ZY',
                        style: poppins.fs12.w600.error,
                      ),
                    ],
                  ),
                ),
                gap.h4,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'State Code: ',
                        style: poppins.fs12.w600.black,
                      ),
                      TextSpan(text: '24', style: poppins.fs12.w600.error),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right side - Bill Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Bill No: ', style: poppins.fs12.w600),
                    Text(billNumber, style: poppins.fs16.w700.error),
                  ],
                ),
                gap.h4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Date: ', style: poppins.fs12.w600),
                    Text(_formatDate(billDate), style: poppins.fs12.w600),
                  ],
                ),
                gap.h4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Due Date: ', style: poppins.fs12.w600),
                    Text(_formatDate(dueDate), style: poppins.fs12.w600),
                  ],
                ),
                gap.h4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Due Days: ', style: poppins.fs12.w600),
                    Text('$dueDays Days', style: poppins.fs12.w600),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingDetails() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text('BILLING DETAILS', style: poppins.fs14.w700)),
          gap.h12,
          Table(
            border: TableBorder.all(color: Colors.black, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  _buildTableCell('M/S: ${customer.firmName}', isHeader: false),
                  _buildTableCell(
                    'GST No: ${customer.gstNumber}',
                    isHeader: false,
                  ),
                  _buildTableCell(
                    'Mo: ${customer.mobileNumber}',
                    isHeader: false,
                  ),
                ],
              ),
            ],
          ),
          gap.h8,
          Table(
            border: TableBorder.all(color: Colors.black, width: 1),
            children: [
              TableRow(
                children: [
                  _buildTableCell(
                    'Ofc Address: ${customer.firmAddress}',
                    isHeader: false,
                  ),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell(
                    'Delivery Address: ${customer.deliveryAddress}',
                    isHeader: false,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      margin: EdgeInsets.all(16.r),
      child: Table(
        border: TableBorder.all(color: Colors.black, width: 1),
        columnWidths: const {
          0: FlexColumnWidth(0.5), // Sr
          1: FlexColumnWidth(0.8), // Chalan
          2: FlexColumnWidth(2.5), // Description
          3: FlexColumnWidth(0.8), // Taka
          4: FlexColumnWidth(0.8), // HSN
          5: FlexColumnWidth(1), // Meter
          6: FlexColumnWidth(0.8), // Rate
          7: FlexColumnWidth(1.2), // Amount
        },
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[100]),
            children: [
              _buildTableCell('Sr', isHeader: true),
              _buildTableCell('Chalan', isHeader: true),
              _buildTableCell('Description', isHeader: true),
              _buildTableCell('Taka', isHeader: true),
              _buildTableCell('HSN', isHeader: true),
              _buildTableCell('Meter', isHeader: true),
              _buildTableCell('Rate', isHeader: true),
              _buildTableCell('Amount', isHeader: true),
            ],
          ),
          // Item rows
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return TableRow(
              children: [
                _buildTableCell('${index + 1}'),
                _buildTableCell('${index + 1}'),
                _buildTableCell(item.description),
                _buildTableCell('${item.taka}'),
                _buildTableCell('${item.hsn}'),
                _buildTableCell('${item.meter}'),
                _buildTableCell('${item.rate}'),
                _buildTableCell(item.amount.toStringAsFixed(0)),
              ],
            );
          }),
          // Empty rows for spacing
          ...List.generate(3 - items.length.clamp(0, 3), (index) {
            return TableRow(
              children: List.generate(
                8,
                (i) => _buildTableCell('', height: 30.h),
              ),
            );
          }),
          // Subtotal row
          TableRow(
            children: [
              _buildTableCell(''),
              _buildTableCell(''),
              _buildTableCell('Subtotal', isHeader: true),
              _buildTableCell(''),
              _buildTableCell(''),
              _buildTableCell('${_getTotalMeter()}'),
              _buildTableCell(''),
              _buildTableCell(
                _getSubtotal().toStringAsFixed(0),
                isHeader: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    final subtotal = _getSubtotal();
    final discount = 500.0;
    final otherLess = 687.0;
    final freight = 987.01;
    final taxableValue = subtotal - discount - otherLess + freight;
    final igst = taxableValue * 0.025; // 2.5%
    final sgst = taxableValue * 0.025; // 2.5%
    final cgst = taxableValue * 0.025; // 2.5%
    final netAmount = taxableValue + igst + sgst + cgst;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Bank details
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank: HDFC BANK', style: poppins.fs12.w600),
                Text('Branch: Nanpura', style: poppins.fs12.w600),
                Text('A/C: 50500000000000.0', style: poppins.fs12.w600),
                Text('IFSC: HDFC0001026', style: poppins.fs12.w600),
                gap.h16,
                Text('Remark: Lore ipsum text', style: poppins.fs12.w600),
                gap.h16,
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(
                    'FIFTY THOUSAND FOUR HUNDRED FOUR ONLY',
                    style: poppins.fs12.w600,
                  ),
                ),
              ],
            ),
          ),
          gap.w16,
          // Right side - Calculations
          Expanded(
            flex: 2,
            child: Table(
              border: TableBorder.all(color: Colors.black, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                _buildCalculationRow('Discount (7%)', '-500'),
                _buildCalculationRow('Oth Less', '-687'),
                _buildCalculationRow('Freight', '+987.01'),
                _buildCalculationRow('Taxable Value', '48003.75'),
                _buildCalculationRow('I GST (2.5%)', '+1200.09'),
                _buildCalculationRow('S GST (2.5%)', '+1200.09'),
                _buildCalculationRow('C GST (2.5%)', '+1200.09'),
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    _buildTableCell('Net Amount', isHeader: true),
                    _buildTableCell('50404.00', isHeader: true, fontSize: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Terms and Conditions:', style: poppins.fs12.w700),
          gap.h8,
          Text(
            '1) Complaint, if any, regarding this Invoice must be settled immediately.',
            style: poppins.fs10.w400,
          ),
          Text(
            '2) Goods once sold will not be taken back or exchanged.',
            style: poppins.fs10.w400,
          ),
          Text(
            '3) Goods are dispatched to the account and risk of the buyer.',
            style: poppins.fs10.w400,
          ),
          Text(
            '4) Interest @2% per month will be charged on the amount remaining unpaid from the due date.',
            style: poppins.fs10.w400,
          ),
          Text('5) Subject to SURAT Jurisdiction.', style: poppins.fs10.w400),
        ],
      ),
    );
  }

  Widget _buildSignature() {
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('FOR YOUR COMPANY', style: poppins.fs12.w600),
              gap.h40,
              SizedBox(
                width: 120.w,
                child: Column(
                  children: [
                    Text('S.D.Lathiya', style: poppins.fs16.w600),
                    Divider(color: Colors.black),
                    Text('Auth Sign.', style: poppins.fs12.w600),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildCalculationRow(String label, String value) {
    return TableRow(
      children: [
        _buildTableCell(label),
        _buildTableCell(value, textAlign: TextAlign.right),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    double? height,
    TextAlign? textAlign,
    double? fontSize,
  }) {
    return Container(
      height: height ?? 30.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize?.sp ?? (isHeader ? 11.sp : 10.sp),
            fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
            fontFamily: 'Poppins',
          ),
          textAlign: textAlign ?? TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  double _getSubtotal() {
    return items.fold(0.0, (sum, item) => sum + item.amount);
  }

  int _getTotalMeter() {
    return items.fold<int>(0, (sum, item) => (sum + item.meter) as int);
  }

  void _editBill(BuildContext context) {
    // Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit functionality will open edit screen'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _duplicateBill(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Duplicate Bill'),
        content: Text('Do you want to create a copy of this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bill duplicated successfully'),
                  backgroundColor: AppColors.accent2,
                ),
              );
            },
            child: Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _deleteBill(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.warning(), color: AppColors.error),
            gap.w8,
            Text('Delete Bill'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this bill? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to bills list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bill deleted successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _generatePDF(BuildContext context) async {
    try {
      // Create temporary invoice items
      final invoiceItems = <InvoiceItem>[];
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        invoiceItems.add(
          InvoiceItem.create(
            srNo: i + 1,
            description: item.description,
            taka: item.taka.toDouble(),
            meter: item.meter.toDouble(),
            rate: item.rate.toDouble(),
            gstRate: 5.0, // Default GST rate
            chalanNo: (i + 1).toString(),
            hsnCode: item.hsn.toString(),
          ),
        );
      }

      // Create a temporary invoice object for PDF generation
      final invoice = Invoice.create(
        customerId: customer.id,
        companyId: company.id,
        items: invoiceItems,
        invoiceNumber: billNumber,
        invoiceDate: billDate,
        discount: 500.0,
        otherDeductions: 687.0,
        freight: 987.01,
        dueDays: dueDate.difference(billDate).inDays,
        broker: '',
        notes: '',
      );

      // Generate PDF
      final pdfBytes = await InvoicePDFService.generateInvoicePDF(
        invoice: invoice,
        customer: customer,
        company: company,
      );

      // Preview the PDF
      await InvoicePDFService.previewPDF(pdfBytes, 'Invoice_$billNumber');
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _shareBill(BuildContext context) async {
    try {
      // Create temporary invoice items
      final invoiceItems = <InvoiceItem>[];
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        invoiceItems.add(
          InvoiceItem.create(
            srNo: i + 1,
            description: item.description,
            taka: item.taka.toDouble(),
            meter: item.meter.toDouble(),
            rate: item.rate.toDouble(),
            gstRate: 5.0, // Default GST rate
            chalanNo: (i + 1).toString(),
            hsnCode: item.hsn.toString(),
          ),
        );
      }

      // Create a temporary invoice object for PDF generation
      final invoice = Invoice.create(
        customerId: customer.id,
        companyId: company.id,
        items: invoiceItems,
        invoiceNumber: billNumber,
        invoiceDate: billDate,
        discount: 500.0,
        otherDeductions: 687.0,
        freight: 987.01,
        dueDays: dueDate.difference(billDate).inDays,
        broker: '',
        notes: '',
      );

      // Generate PDF
      final pdfBytes = await InvoicePDFService.generateInvoicePDF(
        invoice: invoice,
        customer: customer,
        company: company,
      );

      // Share the PDF
      await InvoicePDFService.sharePDF(pdfBytes, 'Invoice_$billNumber');
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}