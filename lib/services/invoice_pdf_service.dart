import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/company.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import 'dart:ui';

class InvoicePDFService {
  /// Generate PDF for invoice using Syncfusion PDF library
  static Future<Uint8List> generateInvoicePDF({
    required Invoice invoice,
    required Customer customer,
    required Company company,
  }) async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();
    // Add a page to the document.
    final PdfPage page = document.pages.add();

    // Get page client size
    final Size pageSize = page.getClientSize();

    // Create a PDF template for the header
    final PdfTemplate headerTemplate = _buildHeader(company, pageSize);
    page.template.top = headerTemplate;

    // Build the invoice title
    _buildInvoiceTitle(page, pageSize);

    // Build the invoice info section
    _buildInvoiceInfo(page, pageSize, invoice, customer, company);

    // Build the billing details section
    _buildBillingDetails(page, pageSize, customer);

    // Build the items table
    final PdfLayoutResult? tableResult = _buildItemsTable(page, pageSize, invoice.items);

    // Build the totals and bank details section
    if (tableResult != null) {
      _buildTotalsAndBankDetails(page, pageSize, invoice, company, tableResult);
    }

    // Build the terms and signature section
    _buildTermsAndSignature(page, pageSize, company);

    // Save the document.
    final List<int> bytes = await document.save();
    // Dispose the document.
    document.dispose();

