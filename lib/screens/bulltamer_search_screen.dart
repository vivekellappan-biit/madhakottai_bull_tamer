// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/bull_tamer.dart';
// import '../providers/bull_tamer_search_provider.dart';
// import '../widgets/labelvalue_Row.dart';
// import 'dart:ui';

// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:share_plus/share_plus.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'dart:typed_data';

// // ignore: must_be_immutable
// class BullTamerSearchScreen extends StatelessWidget {
//   late BullTamer tamer;

//   BullTamerSearchScreen({super.key});

//   final TextEditingController _aadharController = TextEditingController();

//   Future<pw.MemoryImage> base64ToImage(String base64String) async {
//     try {
//       final cleanBase64 =
//           base64String.replaceAll(RegExp(r'data:image/[^;]+;base64,'), '');
//       final Uint8List bytes = base64.decode(cleanBase64);
//       return pw.MemoryImage(bytes);
//     } catch (e) {
//       print('Error converting base64 to image: $e');
//       throw Exception('Invalid base64 image');
//     }
//   }

//   // Create QR code widget for preview
//   Widget buildQrPreview() {
//     return QrImageView(
//       data: tamer.uuid,
//       version: QrVersions.auto,
//       size: 100,
//     );
//   }

//   // Convert QR widget to Uint8List
//   Future<Uint8List> generateQrImage() async {
//     final qrPainter = QrPainter(
//       data: tamer.uuid,
//       version: QrVersions.auto,
//       color: Colors.black,
//       emptyColor: Colors.white,
//     );

//     final painter = qrPainter;
//     const size = 100.0;

//     final image = await painter.toImage(size);
//     final byteData = await image.toByteData(format: ImageByteFormat.png);

//     return byteData!.buffer.asUint8List();
//   }

//   Future<void> generateAndSharePDF() async {
//     final pdf = pw.Document();

//     // Load the logo image
//     final logoBytes = await rootBundle.load("assets/images/frame.png");
//     final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

//     // Convert base64 to image
//     final profileImage = await base64ToImage(tamer.aadhar_image);

//     // Generate QR code image
//     final qrBytes = await generateQrImage();
//     final qrImage = pw.MemoryImage(qrBytes);

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Container(
//             padding: const pw.EdgeInsets.all(8),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 pw.Expanded(
//                   child: pw.Container(
//                     height: 50,
//                     child: pw.Image(
//                       logoImage,
//                       fit: pw.BoxFit
//                           .scaleDown, // Adjust the fit to scale down while preserving aspect ratio
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),

//                 pw.Center(
//                   child: pw.Text(
//                     "Bull Tamer's Identity Card",
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),

//                 // ID Number
//                 pw.Center(
//                   child: pw.Text(
//                     '-${tamer.sequence}-',
//                     style: pw.TextStyle(
//                       fontSize: 40,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),

