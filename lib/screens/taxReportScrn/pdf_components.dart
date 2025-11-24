import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wellkins/models/taxreturn_model.dart';
import 'package:wellkins/screens/engagementScrn/engagement.dart';

import 'pdf_widgets.dart';

class PdfComponents {
  static const String headerText = 'AFSL 482375 \nABN 12 608 424 488';
  static const String titleText =
      'Wellkins Mortgage Fund ARSN 673 559 576\nAnnual Tax Statement for financial year ended 30 June';
  static const String disclaimerText =
      'This Annual Tax Statement is issued for purposes of preparation of an investor\'s tax return. Net Distributions Paid to Investor amount in this statement is included in the investor\'s tax return being distributions from trusts (non-primary). Where a tax file number has not been provided by the investor, tax may be withheld as shown in this statement. You should consult your taxation advisor for any taxation advice or generally in respect to preparation of your annual tax return.';
  static const String footerText =
      'For and on behalf of Wellkins Capital Limited ABN 12608424488 AFSL 482375 as Responsible Entity for the Wellkins Mortgage Fund ARSN 673 559 576';
  static const String cInfo1 = '0291194947\ninfo@wellkins.com.au';
  static const String cInfo2 = 'www.wellkins.com.au';
  static const String cInfo3 =
      '4.01/5, Celebration Drive,\nBella Vista NSW 2153';

