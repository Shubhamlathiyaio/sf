import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/company.dart';

final bm = BorderMaster();
final lm = LineMaster();

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
    final fontData = await rootBundle.load(
      "assets/fonts/opensans/OpenSans-Regular.ttf",
    );
    final boldFontData = await rootBundle.load(
      "assets/fonts/opensans/OpenSans-Bold.ttf",
    );
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf, bold: boldTtf),
        margin: const pw.EdgeInsets.all(12),
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
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildHeader(company),
        _buildInvoiceTitle('INVOICE'),
        _buildInvoiceInfo(invoice, customer, company),
        _buildInvoiceTitle('BILLING DETAILS'),
        _buildBillingDetails(customer),
        pw.SizedBox(height: 10),
        _buildItemsTable(invoice.items),
        _buildTotalsAndBankDetails(invoice, company),
        pw.Expanded(child: pw.SizedBox()),
        _buildTermsAndSignature(company),
      ],
    );
  }

  /// Build the header section
  static pw.Widget _buildHeader(Company company) {
    return pw.Container(
      decoration: bm.circularBorderAll,
      child: pw.Column(
        children: [
          pw.Container(
            margin: pw.EdgeInsets.all(2),
            color: PdfColors.grey100,
            padding: const pw.EdgeInsets.only(
              top: 3,
              left: 10,
              right: 10,
              bottom: 3,
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '|| Shree Ganeshay Namah ||',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.Text(
                  '|| Jay Yogeshwar ||',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          // Main header content
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
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
                    pw.Text(
                      company.companyName,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    // Company name and address
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // Right side: Contact number
                    pw.Text(
                      company.mobileNumber,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      company.address,
                      style: const pw.TextStyle(fontSize: 9),
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

  /// Build the invoice title
  static pw.Widget _buildInvoiceTitle(String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Text(
          label,
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
      decoration: bm.circularBorderAll,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - GST Info
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildRichText(
                    'GST No: ',
                    company.gstNumber,
                    valueColor: PdfColors.red,
                  ),
                  pw.SizedBox(height: 5),
                  _buildRichText(
                    'State Code: ',
                    company.stateCode,
                    valueColor: PdfColors.red,
                  ),
                ],
              ),
            ),
          ),
          lm.verticalLine(45),
          // Right side - Bill Info
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoTableRow(
                        'Bill No: ',
                        invoice.invoiceNumber,
                        valueColor: PdfColors.red,
                        valueFontSize: 14,
                      ),
                      _buildInfoTableRow(
                        'Date: ',
                        _formatDate(invoice.invoiceDate),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 50),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoTableRow(
                        'Due Date: ',
                        _formatDate(invoice.dueDate),
                      ),
                      pw.SizedBox(height: 1),
                      _buildInfoTableRow(
                        'Due Days: ',
                        '${invoice.dueDays} Days',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build billing details section
  static pw.Widget _buildBillingDetails(Customer customer) {
    return pw.Container(
      decoration: bm.circularBorderAll,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Details Table
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 7,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                    child: _buildRichText('M/S: ', customer.firmName),
                  ),
                ),
                lm.verticalLine(30),
                pw.Expanded(
                  flex: 4,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                    child: _buildRichText('GST No: ', customer.gstNumber),
                  ),
                ),
                lm.verticalLine(30),
                pw.Expanded(
                  flex: 3,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                    child: _buildRichText('Mo: ', customer.mobileNumber),
                  ),
                ),
              ],
            ),
          ),
          lm.horizontalLine(),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildRichText('Ofc Address: ', customer.firmAddress),
                _buildRichText('Delivery Address: ', customer.deliveryAddress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<InvoiceItem> items) {
    final tableHeaders = [
      'Sr',
      'Chalan',
      'Description',
      'Taka',
      'HSN',
      'Meter',
      'Rate',
      'Amount',
    ];

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: pw.BorderRadius.only(
          topLeft: pw.Radius.circular(5),
          topRight: pw.Radius.circular(5),
        ),
      ),
      child: pw.ClipRRect(
        horizontalRadius: bm.radius,
        verticalRadius: bm.radius,
        child: pw.Table(
          border: pw.TableBorder.symmetric(
            inside: const pw.BorderSide(color: PdfColors.black, width: 1),
          ),
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
              children: tableHeaders
                  .map(
                    (header) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 5,
                      ),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Item rows
            ...items.asMap().entries.map((entry) {
              final item = entry.value;

              // Split description into lines
              final descriptionLines = item.description.split('\n');

              return pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  _buildFlexibleTableCell('${item.srNo}'),
                  _buildFlexibleTableCell(item.chalanNo),
                  // Multi-line description with flexible height
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisSize: pw.MainAxisSize.min,
                      children: descriptionLines
                          .map(
                            (line) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 2),
                              child: pw.Text(
                                line.trim(),
                                style: const pw.TextStyle(fontSize: 9),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildFlexibleTableCell('${item.taka.toInt()}'),
                  _buildFlexibleTableCell(item.hsnCode),
                  _buildFlexibleTableCell(
                    item.meter.toStringAsFixed(
                      item.meter.truncateToDouble() == item.meter ? 0 : 2,
                    ),
                  ),
                  _buildFlexibleTableCell(
                    item.rate.toStringAsFixed(
                      item.rate.truncateToDouble() == item.rate ? 0 : 2,
                    ),
                  ),
                  _buildFlexibleTableCell(
                    item.amount.toStringAsFixed(0),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              );
            }),
            // Subtotal row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 15),

                  decoration: pw.BoxDecoration(border: bm.allSides),
                ),
                _buildFlexibleTableCell(''),
                _buildFlexibleTableCell(
                  'Subtotal',
                  textAlign: pw.TextAlign.left,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                _buildFlexibleTableCell(''),
                _buildFlexibleTableCell(''),
                _buildFlexibleTableCell(
                  _getTotalMeter(items).toString(),
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                _buildFlexibleTableCell(''),

                pw.Container(
                  decoration: pw.BoxDecoration(border: bm.allSides),
                  child: _buildFlexibleTableCell(
                    _getSubtotal(items).toStringAsFixed(0),
                    textAlign: pw.TextAlign.right,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Add this new helper method for flexible table cells
  static pw.Widget _buildFlexibleTableCell(
    String text, {
    pw.TextAlign? textAlign,
    double? fontSize,
    pw.FontWeight? fontWeight,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize ?? 9,
          fontWeight: fontWeight ?? pw.FontWeight.normal,
        ),
        textAlign: textAlign ?? pw.TextAlign.center,
      ),
    );
  }

  /// Build totals and bank details section
  static pw.Widget _buildTotalsAndBankDetails(
    Invoice invoice,
    Company company,
  ) {
    return pw.Container(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left side - Bank details and amount in words
          pw.Expanded(
            child: pw.Container(
              height: 164, //Limited height

              decoration: pw.BoxDecoration(
                border: bm.allSides,
                borderRadius: bm.onlyBottomLeftRadius,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,

                children: [
                  _buildBankDetails(company),

                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                    height: 25,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(border: bm.horizontal),
                    child: pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: _buildRichText('Remark: ', invoice.notes),
                      ),
                    ),
                  ),

                  pw.Container(
                    alignment: pw.Alignment.centerLeft,
                    height: 25,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      border: bm.allSides,
                      borderRadius: bm.onlyBottomLeftRadius,
                      color: PdfColor.fromHex('#F2F2F2'),
                    ),
                    child: pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                        child: pw.Text(
                          invoice.amountInWords.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - Calculations
          pw.Expanded(child: _buildCalculationDetails(invoice)),
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
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...terms.map(
                  (term) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 1),
                    child: pw.Text(
                      term,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ),
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
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'S.D.Lathiya',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Divider(color: PdfColors.black, thickness: 1, height: 1),
                pw.Text(
                  'Auth Sign.',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static pw.Widget _buildInfoTableRow(
    String label,
    String value, {
    PdfColor? valueColor,
    double? valueFontSize,
  }) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          textAlign: pw.TextAlign.left,
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
            fontSize: valueFontSize ?? 10,
          ),
          textAlign: pw.TextAlign.left,
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
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildRichText('Bank: ', company.bankName),
          pw.SizedBox(height: 6),
          _buildRichText('Branch: ', company.branchName),
          pw.SizedBox(height: 6),
          _buildRichText('A/C: ', company.accountNumber),
          pw.SizedBox(height: 6),
          _buildRichText('IFSC: ', company.ifscCode),
        ],
      ),
    );
  }

  static pw.Widget _buildCalculationDetails(Invoice invoice) {
    return pw.Container(
      height: 164, //Limited height
      decoration: pw.BoxDecoration(
        border: bm.allSides,
        borderRadius: bm.onlyBottomRightRadius,
      ),
      child: pw.Column(
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 20, right: 10),
            child: pw.Column(
              children: [
                _buildCalculationRow(
                  'Discount (7%)',
                  '-${invoice.discount.toStringAsFixed(0)}',
                ),
                _buildCalculationRow(
                  'Oth Less',
                  '-${invoice.otherDeductions.toStringAsFixed(0)}',
                ),
                _buildCalculationRow(
                  'Freight',
                  '+${invoice.freight.toStringAsFixed(2)}',
                ),
                _buildCalculationRow(
                  'Taxable Value',
                  invoice.taxableValue.toStringAsFixed(2),
                ),
                _buildCalculationRow(
                  'I GST (2.5%)',
                  '+${invoice.igstAmount.toStringAsFixed(2)}',
                ),
                _buildCalculationRow(
                  'S GST (2.5%)',
                  '+${invoice.sgstAmount.toStringAsFixed(2)}',
                ),
                _buildCalculationRow(
                  'C GST (2.5%)',
                  '+${invoice.cgstAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Container(
            padding: const pw.EdgeInsets.only(left: 20, right: 10),
            height: 25,
            decoration: pw.BoxDecoration(
              borderRadius: bm.onlyBottomRightRadius,
              color: PdfColor.fromHex('#F2F2F2'),
              border: bm.allSides,
            ),
            child: _buildCalculationRow(
              'Net Amount',
              invoice.netAmount.toStringAsFixed(2),
              isHeader: true,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Row _buildCalculationRow(
    String label,
    String value, {
    bool isHeader = false,
  }) {
    return pw.Row(
      // decoration: isHeader
      //     ? const pw.BoxDecoration(color: PdfColors.grey200)
      //     : null,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
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
          fontWeight:
              fontWeight ??
              (isHeader ? pw.FontWeight.bold : pw.FontWeight.normal),
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

    await Share.shareXFiles([XFile(file.path)], text: 'Invoice: $fileName');
  }

  /// Open PDF with system default app
  static Future<void> openPDF(Uint8List pdfBytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Invoice: $fileName');
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

// This is the border master class this help me to quickly set the border with width, radius, color, topOnly, bottomOnly, leftOnly, rightOnly, horizontal, vertical, allSides and also onlys for the radius ex[topLeft, bottomRight etc ]
class BorderMaster {
  final double width;
  final double radius;
  final PdfColor color;

  BorderMaster({
    this.width = 1.5,
    this.radius = 5,
    this.color = PdfColors.black,
  });

  // Now I think we have to update the border styles with using the radius and width and color
  pw.BoxDecoration get circularBorderAll {
    return pw.BoxDecoration(
      border: pw.Border.all(color: color, width: width),
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(radius)),
    );
  }

  // border Top
  pw.BoxDecoration get circularBorderTopOnly {
    return pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(color: color, width: width),
      ),
      borderRadius: BorderMaster().topRadius,
    );
  }

  // border Bottom
  pw.BoxDecoration get circularBorderBottomOnly {
    return pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: color, width: width),
      ),
      borderRadius: BorderMaster().bottomRadius,
    );
  }

  // border Left
  pw.BoxDecoration get circularBorderLeftOnly {
    return pw.BoxDecoration(
      border: pw.Border(
        left: pw.BorderSide(color: color, width: width),
      ),
      borderRadius: BorderMaster().leftRadius,
    );
  }

  // border Right
  pw.BoxDecoration get circularBorderRightOnly {
    return pw.BoxDecoration(
      border: pw.Border(
        right: pw.BorderSide(color: color, width: width),
      ),
      borderRadius: BorderMaster().rightRadius,
    );
  }

  // border Horizontal
  pw.BoxDecoration get circularBorderHorizontal {
    return pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(color: color, width: width),
        bottom: pw.BorderSide(color: color, width: width),
      ),
      borderRadius: BorderMaster().allRadius,
    );
  }

  // border Vertical
  pw.BoxDecoration get circularBorderVertical {
    return pw.BoxDecoration(
      border: pw.Border(
        left: pw.BorderSide(color: color, width: width),
        right: pw.BorderSide(color: color, width: width),
      ),
      borderRadius: BorderMaster().allRadius,
    );
  }

  // Here are the fixd radius onlys

  pw.BorderRadius get onlyTopLeftRadius {
    return pw.BorderRadius.only(topLeft: pw.Radius.circular(radius));
  }

  pw.BorderRadius get onlyTopRightRadius {
    return pw.BorderRadius.only(topRight: pw.Radius.circular(radius));
  }

  pw.BorderRadius get onlyBottomLeftRadius {
    return pw.BorderRadius.only(bottomLeft: pw.Radius.circular(radius));
  }

  pw.BorderRadius get onlyBottomRightRadius {
    return pw.BorderRadius.only(bottomRight: pw.Radius.circular(radius));
  }

  pw.BorderRadius get topRadius {
    return pw.BorderRadius.only(
      topLeft: pw.Radius.circular(5),
      topRight: pw.Radius.circular(5),
    );
  }

  pw.BorderRadius get bottomRadius {
    return pw.BorderRadius.only(
      bottomLeft: pw.Radius.circular(radius),
      bottomRight: pw.Radius.circular(radius),
    );
  }

  pw.BorderRadius get leftRadius {
    return pw.BorderRadius.only(
      topLeft: pw.Radius.circular(radius),
      bottomLeft: pw.Radius.circular(radius),
    );
  }

  pw.BorderRadius get rightRadius {
    return pw.BorderRadius.only(
      topRight: pw.Radius.circular(radius),
      bottomRight: pw.Radius.circular(radius),
    );
  }

  pw.BorderRadius get allRadius {
    return pw.BorderRadius.all(pw.Radius.circular(radius));
  }

  // Here are the normal borders without radius

  pw.Border get allSides {
    return pw.Border.all(color: color, width: width);
  }

  pw.Border get topOnly {
    return pw.Border(
      top: pw.BorderSide(color: color, width: width),
    );
  }

  pw.Border get bottomOnly {
    return pw.Border(
      bottom: pw.BorderSide(color: color, width: width),
    );
  }

  pw.Border get leftOnly {
    return pw.Border(
      left: pw.BorderSide(color: color, width: width),
    );
  }

  pw.Border get rightOnly {
    return pw.Border(
      right: pw.BorderSide(color: color, width: width),
    );
  }

  pw.Border get horizontal {
    return pw.Border(
      top: pw.BorderSide(color: color, width: width),
      bottom: pw.BorderSide(color: color, width: width),
    );
  }

  pw.Border get vertical {
    return pw.Border(
      left: pw.BorderSide(color: color, width: width),
      right: pw.BorderSide(color: color, width: width),
    );
  }
}

// This class give me the lines horizontal and vertical with the custom thickness and color
class LineMaster {
  final double thickness;
  final PdfColor color;

  LineMaster({this.thickness = 1, this.color = PdfColors.black});

  pw.Widget horizontalLine() {
    return pw.Container(
      width: double.infinity,
      height: thickness,
      color: color,
    );
  }

  pw.Widget verticalLine(double height) {
    return pw.Container(width: thickness, height: height, color: color);
  }
}
