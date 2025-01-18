import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGeneratorPage extends StatelessWidget {
  final String name;
  final String bloodGroup;
  final String aadhar;
  final String mobile;
  final String address;

  const PdfGeneratorPage({
    super.key,
    required this.name,
    required this.bloodGroup,
    required this.aadhar,
    required this.mobile,
    required this.address,
  });

  Future<void> generateAndSharePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Container(
              color: PdfColor.fromHex('#FFA500'),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'புனித ஊர்து மாதா ஜில்லிக்கட்டு பேரவை 2025\nமாதா கோட்டை, தஞ்சாவூர்\nநாள்: 01-பிப்ரவரி-2025 சனிக்கிழமை நேரம்: காலை 7 மணி',
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'மாடுபிடி வீரர்களுக்கான அடையாள அட்டை',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              '-053-',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Name: $name',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Blood Group: $bloodGroup',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Aadhar: $aadhar',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Mobile: $mobile',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Address: $address',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.Container(
                  width: 60,
                  height: 80,
                  color: PdfColor.fromHex('#FFA500'),
                  child: pw.Center(
                      child: pw.Text('Photo',
                          style: const pw.TextStyle(fontSize: 10))),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              width: 60,
              height: 60,
              color: PdfColor.fromHex('#FFA500'),
              child: pw.Center(
                  child:
                      pw.Text('QR', style: const pw.TextStyle(fontSize: 10))),
            ),
          ],
        ),
      ),
    );

    try {
      final directory = await getTemporaryDirectory();
      final file = File("${directory.path}/identity_card.pdf");
      await file.writeAsBytes(await pdf.save());

      // // Share via WhatsApp
      // FlutterShareMe().shareToWhatsApp(
      //     imagePath: file.path, msg: "Here is your identity card PDF.");
    } catch (e) {
      print("Error generating PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Generator")),
      body: Center(
        child: ElevatedButton(
          onPressed: generateAndSharePdf,
          child: const Text("Generate & Share PDF"),
        ),
      ),
    );
  }
}