  static Future<void> generateAndOpenPdf(
    List<TaxReport> taxReports,
    String year,
    String fileName,
    BuildContext ctx,
  ) async {
    final wooProvider = getWooProvider(ctx);

    final pdf = pw.Document();
    final assets = await PdfWidgets.loadAssets();

    if (taxReports.isEmpty) return;

    for (final taxReport in taxReports) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildPdfContent(assets, taxReport, year),
        ),
      );
    }

    final directory = await getTemporaryDirectory();
    final tempFilePath = '${directory.path}/$fileName';
    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(await pdf.save());
    wooProvider.saveFileToDir(tempFilePath, fileName, isCert: true);
  }

  // static Future<void> generateAndOpenPdf(List<TaxReport> taxReports) async {
  //   final pdf = pw.Document();
  //   final assets = await PdfComponents.loadAssets();
  //   if (taxReports.isEmpty) return;
  //   for (final taxReport in taxReports) {
  //     pdf.addPage(
  //       pw.MultiPage(
  //         pageFormat: PdfPageFormat.a4,
  //         margin: const pw.EdgeInsets.all(32),
  //         header: (context) => _header(assets),
  //         footer: (context) => _footer(assets),
  //         build: (context) => [
  //           PdfComponents.sb15,
  //           // should be placed with the header in multipagae
  //           PdfComponents.pdfHFDivider(header: true),
  //           PdfComponents.sb30,
  //           _buildCenteredTitle(assets, taxReport.orderDate),
  //           PdfComponents.sb20,
  //           _buildInformationTable(assets, taxReport),
  //           PdfComponents.sb20,
  //           _buildDisclaimer(assets),
  //           PdfComponents.sb20,
  //           PdfComponents.divider,
  //           _buildFooterText(assets),
  //           PdfComponents.spcr,
  //           PdfComponents.sb20,
  //           // should be placed with the footer in multipagae
  //           PdfComponents.pdfHFDivider(),
  //           PdfComponents.sb15,
  //         ],
  //       ),
  //     );
  //   }
  //   await PdfComponents.saveAndOpenPdf(pdf);
  // }

  static pw.Widget _buildPdfContent(
    Map<String, dynamic> assets,
    TaxReport taxReport,
    String finYear,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _header(assets),
        PdfWidgets.sb15,
        PdfWidgets.pdfHFDivider(header: true),
        PdfWidgets.sb30,
        _buildCenteredTitle(assets, finYear),
        PdfWidgets.sb20,
        _buildInformationTable(assets, taxReport),
        PdfWidgets.sb20,
        _buildDisclaimer(assets),
        PdfWidgets.sb20,
        PdfWidgets.divider,
        _buildFooterText(assets),
        PdfWidgets.spcr,
        PdfWidgets.sb20,
        PdfWidgets.pdfHFDivider(),
        PdfWidgets.sb15,
        _footer(assets),
      ],
    );
  }

  static pw.Widget _header(Map<String, dynamic> assets) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Image(assets['logo'], width: 110),
        PdfWidgets.spcr,
        _buildText(headerText, assets, fontKey: 'semiBold', size: 12),
      ],
    );
  }

  static pw.Widget _buildCenteredTitle(
    Map<String, dynamic> assets,
    String finYear,
  ) {
    final year = finYear.split('-').last;
    return pw.Center(
      child: _buildText(
        '$titleText $year',
        assets,
        fontKey: 'bold',
        size: 13,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildInformationTable(
    Map<String, dynamic> assets,
    TaxReport order,
  ) {
    final rows = [
      ['Investment Class of Units', order.propertyName],
      ['Investor Number', order.investorNumber],
      ['Order Id', order.orderId],
      ['Investor', order.fullName],
      if (order.address.isNotEmpty) ['Investor Address', order.address],
      ['Date of Investment', order.orderDate],
      ['Amount Invested', order.investingAmount],
      ['Net Distributions Paid to Investor', order.totalReturns],
      ['Tax File Number Held (Yes/No)', order.held],
      ['Tax Withheld', order.withHeld],
    ];

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(0.6),
          2: const pw.FlexColumnWidth(3),
        },
        children:
            rows.map((row) => _buildTableRow(row[0], row[1], assets)).toList(),
      ),
    );
  }

  static pw.TableRow _buildTableRow(
    String label,
    String value,
    Map<String, dynamic> assets,
  ) {
    return pw.TableRow(
      children: [
        _buildTableCell(label, assets, isBold: true),
        _buildTableCell(':', assets),
        _buildTableCell(value, assets),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    Map<String, dynamic> assets, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: _buildText(
        text,
        assets,
        fontKey: isBold ? 'semiBold' : 'regular',
        size: 10,
      ),
    );
  }

  static pw.Widget _buildDisclaimer(Map<String, dynamic> assets) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: _buildText(
        disclaimerText,
        assets,
        fontKey: 'italic',
        size: 10,
        lineSpacing: 2,
        textAlign: pw.TextAlign.justify,
      ),
    );
  }

  static pw.Widget _buildFooterText(Map<String, dynamic> assets) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40),
      child: _buildText(
        footerText,
        assets,
        fontKey: 'semiBold',
        size: 9,
        textAlign: pw.TextAlign.justify,
      ),
    );
  }

  static pw.Widget _footer(Map<String, dynamic> assets) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildIconRow(String.fromCharCode(0xe800), cInfo1, assets),
        PdfWidgets.verDivider(40),
        _buildIconRow(String.fromCharCode(0xe801), cInfo2, assets),
        PdfWidgets.verDivider(40),
        _buildIconRow(String.fromCharCode(0xe833), cInfo3, assets),
      ],
    );
  }

  static pw.Widget _buildIconRow(
      String icon, String text, Map<String, dynamic> assets) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          _buildText(icon, assets,
              fontKey: 'icons', size: 20, color: PdfColors.red),
          PdfWidgets.sbw10,
          _buildText(text, assets, fontKey: 'semiBold', size: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildText(
    String text,
    Map<String, dynamic> assets, {
    String fontKey = 'regular',
    double size = 12,
    PdfColor? color,
    double? lineSpacing,
    pw.TextAlign textAlign = pw.TextAlign.left,
  }) {
    return pw.Text(
      text,
      textAlign: textAlign,
      style: pw.TextStyle(
        font: assets[fontKey],
        fontSize: size,
        color: color,
        lineSpacing: lineSpacing,
      ),
    );
  }
}
