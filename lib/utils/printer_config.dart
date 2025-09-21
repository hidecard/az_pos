import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../controllers/cart_controller.dart';
import '../models/customer.dart';

enum PrinterSize { mm58, mm80 }

class PrinterConfig {
  final double widthMM;
  final double headerFont;
  final double subHeaderFont;
  final double contentFont;
  final double thankFont;
  final CartController cartController;
  final PrinterSize printerSize;

  PrinterConfig({
    required this.widthMM,
    required this.headerFont,
    required this.subHeaderFont,
    required this.contentFont,
    required this.thankFont,
    required this.cartController,
    required this.printerSize,
  });

  factory PrinterConfig.for58MM({required CartController cartController}) =>
      PrinterConfig(
        widthMM: 58,
        headerFont: 14,
        subHeaderFont: 12,
        contentFont: 10,
        thankFont: 12,
        cartController: cartController,
        printerSize: PrinterSize.mm58,
      );

  factory PrinterConfig.for80MM({required CartController cartController}) =>
      PrinterConfig(
        widthMM: 80,
        headerFont: 18,
        subHeaderFont: 14,
        contentFont: 12,
        thankFont: 14,
        cartController: cartController,
        printerSize: PrinterSize.mm80,
      );

  Future<pw.Document> generateInvoice({required Customer? customer}) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    final items = cartController.cartItems;

    final pageFormat = PdfPageFormat(
      widthMM * PdfPageFormat.mm,
      double.infinity,
      marginAll: 5,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'My Shop',
                style: pw.TextStyle(fontSize: headerFont, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Invoice',
                style: pw.TextStyle(fontSize: subHeaderFont, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Invoice No: ${now.millisecondsSinceEpoch}', style: pw.TextStyle(fontSize: contentFont)),
                    pw.Text('Date: ${formatter.format(now)}', style: pw.TextStyle(fontSize: contentFont)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Customer: ${customer?.name ?? 'Guest'}', style: pw.TextStyle(fontSize: contentFont)),
                    pw.Text('Phone: ${customer?.phone ?? '-'}', style: pw.TextStyle(fontSize: contentFont)),
                  ],
                )
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['Product', 'Qty', 'Price', 'Total'],
              data: items.map((i) => [
                i.product.name,
                i.quantity.toString(),
                i.product.price.toStringAsFixed(2),
                i.total.toStringAsFixed(2)
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: contentFont),
              headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
              cellStyle: pw.TextStyle(fontSize: contentFont),
              cellPadding: pw.EdgeInsets.all(4),
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: ${cartController.totalAmount.value.toStringAsFixed(2)} MMK',
                style: pw.TextStyle(fontSize: contentFont, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Thank you for your purchase!',
                style: pw.TextStyle(fontSize: thankFont, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    return pdf;
  }
}
