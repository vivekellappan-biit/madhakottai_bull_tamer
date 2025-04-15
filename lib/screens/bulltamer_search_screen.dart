import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:madhakottai_bull_tamer/providers/registration_provider.dart';
import 'package:madhakottai_bull_tamer/providers/splash_provider.dart';
import 'package:madhakottai_bull_tamer/router/router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/bull_tamer.dart';
import '../providers/bull_tamer_search_provider.dart';
import '../widgets/base64_image_dialog.dart';
import '../widgets/labelvalue_Row.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';

import 'qr_scanner_screen.dart';

// This class represents the data needed for PDF generation
class PdfGenerationData {
  final String logo;
  final String uuid;
  final String sequence;
  final String name;
  final String bloodGroup;
  final String dateOfBirth;
  final String aadharNumber;
  final String mobileOne;
  final String addressLine;
  final String companyName;
  final String street;
  final String street2;
  final Uint8List qrBytes;
  final RootIsolateToken rootToken;
  final Uint8List profileImageBytes;

  PdfGenerationData({
    required this.logo,
    required this.uuid,
    required this.sequence,
    required this.name,
    required this.bloodGroup,
    required this.dateOfBirth,
    required this.aadharNumber,
    required this.mobileOne,
    required this.addressLine,
    required this.companyName,
    required this.street,
    required this.street2,
    required this.qrBytes,
    required this.rootToken,
    required this.profileImageBytes,
  });
}

class BullTamerSearchScreen extends StatefulWidget {
  const BullTamerSearchScreen({super.key});

  @override
  State<BullTamerSearchScreen> createState() => _BullTamerSearchScreenState();
}