//                 // Details
//                 pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Expanded(
//                       flex: 3,
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             'Name: ${tamer.name}',
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                           pw.SizedBox(height: 10),
//                           pw.Text(
//                             'Blood Group: ${tamer.bloodGroup}',
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                           pw.SizedBox(height: 10),
//                           pw.Text(
//                             'Date Of Birth: ${tamer.dateOfBirth}',
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                           pw.SizedBox(height: 10),
//                           pw.Text(
//                             'Aadhar: ${tamer.aadharNumber}',
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                           pw.SizedBox(height: 10),
//                           pw.Text(
//                             'Mobile: ${tamer.mobileOne}',
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                           pw.SizedBox(
//                             height: 10,
//                           ),
//                           pw.Text(
//                             'Address: ${tamer..addressLine}',
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     pw.Expanded(
//                       flex: 1,
//                       child: pw.Column(
//                         children: [
//                           // Profile Photo
//                           pw.Container(
//                             width: 100,
//                             height: 120,
//                             child: pw.Image(profileImage, fit: pw.BoxFit.cover),
//                           ),
//                           pw.SizedBox(height: 10),
//                           // QR Code
//                           pw.Container(
//                             width: 100,
//                             height: 100,
//                             child: pw.Image(qrImage),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     // Save and share PDF
//     final output = await getTemporaryDirectory();
//     final file = File('${output.path}/id_card.pdf');
//     await file.writeAsBytes(await pdf.save());

//     final result = await Share.shareXFiles([XFile(file.path)], text: 'ID Card');

//     if (result.status == ShareResultStatus.success) {
//       print('ID Card shared successfully!');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Search Bull Tamer'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _aadharController,
//               decoration: const InputDecoration(
//                 labelText: 'Aadhar Number',
//                 hintText: 'Enter 12 digit Aadhar number',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//               maxLength: 12,
//               onChanged: (value) {
//                 if (value.length == 12) {
//                   context
//                       .read<BullTamerSearchProvider>()
//                       .searchBullTamer(value, context);
//                 }
//               },
//             ),
//             // const SizedBox(height: 16),
//             // ElevatedButton(
//             //   onPressed: () {
//             //     if (_aadharController.text.length == 12) {
//             //       context
//             //           .read<BullTamerSearchProvider>()
//             //           .searchBullTamer(_aadharController.text, context);
//             //     }
//             //   },
//             //   child: const Text('Search'),
//             // ),
//             const SizedBox(height: 24),
//             Expanded(
//               child: Consumer<BullTamerSearchProvider>(
//                 builder: (context, provider, child) {
//                   if (provider.isLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (provider.errorMessage.isNotEmpty) {
//                     return Center(
//                       child: Text(
//                         provider.errorMessage,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     );
//                   }

//                   if (provider.searchResults.isEmpty) {
//                     return const Center(
//                       child: Text('No results found'),
//                     );
//                   }

//                   return ListView.builder(
//                     itemCount: provider.searchResults.length,
//                     itemBuilder: (context, index) {
//                       final tamer2 = provider.searchResults[index];
//                       return GestureDetector(
//                         onTap: () {
//                           // tamer = tamer2;
//                           // generateAndSharePDF();
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //       builder: (context) => IdCardGenerator(
//                           //             sequence: tamer.sequence.toString(),
//                           //             uuid: tamer.uuid,
//                           //             dob: tamer.dateOfBirth,
//                           //             name: tamer.name,
//                           //             bloodGroup: tamer.bloodGroup,
//                           //             aadhar: tamer.aadharNumber,
//                           //             mobile: tamer.mobileOne,
//                           //             address: tamer.addressLine,
//                           //             base64Image: tamer.aadhar_image,
//                           //             qrData: tamer.aadharNumber,
//                           //           )),
//                           // );
//                         },
//                         child: Card(
//                           margin: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 0),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 LabelValueRow(
//                                     label: "காளையை அடக்குபவர் பெயர்:",
//                                     value: tamer2.name),
//                                 LabelValueRow(
//                                     label: "இரத்த வகை:",
//                                     value: tamer2.bloodGroup),
//                                 LabelValueRow(
//                                     label: "பிறந்த தேதி:",
//                                     value: tamer2.dateOfBirth),
//                                 LabelValueRow(
//                                     label: "தொலைபேசி எண்:",
//                                     value: tamer2.mobileOne),
//                                 LabelValueRow(
//                                     label: "ஆதார் எண்:",
//                                     value: tamer2.aadharNumber),
//                                 LabelValueRow(
//                                   label: "Created By:",
//                                   value: '${tamer2.writeUid[1]}',
//                                 ),
//                                 LabelValueRow(
//                                   label: "Created Date:",
//                                   value: tamer2.createDate,
//                                 ),
//                                 Align(
//                                   alignment: Alignment.topRight,
//                                   child: IconButton(
//                                     onPressed: () {
//                                       tamer = tamer2;
//                                       generateAndSharePDF();
//                                     },
//                                     icon: const Icon(Icons.share),
//                                     tooltip: 'Share',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:madhakottai_bull_tamer/providers/registration_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/bull_tamer.dart';
import '../providers/bull_tamer_search_provider.dart';
import '../widgets/labelvalue_Row.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class BullTamerSearchScreen extends StatefulWidget {
  const BullTamerSearchScreen({super.key});

  @override
  State<BullTamerSearchScreen> createState() => _BullTamerSearchScreenState();
}

class _BullTamerSearchScreenState extends State<BullTamerSearchScreen>
    with AutomaticKeepAliveClientMixin {
  late BullTamer tamer;
  final TextEditingController _aadharController = TextEditingController();
  bool _isScanning = false;

  @override
  bool get wantKeepAlive => false; // Set to false to clear state when leaving

  @override
  void dispose() {
    // Clear the search results when disposing
    context.read<BullTamerSearchProvider>().clearSearchResults();
    _aadharController.dispose();
    super.dispose();
  }

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

  Widget buildQrPreview() {
    return QrImageView(
      data: tamer.uuid,
      version: QrVersions.auto,
      size: 100,
    );
  }

  Future<Uint8List> generateQrImage() async {
    final qrPainter = QrPainter(
      data: tamer.uuid,
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
    final profileImage = await base64ToImage(tamer.aadhar_image);

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
                    '-${tamer.sequence}-',
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
                            'Name: ${tamer.name}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Blood Group: ${tamer.bloodGroup}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Date Of Birth: ${tamer.dateOfBirth}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Aadhar: ${tamer.aadharNumber}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Mobile: ${tamer.mobileOne}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.SizedBox(
                            height: 10,
                          ),
                          pw.Text(
                            'Address: ${tamer..addressLine}',
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
    final file = File('${output.path}/Bull Tamer_Identity_Card.pdf');
    await file.writeAsBytes(await pdf.save());

    //shareTextWithWhatsapp();
    //sharePdfToWhatsapp(file.path);
    final result = await Share.shareXFiles([XFile(file.path)], text: 'ID Card');
    // sharePdfWithWhatsapp(file.path);
    if (result.status == ShareResultStatus.success) {
      print('ID Card shared successfully!');
    }
  }

  // Future<void> sharePdfWithWhatsapp(String filePath) async {
  //   print("called");
  //   String phoneNumber =
  //       "+919345281193"; // Add recipient's phone number with country code
  //   String message = "Hello, please find the attached PDF.";

  //   if (Platform.isAndroid) {
  //     final Uri uri = Uri.parse(
  //         "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}");
  //     if (await canLaunchUrl(uri)) {
  //       await Share.shareXFiles([XFile(filePath)], text: message);
  //     } else {
  //       throw 'Could not launch WhatsApp';
  //     }
  //   } else if (Platform.isIOS) {
  //     // For iOS
  //     final Uri uri = Uri.parse(
  //         "https://wa.me/${phoneNumber.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}");
  //     if (await canLaunchUrl(uri)) {
  //       await Share.shareXFiles([XFile(filePath)], text: message);
  //     } else {
  //       throw 'Could not launch WhatsApp';
  //     }
  //   } else {
  //     throw 'Unsupported platform';
  //   }
  // }

  Future<void> sendTextToWhatsapp(String message, String phoneNumber) async {
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri uri =
        Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  // Future<void> shareTextWithWhatsapp() async {
  //   print("called");
  //   String phoneNumber =
  //       "+919345281193"; // Add recipient's phone number with country code
  //   String message = "Hello, this is a text message sent via WhatsApp.";

  //   if (Platform.isAndroid) {
  //     // For Android
  //     final Uri uri = Uri.parse(
  //         "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}");
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri);
  //     } else {
  //       throw 'Could not launch WhatsApp';
  //     }
  //   } else if (Platform.isIOS) {
  //     // For iOS
  //     final Uri uri = Uri.parse(
  //         "https://wa.me/${phoneNumber.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}");
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri);
  //     } else {
  //       throw 'Could not launch WhatsApp';
  //     }
  //   } else {
  //     throw 'Unsupported platform';
  //   }
  // }

  // Future<void> sharePdfToWhatsapp(String filePath) async {
  //   String phoneNumber = "+919791062925"; // WhatsApp number with country code
  //   String message = "ID Card"; // Custom message to send
  //   final result = await Share.shareXFiles([XFile(filePath)], text: message);
  //   String url =
  //       "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

  //   // Open WhatsApp with the link
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not open WhatsApp';
  //   }
  // }

  Widget _buildQRScanner() {
    return SizedBox(
      height: 300,
      child: _isScanning
          ? MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final String? code = barcode.rawValue;
                  if (code != null && code.length == 12) {
                    setState(() {
                      _isScanning = false;
                      _aadharController.text = code;
                    });
                    context
                        .read<BullTamerSearchProvider>()
                        .searchBullTamer(code, context);
                  }
                }
              },
            )
          : Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isScanning = true;
                  });
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);

    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bull Tamer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _aadharController,
              decoration: const InputDecoration(
                labelText: 'Aadhar Number',
                hintText: 'Enter 12 digit Aadhar number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
              onChanged: (value) {
                if (value.length == 12) {
                  context
                      .read<BullTamerSearchProvider>()
                      .searchBullTamer(value, context);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildQRScanner(),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<BullTamerSearchProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        provider.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (provider.searchResults.isEmpty) {
                    return const Center(
                      child: Text('No results found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final tamer2 = provider.searchResults[index];
                      return GestureDetector(
                        onTap: () {
                          // ... [Keep existing onTap code unchanged] ...
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelValueRow(
                                    label: "காளையை அடக்குபவர் பெயர்:",
                                    value: tamer2.name),
                                LabelValueRow(
                                    label: "இரத்த வகை:",
                                    value: tamer2.bloodGroup),
                                LabelValueRow(
                                    label: "பிறந்த தேதி:",
                                    value: tamer2.dateOfBirth),
                                LabelValueRow(
                                    label: "தொலைபேசி எண்:",
                                    value: tamer2.mobileOne),
                                LabelValueRow(
                                    label: "ஆதார் எண்:",
                                    value: tamer2.aadharNumber),
                                LabelValueRow(
                                  label: "Created By:",
                                  value: '${tamer2.writeUid[1]}',
                                ),
                                LabelValueRow(
                                  label: "Created Date:",
                                  value: tamer2.createDate,
                                ),
                                const Text('Entry Status'),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () {
                                            _submitForm(
                                                registrationProvider,
                                                "Not Entered",
                                                tamer2.id,
                                                "entry_status");
                                          },
                                          child: const Text('Not Entered')),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () async {
                                            _submitForm(
                                                registrationProvider,
                                                "Entered",
                                                tamer2.id,
                                                "entry_status");
                                          },
                                          child: const Text('Entered')),
                                    )
                                  ],
                                ),
                                const Text('Registration Status'),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () {
                                            _submitForm(
                                                registrationProvider,
                                                "Registered",
                                                tamer2.id,
                                                "registration_status");
                                          },
                                          child: const Text('Registered')),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () {
                                            _submitForm(
                                                registrationProvider,
                                                "Verified",
                                                tamer2.id,
                                                "registration_status");
                                          },
                                          child: const Text('Verified')),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () {
                                            _submitForm(
                                                registrationProvider,
                                                "Cancelled",
                                                tamer2.id,
                                                "registration_status");
                                          },
                                          child: const Text('Cancelled')),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        tamer = tamer2;

                                        String message = """
புனித லூர்து மாதா ஜெயிலிக்கட்டு பேரவை 2025
மாதாக்கோட்டை, தஞ்சாவூர்
நாள்: 01-பிப்ரவரி-2025 சனிக்கிழமை
நேரம்: காலை 7 மணி

Participant Details:
Name: ${tamer.name}
Blood Group: ${tamer.bloodGroup}
Aadhar: ${tamer.aadharNumber}
Mobile: ${tamer.mobileOne}
Address: ${tamer.addressLine}
""";

                                        String phoneNumber = tamer.mobileOne
                                            .replaceAll(
                                                ' ', ''); // Remove spaces
                                        print(phoneNumber);

// Send message to WhatsApp
                                        sendTextToWhatsapp(
                                            message, phoneNumber);
                                      },
                                      icon: const Icon(Icons.share),
                                      tooltip: 'Share',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        tamer = tamer2;
                                        generateAndSharePDF();
                                      },
                                      icon: const Icon(Icons.attach_file),
                                      tooltip: 'Share',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm(RegistrationProvider provider, String status, int id,
      String entryStatus) async {
    final success = await provider.updatedEntryStatus(
        id.toString(), status, entryStatus, context);

    if (success && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Updated successfully'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage.isEmpty
                ? 'Registration failed'
                : provider.errorMessage)),
      );
    }
  }
}
