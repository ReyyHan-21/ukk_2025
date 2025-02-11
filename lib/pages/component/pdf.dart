import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class TransaksiPage extends StatelessWidget {
  final List<Map<String, dynamic>> transaksi;
  final int totalHarga;

  TransaksiPage({required this.transaksi, required this.totalHarga});

  Future<void> generateAndSavePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Detail Transaksi',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Produk yang dibeli:',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              ...transaksi.map((item) => pw.Container(
                    margin: pw.EdgeInsets.only(bottom: 5),
                    child: pw.Text(
                        '${item['NamaProduk']} - Jumlah: ${item['quantity']} | Harga: Rp ${item['Harga']} | Subtotal: Rp ${item['Harga'] * item['quantity']}'),
                  )),
              pw.Divider(),
              pw.Text('Total Belanja: Rp $totalHarga',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/transaksi.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF disimpan di: $filePath');

    // Membuka file setelah disimpan
    await OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk yang dibeli:',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: transaksi.map((item) {
                  return ListTile(
                    title: Text(item['NamaProduk']),
                    subtitle: Text(
                        'Jumlah: \${item['quantity']} | Harga: Rp \${item['Harga']}'),
                    trailing: Text(
                        'Subtotal: Rp \${item['Harga'] * item['quantity']}'),
                  );
                }).toList(),
              ),
            ),
            Divider(),
            Text(
              'Total Belanja: Rp $totalHarga',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generateAndSavePdf,
              child: Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
