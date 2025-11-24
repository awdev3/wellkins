import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class PdfWidgets {
  static pw.SizedBox sb30 = pw.SizedBox(height: 30);
  static pw.SizedBox sb20 = pw.SizedBox(height: 20);
  static pw.SizedBox sb15 = pw.SizedBox(height: 15);
  static pw.SizedBox sb10 = pw.SizedBox(height: 10);
  static pw.SizedBox sb6 = pw.SizedBox(height: 6);
  static pw.SizedBox sb5 = pw.SizedBox(height: 5);
  static pw.SizedBox sbw10 = pw.SizedBox(width: 10);

  static pw.Spacer spcr = pw.Spacer();

  static const List<String> _futures = [
    'assets/fonts/PdfIcons.ttf',
    'assets/fonts/Spectral-Bold.ttf',
    'assets/fonts/Spectral-SemiBold.ttf',
    'assets/fonts/Spectral-Regular.ttf',
    'assets/fonts/Spectral-Italic.ttf',
    'assets/images/logo-pdf.png',
  ];

  static Future<Map<String, dynamic>> loadAssets() async {
    final results = await Future.wait(_futures.map((e) => _loadAssetFile(e)));

    return {
      'icons': results[0],
      'bold': results[1],
      'semiBold': results[2],
      'regular': results[3],
      'italic': results[4],
      'logo': results[5],
    };
  }

  static Future<dynamic> _loadAssetFile(String path) async {
    final isImg = path.endsWith('.png');
    final data = await rootBundle.load(path);
    return isImg
        ? pw.MemoryImage(data.buffer.asUint8List())
        : pw.Font.ttf(data.buffer.asByteData());
  }

  static pw.Widget pdfHFDivider({bool header = false}) {
    pw.Widget sp() => pw.Expanded(child: sb6);

    pw.Widget divLine([double height = 4, PdfColor? color]) {
      final container = pw.Container(
        height: height,
        decoration: pw.BoxDecoration(
          color: color ?? PdfColors.red,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        ),
      );

      return color == null ? pw.Expanded(child: container) : container;
    }

    return pw.SizedBox(
      width: double.infinity,
      child: pw.Stack(
        alignment: header ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
        children: [
          divLine(3, PdfColors.black),
          pw.Row(
            children: [
              if (header) ...[divLine(), sp()] else ...[sp(), divLine()],
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget divider = pw.Divider(
    indent: 40,
    endIndent: 40,
    thickness: .5,
  );

  static pw.Widget verDivider(double height) => pw.SizedBox(
    height: height,
    child: pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
      child: pw.VerticalDivider(thickness: 1, color: PdfColors.black),
    ),
  );
}
