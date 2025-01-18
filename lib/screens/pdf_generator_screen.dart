import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class IdCardGenerator extends StatelessWidget {
  final String name;
  final String bloodGroup;
  final String aadhar;
  final String mobile;
  final String address;
  final String base64Image;
  final String qrData;
  final String sequence;
  final String uuid;
  final String dob;

  const IdCardGenerator({
    super.key,
    required this.name,
    required this.sequence,
    required this.uuid,
    required this.dob,
    required this.bloodGroup,
    required this.aadhar,
    required this.mobile,
    required this.address,
    required this.base64Image,
    required this.qrData,
  });

  Future<pw.MemoryImage> base64ToImage(String base64String) async {
    try {
      final cleanBase64 =
          base64String.replaceAll(RegExp(r'data:image/[^;]+;base64,'), '');
      final Uint8List bytes = base64.decode(cleanBase64);
      return pw.MemoryImage(bytes);
    } catch (e) {
      print('Error converting base64 to image: $e');
      throw Exception('Invalid base64 image');
    }
  }

  // Create QR code widget for preview
  Widget buildQrPreview() {
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: 100,
    );
  }

  // Convert QR widget to Uint8List
  Future<Uint8List> generateQrImage() async {
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      color: Colors.black,
      emptyColor: Colors.white,
    );

    final painter = qrPainter;
    const size = 100.0;

    final image = await painter.toImage(size);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<void> generateAndSharePDF() async {
    final pdf = pw.Document();

    // Load the logo image
    final logoBytes = await rootBundle.load("assets/images/frame.png");
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Convert base64 to image
    final profileImage = await base64ToImage(base64Image);

    // Generate QR code image
    final qrBytes = await generateQrImage();
    final qrImage = pw.MemoryImage(qrBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Expanded(
                  child: pw.Container(
                    height: 50,
                    child: pw.Image(
                      logoImage,
                      fit: pw.BoxFit
                          .scaleDown, // Adjust the fit to scale down while preserving aspect ratio
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Center(
                  child: pw.Text(
                    "Bull Tamer's Identity Card",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // ID Number
                pw.Center(
                  child: pw.Text(
                    '-$sequence-',
                    style: pw.TextStyle(
                      fontSize: 40,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Details
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Name: $name',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Blood Group: $bloodGroup',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Date Of Birth: $dob',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Aadhar: $aadhar',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Mobile: $mobile',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(
                            height: 10,
                          ),
                          pw.Text(
                            'Address: $address',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        children: [
                          // Profile Photo
                          pw.Container(
                            width: 100,
                            height: 120,
                            child: pw.Image(profileImage, fit: pw.BoxFit.cover),
                          ),
                          pw.SizedBox(height: 10),
                          // QR Code
                          pw.Container(
                            width: 100,
                            height: 100,
                            child: pw.Image(qrImage),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save and share PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/id_card.pdf');
    await file.writeAsBytes(await pdf.save());

    final result = await Share.shareXFiles([XFile(file.path)], text: 'ID Card');

    if (result.status == ShareResultStatus.success) {
      print('ID Card shared successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card Generator'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: generateAndSharePDF,
          child: const Text('Generate and Share PDF'),
        ),
      ),
    );
  }
}
