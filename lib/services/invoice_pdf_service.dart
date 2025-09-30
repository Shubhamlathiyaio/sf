import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/company.dart';

class InvoicePDFService {
  /// Generate PDF for invoice that matches SHUBHAM FASHION structure
  static Future<Uint8List> generateInvoicePDF({
    required Invoice invoice,
    required Customer customer,
    required Company company,
  }) async {
    // Validate inputs
    if (company.companyName.isEmpty) {
      throw Exception('Company name is required');
    }
    if (customer.firmName.isEmpty) {
      throw Exception('Customer firm name is required');
    }

    final pdf = pw.Document();

    // Load custom fonts
    final fontData = await rootBundle.load("assets/fonts/opensans/OpenSans-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/opensans/OpenSans-Bold.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: boldTtf,
        ),
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            child: _buildInvoiceContent(invoice, customer, company),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build the complete invoice content
  static pw.Widget _buildInvoiceContent(
    Invoice invoice,
    Customer customer,
    Company company,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildHeader(company),
        _buildInvoiceTitle(),
        _buildInvoiceInfo(invoice, customer, company),
        _buildBillingDetails(customer),
        pw.Expanded(
          child: _buildItemsTable(invoice.items),
        ),
        _buildTotalsAndBankDetails(invoice, company),
        _buildTermsAndSignature(company),
      ],
    );
  }

  static pw.Widget _buildBillingCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  /// Build the header section
  static pw.Widget _buildHeader(Company company) {
    return pw.Column(
      children: [
        // Top religious texts
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '|| Shree Ganeshay Namah ||',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.Text(
              '|| Jay Yogeshwar ||',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        // Main header content
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1.5)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Left side: Logo and company details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Logo
                  pw.Container(
                    width: 48,
                    height: 48,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.deepOrange,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'SF',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Company name and address
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        company.companyName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        company.address,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              // Right side: Contact number
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.5),
                ),
                child: pw.Text(
                  company.mobileNumber,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the invoice title
  static pw.Widget _buildInvoiceTitle() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      margin: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.5),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  /// Build invoice information section
  static pw.Widget _buildInvoiceInfo(
    Invoice invoice,
    Customer customer,
    Company company,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 10, 10, 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1.5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - GST Info
          pw.Expanded(
            flex: 4,
            child: pw.Container(
              height: 60,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildRichText('GST No: ', company.gstNumber, valueColor: PdfColors.red),
                  pw.SizedBox(height: 5),
                  _buildRichText('State Code: ', company.stateCode, valueColor: PdfColors.red),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          // Right side - Bill Info
          pw.Expanded(
            flex: 5,
            child: pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(1.4),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _buildInfoTableRow(
                  'Bill No:',
                  invoice.invoiceNumber,
                  valueColor: PdfColors.red,
                  valueFontSize: 14,
                ),
                _buildInfoTableRow('Date:', _formatDate(invoice.invoiceDate)),
                _buildInfoTableRow('Due Date:', _formatDate(invoice.dueDate)),
                _buildInfoTableRow('Due Days:', '${invoice.dueDays} Days'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build billing details section
  static pw.Widget _buildBillingDetails(Customer customer) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1.5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Title
          pw.Container(
            padding: const pw.EdgeInsets.all(2),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Center(
              child: pw.Text(
                'BILLING DETAILS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
          // Details Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.5),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                children: [
                  _buildBillingCell('M/S: ${customer.firmName}'),
                  _buildBillingCell('GST No: ${customer.gstNumber}'),
                  _buildBillingCell('Mo: ${customer.mobileNumber}'),
                ],
              ),
            ],
          ),
          pw.Table(
            border: const pw.TableBorder(
              left: pw.BorderSide(width: 1),
              right: pw.BorderSide(width: 1),
              bottom: pw.BorderSide(width: 1),
              horizontalInside: pw.BorderSide(width: 1),
            ),
            children: [
              pw.TableRow(
                children: [
                  _buildBillingCell('Ofc Address: ${customer.firmAddress}'),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildBillingCell('Delivery Address: ${customer.deliveryAddress}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build items table
  static pw.Widget _buildItemsTable(List<InvoiceItem> items) {
    final tableHeaders = [
      'Sr', 'Chalan', 'Description', 'Taka', 'HSN', 'Meter', 'Rate', 'Amount'
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5),
          1: pw.FlexColumnWidth(0.6),
          2: pw.FlexColumnWidth(3),
          3: pw.FlexColumnWidth(0.6),
          4: pw.FlexColumnWidth(0.8),
          5: pw.FlexColumnWidth(1),
          6: pw.FlexColumnWidth(0.8),
          7: pw.FlexColumnWidth(1.2),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: tableHeaders.map((header) => _buildTableCell(
              header,
              isHeader: true,
              fontSize: 10,
            )).toList(),
          ),
          // Item rows
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.top,
              children: [
                _buildTableCell('${item.srNo}'),
                _buildTableCell(item.chalanNo),
                _buildTableCell(
                  item.description,
                  textAlign: pw.TextAlign.left,
                ),
                _buildTableCell('${item.taka.toInt()}'),
                _buildTableCell(item.hsnCode),
                _buildTableCell(item.meter.toStringAsFixed(item.meter.truncateToDouble() == item.meter ? 0 : 2)),
                _buildTableCell(item.rate.toStringAsFixed(item.rate.truncateToDouble() == item.rate ? 0 : 2)),
                _buildTableCell(
                  item.amount.toStringAsFixed(0),
                  textAlign: pw.TextAlign.right,
                ),
              ],
            );
          }),
          // Subtotal row
          pw.TableRow(
            children: [
              _buildTableCell(''),
              _buildTableCell(''),
              _buildTableCell(
                'Subtotal',
                textAlign: pw.TextAlign.right,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              _buildTableCell(''),
              _buildTableCell(''),
              _buildTableCell(
                _getTotalMeter(items).toString(),
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              _buildTableCell(''),
              _buildTableCell(
                _getSubtotal(items).toStringAsFixed(0),
                textAlign: pw.TextAlign.right,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build totals and bank details section
  static pw.Widget _buildTotalsAndBankDetails(Invoice invoice, Company company) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 5, 10, 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - Bank details and amount in words
          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildBankDetails(company),
                pw.SizedBox(height: 5),
                _buildRichText('Remark: ', invoice.notes),
                pw.SizedBox(height: 5),
                pw.Text(
                  invoice.amountInWords.toUpperCase(),
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          // Right side - Calculations
          pw.Expanded(
            flex: 5,
            child: _buildCalculationDetails(invoice),
          ),
        ],
      ),
    );
  }

  /// Build terms and signature section
  static pw.Widget _buildTermsAndSignature(Company company) {
    final terms = [
      '1) Complaint, if any, regarding this Invoice must be settled immediately.',
      '2) Goods once sold will not be taken back or exchanged.',
      '3) Goods are dispatched to the account and risk of the buyer.',
      '4) Interest @2% per month will be charged on the amount remaining unpaid from the due date.',
      '5) Subject to SURAT Jurisdiction.',
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 5, 10, 5),
      margin: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Terms and Conditions
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Terms and Conditions:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
                pw.SizedBox(height: 4),
                ...terms.map((term) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 1),
                      child: pw.Text(term, style: const pw.TextStyle(fontSize: 8)),
                    )),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          // Signature
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'FOR YOUR COMPANY',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'S.D.Lathiya',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
                pw.Divider(color: PdfColors.black, thickness: 1, height: 1),
                pw.Text(
                  'Auth Sign.',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static pw.TableRow _buildInfoTableRow(
    String label,
    String value, {
    PdfColor? valueColor,
    double? valueFontSize,
  }) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
              fontSize: valueFontSize ?? 10,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    );
  }

  static pw.RichText _buildRichText(
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.RichText(
      text: pw.TextSpan(
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        children: [
          pw.TextSpan(text: label),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(color: valueColor),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBankDetails(Company company) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildRichText('Bank: ', company.bankName),
        _buildRichText('Branch: ', company.branchName),
        _buildRichText('A/C: ', company.accountNumber),
        _buildRichText('IFSC: ', company.ifscCode),
      ],
    );
  }

  static pw.Widget _buildCalculationDetails(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.5),
        1: pw.FlexColumnWidth(1.5),
      },
      children: [
        _buildCalculationRow('Discount (7%)', '-${invoice.discount.toStringAsFixed(0)}'),
        _buildCalculationRow('Oth Less', '-${invoice.otherDeductions.toStringAsFixed(0)}'),
        _buildCalculationRow('Freight', '+${invoice.freight.toStringAsFixed(2)}'),
        _buildCalculationRow('Taxable Value', invoice.taxableValue.toStringAsFixed(2)),
        _buildCalculationRow('I GST (2.5%)', '+${invoice.igstAmount.toStringAsFixed(2)}'),
        _buildCalculationRow('S GST (2.5%)', '+${invoice.sgstAmount.toStringAsFixed(2)}'),
        _buildCalculationRow('C GST (2.5%)', '+${invoice.cgstAmount.toStringAsFixed(2)}'),
        _buildCalculationRow(
          'Net Amount',
          invoice.netAmount.toStringAsFixed(2),
          isHeader: true,
        ),
      ],
    );
  }

  static pw.TableRow _buildCalculationRow(String label, String value, {bool isHeader = false}) {
    return pw.TableRow(
      decoration: isHeader ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: isHeader ? 12 : 10,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign? textAlign,
    double? fontSize,
    pw.FontWeight? fontWeight,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize ?? 9,
          fontWeight: fontWeight ?? (isHeader ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
        textAlign: textAlign ?? pw.TextAlign.center,
        maxLines: 4,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  static double _getSubtotal(List<InvoiceItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.amount);
  }

  static int _getTotalMeter(List<InvoiceItem> items) {
    return items.fold(0, (sum, item) => sum + item.meter.toInt());
  }

  /// Save PDF to device storage
  static Future<String> savePDFToDevice(
    Uint8List pdfBytes,
    String fileName,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// Share PDF using share_plus package
  static Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice: $fileName',
    );
  }

  /// Open PDF with system default app
  static Future<void> openPDF(Uint8List pdfBytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice: $fileName',
    );
  }

  /// Preview PDF using printing package (works on all platforms)
  static Future<void> previewPDF(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }

  /// Print PDF directly
  static Future<void> printPDF(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }
}