    return Uint8List.fromList(bytes);
  }

  /// Build the header section
  static PdfTemplate _buildHeader(Company company, Size pageSize) {
    final PdfTemplate headerTemplate = PdfTemplate(pageSize.width, 90);
    final PdfGraphics g = headerTemplate.graphics;

    // Fonts
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    final PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final PdfFont largeBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final PdfFont contactFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);

    // Top religious texts
    g.drawString('|| Shree Ganeshay Namah ||', boldFont,
        bounds: Rect.fromLTWH(0, 0, pageSize.width, 12),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));
    g.drawString('|| Jay Yogeshwar ||', boldFont,
        bounds: Rect.fromLTWH(0, 0, pageSize.width, 12),
        format: PdfStringFormat(alignment: PdfTextAlignment.right));

    // Logo
    g.drawRectangle(
        brush: PdfSolidBrush(PdfColor(234, 84, 35)), // Deep Orange
        bounds: const Rect.fromLTWH(0, 20, 48, 48));
    g.drawString('SF', PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold),
        brush: PdfBrushes.white,
        bounds: const Rect.fromLTWH(0, 20, 48, 48),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    // Company name and address
    g.drawString(company.companyName, largeBoldFont,
        bounds: const Rect.fromLTWH(60, 22, 300, 30));
    g.drawString(company.address, regularFont,
        bounds: const Rect.fromLTWH(60, 55, 300, 20));

    // Contact number
    final Size contactNumberSize = contactFont.measureString(company.mobileNumber);
    final Rect contactNumberBounds = Rect.fromLTWH(
        pageSize.width - contactNumberSize.width - 24, 35, contactNumberSize.width + 12, contactNumberSize.height + 4);
    g.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0), width: 1.5),
        bounds: contactNumberBounds);
    g.drawString(company.mobileNumber, contactFont,
        brush: PdfBrushes.black,
        bounds: contactNumberBounds,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    // Bottom border
    g.drawLine(PdfPens.black, Offset(0, 85), Offset(pageSize.width, 85));

    return headerTemplate;
  }

  /// Build the invoice title
  static void _buildInvoiceTitle(PdfPage page, Size pageSize) {
    final PdfGraphics g = page.graphics;
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);

    g.drawString(
      'INVOICE',
      titleFont,
      bounds: Rect.fromLTWH(0, 95, pageSize.width, 20),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
    g.drawLine(PdfPens.black, Offset(0, 120), Offset(pageSize.width, 120));
  }

  /// Build invoice information section
  static void _buildInvoiceInfo(
    PdfPage page,
    Size pageSize,
    Invoice invoice,
    Customer customer,
    Company company,
  ) {
    final PdfGraphics g = page.graphics;
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    final PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfBrush redBrush = PdfSolidBrush(PdfColor(255, 0, 0));

    // GST Info Box
    final Rect gstBoxBounds = Rect.fromLTWH(0, 130, pageSize.width * 0.45, 60);
    g.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0)), bounds: gstBoxBounds);

    _drawRichText(
        g, 'GST No: ', company.gstNumber, boldFont, regularFont, redBrush,
        Rect.fromLTWH(10, 140, 200, 20));
    _drawRichText(
        g, 'State Code: ', company.stateCode, boldFont, regularFont, redBrush,
        Rect.fromLTWH(10, 160, 200, 20));


    // Bill Info
    final double billInfoX = pageSize.width * 0.5;
    _drawInfoTableRow(g, 'Bill No:', invoice.invoiceNumber, boldFont, regularFont, billInfoX, 130, valueBrush: redBrush, valueFontSize: 14);
    _drawInfoTableRow(g, 'Date:', _formatDate(invoice.invoiceDate), boldFont, regularFont, billInfoX, 150);
    _drawInfoTableRow(g, 'Due Date:', _formatDate(invoice.dueDate), boldFont, regularFont, billInfoX, 170);
    _drawInfoTableRow(g, 'Due Days:', '${invoice.dueDays} Days', boldFont, regularFont, billInfoX, 190);
  }

  /// Build billing details section
  static void _buildBillingDetails(
    PdfPage page,
    Size pageSize,
    Customer customer,
  ) {
    final PdfGraphics g = page.graphics;
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

    // Title
    final Rect titleBounds = Rect.fromLTWH(0, 200, pageSize.width, 20);
    g.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0)), bounds: titleBounds);
    g.drawString('BILLING DETAILS', boldFont,
        bounds: titleBounds,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    // Details Table
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);
    grid.columns[0].width = pageSize.width * 0.4;
    grid.columns[1].width = pageSize.width * 0.35;
    grid.columns[2].width = pageSize.width * 0.25;

    final PdfGridRow row1 = grid.rows.add();
    row1.cells[0].value = 'M/S: ${customer.firmName}';
    row1.cells[1].value = 'GST No: ${customer.gstNumber}';
    row1.cells[2].value = 'Mo: ${customer.mobileNumber}';

    final PdfGridRow row2 = grid.rows.add();
    row2.cells[0].value = 'Ofc Address: ${customer.firmAddress}';
    row2.cells[0].columnSpan = 3;

    final PdfGridRow row3 = grid.rows.add();
    row3.cells[0].value = 'Delivery Address: ${customer.deliveryAddress}';
    row3.cells[0].columnSpan = 3;

    // Style the grid
    grid.style.font = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
    grid.style.cellPadding = PdfPaddings(left: 6, right: 2, top: 4, bottom: 4);

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 220, pageSize.width, 100),
    );
  }

  /// Build items table
  static PdfLayoutResult? _buildItemsTable(
    PdfPage page,
    Size pageSize,
    List<InvoiceItem> items,
  ) {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 8);
    grid.columns[0].width = 30; // Sr
    grid.columns[1].width = 40; // Chalan
    grid.columns[2].width = 180; // Description
    grid.columns[3].width = 40; // Taka
    grid.columns[4].width = 60; // HSN
    grid.columns[5].width = 70; // Meter
    grid.columns[6].width = 50; // Rate
    grid.columns[7].width = 80; // Amount

    final PdfGridRow header = grid.headers.add(1)[0];
    final List<String> headerTitles = [
      'Sr', 'Chalan', 'Description', 'Taka', 'HSN', 'Meter', 'Rate', 'Amount'
    ];
    for (int i = 0; i < headerTitles.length; i++) {
      header.cells[i].value = headerTitles[i];
      header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
      header.cells[i].stringFormat.alignment = PdfTextAlignment.center;
    }
    header.style.backgroundBrush = PdfBrushes.lightGray;

    // Add rows
    for (final item in items) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = item.srNo.toString();
      row.cells[1].value = item.chalanNo;
      row.cells[2].value = item.description;
      row.cells[3].value = item.taka.toInt().toString();
      row.cells[4].value = item.hsnCode;
      row.cells[5].value = item.meter.toStringAsFixed(item.meter.truncateToDouble() == item.meter ? 0 : 2);
      row.cells[6].value = item.rate.toStringAsFixed(item.rate.truncateToDouble() == item.rate ? 0 : 2);
      row.cells[7].value = item.amount.toStringAsFixed(0);
    }

    // Style the grid
    grid.style.cellPadding = PdfPaddings(left: 4, right: 4, top: 5, bottom: 5);
    grid.style.font = PdfStandardFont(PdfFontFamily.helvetica, 9);
    grid.style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center);
    grid.columns[2].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left); // Description
    grid.columns[7].style.stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right); // Amount

    // Subtotal row
    final PdfGridRow subtotalRow = grid.rows.add();
    subtotalRow.cells[2].value = 'Subtotal';
    subtotalRow.cells[2].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    subtotalRow.cells[2].stringFormat.alignment = PdfTextAlignment.right;

    subtotalRow.cells[5].value = items.fold(0.0, (sum, item) => sum + item.meter).toString();
    subtotalRow.cells[5].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

    subtotalRow.cells[7].value = items.fold(0.0, (sum, item) => sum + item.amount).toStringAsFixed(0);
    subtotalRow.cells[7].style.font = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);


    return grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 280, pageSize.width, pageSize.height - 380),
      format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
    );
  }

  /// Build totals and bank details section
  static void _buildTotalsAndBankDetails(
    PdfPage page,
    Size pageSize,
    Invoice invoice,
    Company company,
    PdfLayoutResult tableResult,
  ) {
    final PdfGraphics g = page.graphics;
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    final PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final double y = tableResult.bounds.bottom + 10;

    // Bank Details
    g.drawString('Bank: ${company.bankName}', boldFont, bounds: Rect.fromLTWH(0, y, 200, 20));
    g.drawString('Branch: ${company.branchName}', boldFont, bounds: Rect.fromLTWH(0, y + 15, 200, 20));
    g.drawString('A/C: ${company.accountNumber}', boldFont, bounds: Rect.fromLTWH(0, y + 30, 200, 20));
    g.drawString('IFSC: ${company.ifscCode}', boldFont, bounds: Rect.fromLTWH(0, y + 45, 200, 20));

    // Remark
    g.drawString('Remark: ${invoice.notes}', boldFont, bounds: Rect.fromLTWH(0, y + 70, 250, 20));

    // Amount in words
    g.drawString(invoice.amountInWords.toUpperCase(), boldFont,
        bounds: Rect.fromLTWH(0, y + 90, 250, 20));


    // Calculation Details
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.columns[0].width = 120;
    grid.columns[1].width = 80;

    final List<List<String>> rows = [
      ['Discount (7%)', '-${invoice.discount.toStringAsFixed(0)}'],
      ['Oth Less', '-${invoice.otherDeductions.toStringAsFixed(0)}'],
      ['Freight', '+${invoice.freight.toStringAsFixed(2)}'],
      ['Taxable Value', invoice.taxableValue.toStringAsFixed(2)],
      ['I GST (2.5%)', '+${invoice.igstAmount.toStringAsFixed(2)}'],
      ['S GST (2.5%)', '+${invoice.sgstAmount.toStringAsFixed(2)}'],
      ['C GST (2.5%)', '+${invoice.cgstAmount.toStringAsFixed(2)}'],
      ['Net Amount', invoice.netAmount.toStringAsFixed(2)],
    ];

    for (int i = 0; i < rows.length; i++) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = rows[i][0];
      row.cells[1].value = rows[i][1];
      row.cells[0].style.font = boldFont;
      row.cells[1].style.font = boldFont;
      row.cells[1].stringFormat.alignment = PdfTextAlignment.right;
      if (rows[i][0] == 'Net Amount') {
        row.style.backgroundBrush = PdfBrushes.lightGray;
        row.cells[1].style.font = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
      }
    }

    grid.style.cellPadding = PdfPaddings(left: 6, right: 6, top: 3, bottom: 3);
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(pageSize.width - 200, y, 200, 200),
    );
  }

  /// Build terms and signature section
  static void _buildTermsAndSignature(
    PdfPage page,
    Size pageSize,
    Company company,
  ) {
    final PdfGraphics g = page.graphics;
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
    final PdfFont regularFont = PdfStandardFont(PdfFontFamily.helvetica, 8);
    final double y = pageSize.height - 100;

    g.drawLine(PdfPens.black, Offset(0, y - 5), Offset(pageSize.width, y - 5));

    // Terms and Conditions
    g.drawString('Terms and Conditions:', boldFont,
        bounds: Rect.fromLTWH(0, y, 200, 15));
    final List<String> terms = [
      '1) Complaint, if any, regarding this Invoice must be settled immediately.',
      '2) Goods once sold will not be taken back or exchanged.',
      '3) Goods are dispatched to the account and risk of the buyer.',
      '4) Interest @2% per month will be charged on the amount remaining unpaid from the due date.',
      '5) Subject to SURAT Jurisdiction.',
    ];
    for (int i = 0; i < terms.length; i++) {
      g.drawString(terms[i], regularFont,
          bounds: Rect.fromLTWH(0, y + 15 + (i * 12), 300, 12));
    }

    // Signature
    final double signatureX = pageSize.width - 200;
    g.drawString('FOR YOUR COMPANY',
        PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(signatureX, y + 10, 200, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
    g.drawString('S.D.Lathiya',
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(signatureX, y + 60, 200, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
    g.drawLine(PdfPens.black, Offset(signatureX + 20, y + 80), Offset(pageSize.width - 20, y + 80));
    g.drawString('Auth Sign.',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(signatureX, y + 82, 200, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
  }

  /// Format date to dd-MM-yyyy
  static String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Helper to draw rich text
  static void _drawRichText(
    PdfGraphics g,
    String label, String value,
    PdfFont labelFont, PdfFont valueFont, PdfBrush valueBrush,
    Rect bounds,
  ) {
    final PdfTextElement textElement = PdfTextElement(text: label, font: labelFont);
    final PdfLayoutResult result = textElement.draw(
      page: g.page,
      bounds: bounds,
    )!;
    g.drawString(value, valueFont,
        brush: valueBrush,
        bounds: Rect.fromLTWH(result.bounds.right, bounds.top, bounds.width - result.bounds.width, bounds.height));
  }

  /// Helper to draw a row in the info table
  static void _drawInfoTableRow(
      PdfGraphics g,
      String label, String value,
      PdfFont labelFont, PdfFont valueFont,
      double x, double y,
      {PdfBrush? valueBrush, double? valueFontSize}) {
    g.drawString(label, labelFont,
        bounds: Rect.fromLTWH(x, y, 100, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));
    g.drawString(value, valueFontSize != null ? PdfStandardFont(PdfFontFamily.helvetica, valueFontSize, style: PdfFontStyle.bold) : valueFont,
        brush: valueBrush ?? PdfBrushes.black,
        bounds: Rect.fromLTWH(x + 60, y, 150, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.left));
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

  /// Preview PDF by sharing it with available apps
  static Future<void> previewPDF(Uint8List pdfBytes, String title) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$title.pdf');
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice: $title',
    );
  }
}