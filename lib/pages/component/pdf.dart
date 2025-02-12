import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

Future<void> generateInvoicePDF(
    BuildContext context,
    String namaPelanggan,
    String tanggalPembelian,
    List<Map<String, dynamic>> transaksi,
    int totalHarga) async {
  final pdf = pw.Document();

  // Image
  final ByteData imageData = await rootBundle.load('assets/coffe.png');
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final pw.MemoryImage logo = pw.MemoryImage(imageBytes);

  // Format tanggal agar hanya menampilkan tanggal, bulan, dan tahun
  final formattedDate =
      DateFormat('dd MMMM yyyy').format(DateTime.parse(tanggalPembelian));

  final formattedTime =
      DateFormat('HH:mm').format(DateTime.parse(tanggalPembelian));

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Invoice Transaksi',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Center(
                child: pw.Image(
              logo,
              width: 120,
              height: 120,
            )),
            pw.SizedBox(height: 10),
            pw.Text(
              'Pelanggan: $namaPelanggan',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Tanggal: $formattedDate',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Jam: $formattedTime',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
            pw.SizedBox(height: 25),
            pw.Text('Produk yang dibeli:'),
            pw.SizedBox(height: 5),
            pw.Divider(),
            ...transaksi.map((item) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${item['NamaProduk']}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Rp ${item['Harga'] * item['quantity']}')
                    ],
                  ),
                  pw.Text('Jumlah: ${item['quantity']} x Rp ${item['Harga']}'),
                  pw.SizedBox(height: 5),
                  pw.Divider(),
                ],
              );
            }).toList(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Belanja: Rp $totalHarga',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