class _BullTamerSearchScreenState extends State<BullTamerSearchScreen>
    with AutomaticKeepAliveClientMixin {
  late BullTamer tamer;
  final TextEditingController _aadharController = TextEditingController();
  String logo = "", name = "", street = "", street2 = "";

  // Caches for optimizing performance
  final Map<String, pw.MemoryImage> _imageCache = {};
  final Map<String, Uint8List> _qrCache = {};
  bool _isProcessing = false;

  @override
  bool get wantKeepAlive => false;

  Future<void> _navigateToScanner() async {
    if (!mounted) return;
    final result = await context.push<String>(Routes.qrScan);
    if (!mounted) return;
    if (result != null) {
      context
          .read<BullTamerSearchProvider>()
          .searchBullTamerByUUID(result, context);
    }
  }

  Future<pw.MemoryImage> base64ToImage(String base64String) async {
    // Check cache first
    if (_imageCache.containsKey(base64String)) {
      return _imageCache[base64String]!;
    }

    try {
      final cleanBase64 =
          base64String.replaceAll(RegExp(r'data:image/[^;]+;base64,'), '');
      final Uint8List bytes = base64.decode(cleanBase64);
      final image = pw.MemoryImage(bytes);

      // Store in cache
      _imageCache[base64String] = image;
      return image;
    } catch (e) {
      debugPrint('Error converting base64 to image: $e');
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

  Future<Uint8List> generateQrImage(String uuid) async {
    // Check cache first
    if (_qrCache.containsKey(uuid)) {
      return _qrCache[uuid]!;
    }

    final qrPainter = QrPainter(
      data: uuid,
      version: QrVersions.auto,
      color: Colors.black,
      emptyColor: Colors.white,
    );

    const size = 100.0;
    final image = await qrPainter.toImage(size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    // Cache result
    _qrCache[uuid] = bytes;
    return bytes;
  }

  // This function will be executed in a separate isolate
  static Future<String> _generatePdfInIsolate(PdfGenerationData data) async {
    // Initialize background isolate's binary messenger
    BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootToken);

    final pdf = pw.Document();

    // Decode the base64 logo string
    final logoBytes = base64Decode(data.logo);
    final logoImage = pw.MemoryImage(logoBytes);

    // Use pre-generated profile image bytes
    final profileImage = pw.MemoryImage(data.profileImageBytes);

    // Use pre-generated QR code bytes
    final qrImage = pw.MemoryImage(data.qrBytes);

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
                pw.Container(
                  height: 80,
                  child: pw.Image(
                    logoImage,
                    fit: pw.BoxFit.fitWidth,
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
                pw.Center(
                  child: pw.Text(
                    '-${data.sequence}-',
                    style: pw.TextStyle(
                      fontSize: 40,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Name: ${data.name}', style: _textStyle()),
                          pw.SizedBox(height: 10),
                          pw.Text('Blood Group: ${data.bloodGroup}',
                              style: _textStyle()),
                          pw.SizedBox(height: 10),
                          pw.Text('Date Of Birth: ${data.dateOfBirth}',
                              style: _textStyle()),
                          pw.SizedBox(height: 10),
                          pw.Text('Aadhar: ${data.aadharNumber}',
                              style: _textStyle()),
                          pw.SizedBox(height: 10),
                          pw.Text('Mobile: ${data.mobileOne}',
                              style: _textStyle()),
                          pw.SizedBox(height: 10),
                          pw.Text('Address: ${data.addressLine}',
                              style: _textStyle()),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        children: [
                          pw.Container(
                            width: 100,
                            height: 120,
                            child: pw.Image(profileImage, fit: pw.BoxFit.cover),
                          ),
                          pw.SizedBox(height: 10),
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

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Bull_Tamer_Identity_Card.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.TextStyle _textStyle() {
    return pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.normal);
  }

  Future<void> generateAndSharePDF() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Generating PDF..."),
              ],
            ),
          );
        },
      );

      // Generate QR code in main isolate
      final qrBytes = await generateQrImage(tamer.uuid);

      // Get root isolate token
      final rootToken = RootIsolateToken.instance!;

      // Convert profile image to bytes
      final profileImageBytes = base64Decode(tamer.profile_image
          .replaceAll(RegExp(r'data:image/[^;]+;base64,'), ''));

      // Prepare data for isolate
      final pdfData = PdfGenerationData(
        logo: logo,
        uuid: tamer.uuid,
        sequence: tamer.sequence.toString(),
        name: tamer.name,
        bloodGroup: tamer.bloodGroup,
        dateOfBirth: tamer.dateOfBirth,
        aadharNumber: tamer.aadharNumber,
        mobileOne: tamer.mobileOne,
        addressLine: tamer.addressLine,
        companyName: name,
        street: street,
        street2: street2,
        qrBytes: qrBytes,
        rootToken: rootToken,
        profileImageBytes: profileImageBytes,
      );

      // Generate PDF in a compute function to avoid UI freezing
      final filePath = await compute(_generatePdfInIsolate, pdfData);

      // Close the progress dialog
      if (mounted) Navigator.of(context).pop();

      // Share the file
      final result = await Share.shareXFiles([XFile(filePath)],
          text: 'Bull Tamer Identity Card');

      if (result.status == ShareResultStatus.success) {
        debugPrint('ID Card shared successfully!');
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  final String phone = '919876543210'; // ✅ No '+' symbol
  final String message = 'Hello from Flutter!';

  Future<void> openWhatsApp() async {
    final phone = tamer.mobileOne.replaceAll(' ', '').trim();
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
    final message = """
$name
$street
$street2

Participant Details:
Token No: ${tamer.sequence}
Name: ${tamer.name}
Blood Group: ${tamer.bloodGroup}
Aadhar: ${tamer.aadharNumber}
Mobile: ${tamer.mobileOne}
Address: ${tamer.addressLine}
""";

    final encodedMessage = Uri.encodeComponent(message);
    final url =
        'https://api.whatsapp.com/send?phone=$formattedPhone&text=$encodedMessage';
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open WhatsApp: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> sendTextToWhatsapp(String message, String phoneNumber) async {
    // Make sure the phone number is properly formatted
    phoneNumber = phoneNumber.replaceAll(' ', '').trim();
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91$phoneNumber'; // Add country code if missing
    }

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri uri =
        Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open WhatsApp: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Clear results when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BullTamerSearchProvider>().clearSearchResults();
    });
    readCompanyDetails();
  }

  void readCompanyDetails() async {
    final logoDetails =
        await Provider.of<SplashProvider>(context, listen: false)
            .getLogoDetails();

    if (mounted) {
      setState(() {
        logo = logoDetails['logo'] ?? "";
        name = logoDetails['name'] ?? "";
        street = logoDetails['street'] ?? "";
        street2 = logoDetails['street2'] ?? "";
      });
    }
  }

  // Preload images for smoother UI
  void preloadImages(List<BullTamer> tamers) {
    for (var tamer in tamers) {
      try {
        if (tamer.profile_image.isNotEmpty) {
          precacheImage(
              MemoryImage(base64Decode(tamer.profile_image
                  .replaceAll(RegExp(r'data:image/[^;]+;base64,'), ''))),
              context);
        }
        if (tamer.aadhar_image.isNotEmpty) {
          precacheImage(
              MemoryImage(base64Decode(tamer.aadhar_image
                  .replaceAll(RegExp(r'data:image/[^;]+;base64,'), ''))),
              context);
        }
      } catch (e) {
        debugPrint('Error preloading images: $e');
      }
    }
  }

  @override
  void dispose() {
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('தேடல்'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
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

                  // Preload images for smoother UI
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    preloadImages(provider.searchResults);
                  });

                  return _buildResultsList(provider, registrationProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 80, // Adjusted to account for maxLength counter
            child: TextField(
              controller: _aadharController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Aadhar Number',
                hintText: 'Enter 12 digit Aadhar number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
              onChanged: (value) {
                if (value.length == 12) {
                  // Debounce search to prevent rapid API calls
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (_aadharController.text == value) {
                      final provider = Provider.of<BullTamerSearchProvider>(
                          context,
                          listen: false);
                      provider.searchBullTamer(value, context);
                    }
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: IconButton(
            onPressed: _navigateToScanner,
            icon: const Icon(
              Icons.qr_code_scanner,
              size: 28,
            ),
            tooltip: 'Scan QR Code',
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(BullTamerSearchProvider provider,
      RegistrationProvider registrationProvider) {
    return ListView.builder(
      itemCount: provider.searchResults.length,
      cacheExtent: 3000, // Cache more items for smoother scrolling
      addAutomaticKeepAlives: false, // Don't keep all items alive
      itemBuilder: (context, index) {
        final tamer2 = provider.searchResults[index];
        return _buildTamerCard(tamer2, registrationProvider);
      },
    );
  }

  Widget _buildTamerCard(
      BullTamer tamer2, RegistrationProvider registrationProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic details
            LabelValueRow(
                label: "காளையை அடக்குபவர் எண்:", value: tamer2.sequence),
            LabelValueRow(
                label: "காளையை அடக்குபவர் பெயர்:", value: tamer2.name),
            LabelValueRow(label: "இரத்த வகை:", value: tamer2.bloodGroup),
            LabelValueRow(label: "பிறந்த தேதி:", value: tamer2.dateOfBirth),
            LabelValueRow(label: "தொலைபேசி எண்:", value: tamer2.mobileOne),
            LabelValueRow(label: "ஆதார் எண்:", value: tamer2.aadharNumber),
            LabelValueRow(
              label: "Created By:",
              value: '${tamer2.writeUid[1]}',
            ),
            LabelValueRow(
              label: "Created Date:",
              value: tamer2.createDate,
            ),

            // Image buttons
            _buildImageButtons(tamer2),

            // Entry Status
            _buildEntryStatusSection(tamer2, registrationProvider),

            // Registration Status
            _buildRegistrationStatusSection(tamer2, registrationProvider),

            // Action buttons
            _buildActionButtons(tamer2),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButtons(BullTamer tamer2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              showImageDialog(context, tamer2.profile_image);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              side: const BorderSide(color: Colors.blue),
            ),
            child: const Text(
              'View Profile',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              showImageDialog(context, tamer2.aadhar_image);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              side: const BorderSide(color: Colors.blue),
            ),
            child: const Text(
              'View Aadhar',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryStatusSection(
      BullTamer tamer2, RegistrationProvider registrationProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4, top: 4),
          child: Text(
            'Entry Status',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _submitForm(registrationProvider, "Not Entered", tamer2.id,
                      "entry_status");
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: tamer2.entryStatus == "Not Entered"
                      ? Colors.blue
                      : Colors.transparent,
                  side: BorderSide(
                      color: tamer2.entryStatus == "Not Entered"
                          ? Colors.blue
                          : Colors.grey),
                ),
                child: const Text(
                  'Not Entered',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  _submitForm(registrationProvider, "Entered", tamer2.id,
                      "entry_status");
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: tamer2.entryStatus == "Entered"
                      ? Colors.blue
                      : Colors.transparent,
                  side: BorderSide(
                      color: tamer2.entryStatus == "Entered"
                          ? Colors.blue
                          : Colors.grey),
                ),
                child: const Text(
                  'Entered',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegistrationStatusSection(
      BullTamer tamer2, RegistrationProvider registrationProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            'Registration Status',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _submitForm(registrationProvider, "Registered", tamer2.id,
                      "registration_status");
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: tamer2.registrationStatus == "Registered"
                      ? Colors.blue
                      : Colors.transparent,
                  side: BorderSide(
                      color: tamer2.registrationStatus == "Registered"
                          ? Colors.blue
                          : Colors.grey),
                ),
                child: const Text(
                  'Registered',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _submitForm(registrationProvider, "Verified", tamer2.id,
                      "registration_status");
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: tamer2.registrationStatus == "Verified"
                      ? Colors.green
                      : Colors.transparent,
                  side: BorderSide(
                      color: tamer2.registrationStatus == "Verified"
                          ? Colors.green
                          : Colors.grey),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _submitForm(registrationProvider, "Cancelled", tamer2.id,
                      "registration_status");
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: tamer2.registrationStatus == "Cancelled"
                      ? Colors.red
                      : Colors.transparent,
                  side: BorderSide(
                      color: tamer2.registrationStatus == "Cancelled"
                          ? Colors.red
                          : Colors.grey),
                ),
                child: const Text(
                  'Cancelled',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BullTamer tamer2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            tamer = tamer2;
            openWhatsApp();
          },
          icon: const Icon(Icons.share),
          tooltip: 'Share via WhatsApp',
        ),
        IconButton(
          onPressed: () {
            tamer = tamer2;
            generateAndSharePDF();
          },
          icon: const Icon(Icons.attach_file),
          tooltip: 'Share PDF',
        ),
      ],
    );
  }

  Future<void> _submitForm(RegistrationProvider provider, String status, int id,
      String entryStatus) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Updating status..."),
            ],
          ),
        );
      },
    );

    try {
      final success = await provider.updatedEntryStatus(
          id.toString(), status, entryStatus, context);

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        if (success) {
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
                      context
                          .read<BullTamerSearchProvider>()
                          .searchBullTamer(_aadharController.text, context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(provider.errorMessage.isEmpty
                    ? 'Status update failed'
                    : provider.errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.toString()}')),
        );
      }
    }
  }
}
