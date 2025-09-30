import 'dart:io';
import 'dart:typed_data';
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
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return _buildInvoiceContent(invoice, customer, company);
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
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
      ),
      child: pw.Column(
        children: [
          _buildHeader(company),
          _buildInvoiceTitle(),
          _buildInvoiceInfo(invoice, customer),
          _buildBillingDetails(customer),
          _buildItemsTable(invoice.items),
          _buildTotalsAndBankDetails(invoice, company),
          _buildTermsAndSignature(company),
        ],
      ),
    );
  }

  /// Build the header section
  static pw.Widget _buildHeader(Company company) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Religious text and logo
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '|| Shree Ganeshay Namah ||',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  // Logo placeholder
                  pw.Container(
                    width: 40,
                    height: 40,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'SF',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Text(
                    'SHUBHAM FASHION',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          // Right side - Religious text and contact
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '|| Jay Yogeshwar ||',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '98796 71385',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'U 7106 Radhakrishna Textiles Market Ring Road Surat',
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the invoice title
  static pw.Widget _buildInvoiceTitle() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
      ),
      child: pw.Center(
        child: pw.Text(
          'INVOICE',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }

  /// Build invoice information section
  static pw.Widget _buildInvoiceInfo(Invoice invoice, Customer customer) {
    final dueDays = invoice.dueDate.difference(invoice.invoiceDate).inDays;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
      ),
      child: pw.Row(
        children: [
          // Left side - GST Info
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'GST No: ',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(
                        text: '24ACYPL1289J1ZY',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'State Code: ',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(
                        text: '24',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right side - Bill Info
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Bill No: ',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      invoice.invoiceNumber,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Date: ',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _formatDate(invoice.invoiceDate),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Due Date: ',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _formatDate(invoice.dueDate),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Due Days: ',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '$dueDays Days',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
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
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              'BILLING DETAILS',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  _buildTableCell('M/S: ${customer.firmName}', isHeader: false),
                  _buildTableCell('GST No: ${customer.gstNumber}', isHeader: false),
                  _buildTableCell('Mo: ${customer.mobileNumber}', isHeader: false),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black),
            children: [
              pw.TableRow(
                children: [
                  _buildTableCell('Ofc Address: ${customer.firmAddress}', isHeader: false),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('Delivery Address: ${customer.deliveryAddress}', isHeader: false),
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
    return pw.Container(
      margin: const pw.EdgeInsets.all(16),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.5), // Sr
          1: pw.FlexColumnWidth(0.8), // Chalan
          2: pw.FlexColumnWidth(2.5), // Description
          3: pw.FlexColumnWidth(0.8), // Taka
          4: pw.FlexColumnWidth(0.8), // HSN
          5: pw.FlexColumnWidth(1), // Meter
          6: pw.FlexColumnWidth(0.8), // Rate
          7: pw.FlexColumnWidth(1.2), // Amount
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
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
            return pw.TableRow(
              children: [
                _buildTableCell('${index + 1}'),
                _buildTableCell('${index + 1}'),
                _buildTableCell(item.description),
                _buildTableCell('${item.taka.toInt()}'),
                _buildTableCell(item.hsnCode),
                _buildTableCell('${item.meter.toInt()}'),
                _buildTableCell('${item.rate.toInt()}'),
                _buildTableCell(item.amount.toStringAsFixed(0)),
              ],
            );
          }),
          // Empty rows for spacing (minimum 3 rows total)
          ...List.generate(
            (3 - items.length).clamp(0, 3),
            (index) => pw.TableRow(
              children: List.generate(8, (i) => _buildTableCell('', height: 30)),
            ),
          ),
          // Subtotal row
          pw.TableRow(
            children: [
              _buildTableCell(''),
              _buildTableCell(''),
              _buildTableCell('Subtotal', isHeader: true),
              _buildTableCell(''),
              _buildTableCell(''),
              _buildTableCell(_getTotalMeter(items).toString()),
              _buildTableCell(''),
              _buildTableCell(
                _getSubtotal(items).toStringAsFixed(0),
                isHeader: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build totals and bank details section
  static pw.Widget _buildTotalsAndBankDetails(Invoice invoice, Company company) {
    final subtotal = _getSubtotal(invoice.items);
    final discount = invoice.discount;
    final otherLess = invoice.otherDeductions;
    final freight = invoice.freight;
    final taxableValue = subtotal - discount - otherLess + freight;
    final igst = taxableValue * 0.025; // 2.5%
    final sgst = taxableValue * 0.025; // 2.5%
    final cgst = taxableValue * 0.025; // 2.5%
    final netAmount = taxableValue + igst + sgst + cgst;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - Bank details and amount in words
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Bank: HDFC BANK',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Branch: Nanpura',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'A/C: 50500000000000.0',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'IFSC: HDFC0001026',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Remark: ${invoice.notes.isNotEmpty ? invoice.notes : 'Lore ipsum text'}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Text(
                    invoice.amountInWords.isNotEmpty 
                        ? invoice.amountInWords.toUpperCase()
                        : 'FIFTY THOUSAND FOUR HUNDRED FOUR ONLY',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          // Right side - Calculations
          pw.Expanded(
            flex: 2,
            child: pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1),
              },
              children: [
                _buildCalculationRow('Discount (7%)', '-${discount.toStringAsFixed(0)}'),
                _buildCalculationRow('Oth Less', '-${otherLess.toStringAsFixed(0)}'),
                _buildCalculationRow('Freight', '+${freight.toStringAsFixed(2)}'),
                _buildCalculationRow('Taxable Value', taxableValue.toStringAsFixed(2)),
                _buildCalculationRow('I GST (2.5%)', '+${igst.toStringAsFixed(2)}'),
                _buildCalculationRow('S GST (2.5%)', '+${sgst.toStringAsFixed(2)}'),
                _buildCalculationRow('C GST (2.5%)', '+${cgst.toStringAsFixed(2)}'),
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableCell('Net Amount', isHeader: true),
                    _buildTableCell(
                      netAmount.toStringAsFixed(2),
                      isHeader: true,
                      fontSize: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build terms and signature section
  static pw.Widget _buildTermsAndSignature(Company company) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.black)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Terms and Conditions:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '1) Complaint, if any, regarding this Invoice must be settled immediately.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '2) Goods once sold will not be taken back or exchanged.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '3) Goods are dispatched to the account and risk of the buyer.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '4) Interest @2% per month will be charged on the amount remaining unpaid from the due date.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '5) Subject to SURAT Jurisdiction.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          // Signature section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'FOR YOUR COMPANY',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Container(
                    width: 120,
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'S.D.Lathiya',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Container(
                          height: 1,
                          width: double.infinity,
                          color: PdfColors.black,
                        ),
                        pw.Text(
                          'Auth Sign.',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  static pw.TableRow _buildCalculationRow(String label, String value) {
    return pw.TableRow(
      children: [
        _buildTableCell(label),
        _buildTableCell(value, textAlign: pw.TextAlign.right),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    double? height,
    pw.TextAlign? textAlign,
    double? fontSize,
  }) {
    return pw.Container(
      height: height ?? 30,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: fontSize ?? (isHeader ? 11 : 10),
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textAlign: textAlign ?? pw.TextAlign.center,
          maxLines: 2,
        ),
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