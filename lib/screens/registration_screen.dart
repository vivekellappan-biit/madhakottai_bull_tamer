import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madhakottai_bull_tamer/screens/bulltamer_search_screen.dart';
import 'package:madhakottai_bull_tamer/screens/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/bull_tamer.dart';
import '../providers/bull_tamer_search_provider.dart';
import '../providers/registration_provider.dart';
import '../providers/splash_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/ validators.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';
import '../models/registration_model.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _onlineRegNoController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _aadhaarController;

  // Dropdown values
  String? _selectedBloodGroup;
  String? _selectedDistrict;
  DateTime? _selectedDate;
  XFile? _userPhoto;
  XFile? _aadhaarPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _onlineRegNoController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();
    _aadhaarController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
  }

  Future<void> _pickImage(ImageSource source, bool isUserPhoto) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isUserPhoto) {
            _userPhoto = image;
          } else {
            _aadhaarPhoto = image;
          }
        });
      }
    } else if (status.isDenied) {
      // Handle the case when the user denies the permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera permission is required to capture photos')),
      );
    } else if (status.isPermanentlyDenied) {
      // Handle the case when the user permanently denies the permission
      openAppSettings();
    }
  }

  String? _convertToBase64(XFile? image) {
    if (image == null) return null;
    final bytes = File(image.path).readAsBytesSync();
    return base64Encode(bytes);
  }

  // Future<void> _checkAadhaarNumber(
  //     String value, BullTamerSearchProvider bullTamerProvider) async {
  //   // Perform the search asynchronously
  //   await bullTamerProvider.searchBullTamer(value.replaceAll(' ', ''), context);

  //   // Show the dialog with the search result
  //   if (bullTamerProvider.searchResults.isNotEmpty) {
  //     // If results are found, show the results in the dialog
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Search Result'),
  //         content: SizedBox(
  //           height: 200,
  //           width: 300,
  //           child: ListView.builder(
  //             itemCount: bullTamerProvider.searchResults.length,
  //             itemBuilder: (context, index) {
  //               final BullTamer tamer = bullTamerProvider.searchResults[index];
  //               return ListTile(
  //                 title: Text(tamer.name),
  //                 subtitle: Text('Aadhaar: ${tamer.aadharNumber}'),
  //               );
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else if (bullTamerProvider.errorMessage.isNotEmpty) {
  //     // If an error occurs, show the error message in a dialog
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Error'),
  //         content: Text(bullTamerProvider.errorMessage),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     // If no records are found
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Search Result'),
  //         content: const Text('No records found for this Aadhaar number.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  Future<void> _checkAadhaarNumber(
      String value, BullTamerSearchProvider bullTamerProvider) async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    await bullTamerProvider.searchBullTamer(value.replaceAll(' ', ''), context);
    setState(() {
      _isLoading = false; // Set loading state to false
    });

    if (bullTamerProvider.searchResults.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Search Result'),
          content: SizedBox(
            height: 200,
            width: 300,
            child: ListView.builder(
              itemCount: bullTamerProvider.searchResults.length,
              itemBuilder: (context, index) {
                final BullTamer tamer = bullTamerProvider.searchResults[index];
                return ListTile(
                  title: Text(tamer.name),
                  subtitle: Text('Aadhar: ${tamer.aadharNumber}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _aadhaarController.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context);
    final bullTamerProvider = Provider.of<BullTamerSearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('மாதாகோட்டை ஜல்லிக்கட்டு - 2025'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BullTamerSearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () async {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await splashProvider.setLoginStatus(false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BullTamerSearchScreen()),
          );
        },
        child: const Icon(Icons.search),
      ),
      body: Consumer<RegistrationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          maxLength: 14, // 12 digits + 2 spaces
                          isAadhaarNumber: true,
                          controller: _aadhaarController,
                          label: 'Aadhar Number / ஆதார் எண்',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.replaceAll(' ', '').length == 12) {
                              _checkAadhaarNumber(value, bullTamerProvider);
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.replaceAll(' ', '').length != 12) {
                              return 'Enter a valid 12-digit Aadhaar number';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (bullTamerProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Bull Tamer Name / காளையை அடக்குபவர் பெயர்',
                    validator: Validators.required,
                  ),
                  CustomTextField(
                    controller: _addressController,
                    label: 'Full Address / முழு முகவரி',
                    maxLines: 3,
                    validator: Validators.required,
                  ),
                  SearchableDropdownField(
                    label: 'District / மாவட்டம்',
                    value: _selectedDistrict,
                    items: AppConstants.tnDistricts,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a district';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _onlineRegNoController,
                    label: 'Online Registration No',
                    keyboardType: TextInputType.number,
                    validator: Validators.required,
                  ),
                  SearchableDropdownField(
                    label: 'Blood Group / இரத்த வகை',
                    value: _selectedBloodGroup,
                    items: AppConstants.bloodGroups,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a blood group';
                      }
                      return null;
                    },
                  ),
                  _buildDatePicker(),
                  Visibility(
                    visible: false,
                    child: CustomTextField(
                      controller: _ageController,
                      label: 'வயது / Age',
                      keyboardType: TextInputType.number,
                      validator: Validators.age,
                    ),
                  ),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Mobile Number / தொலைபேசி எண்',
                    keyboardType: TextInputType.phone,
                    maxLength: 15, // +91 12345 67890
                    isPhoneNumber: true,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.replaceAll(' ', '').length != 13) {
                        return 'Enter a valid 10-digit phone number including +91';
                      }
                      return null;
                    },
                  ),
                  Visibility(
                    visible: false,
                    child: CustomTextField(
                      controller: _emergencyPhoneController,
                      label: 'அவசரத் தொடர்பு நபரின் தொலைபேசி எண்',
                      keyboardType: TextInputType.phone,
                      maxLength: 15, // +91 12345 67890
                      isPhoneNumber: true,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.replaceAll(' ', '').length != 13) {
                          return 'Enter a valid 10-digit phone number including +91';
                        }
                        return null;
                      },
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            maxLength: 14,
                            isAadhaarNumber: true,
                            controller: _aadhaarController,
                            label: 'ஆதார் எண் / Aadhaar Number',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.replaceAll(' ', '').length == 12) {
                                _checkAadhaarNumber(value, bullTamerProvider);
                              }
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.replaceAll(' ', '').length != 12) {
                                return 'Enter a valid 12-digit Aadhaar number';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (bullTamerProvider.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          _userPhoto == null
                              ? const Text('')
                              : Image.file(File(_userPhoto!.path),
                                  width: 100, height: 100),
                          OutlinedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                            ),
                            onPressed: () =>
                                _pickImage(ImageSource.camera, true),
                            child: const Text('Bull Tamer Photo '),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          _aadhaarPhoto == null
                              ? const Text('')
                              : Image.file(File(_aadhaarPhoto!.path),
                                  width: 100, height: 100),
                          OutlinedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                            ),
                            onPressed: () =>
                                _pickImage(ImageSource.camera, false),
                            child: const Text('Bull Tamer Aadhar '),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSubmitButton(provider, splashProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            'மாடுபிடி வீரர்களுக்கான அடையாள அட்டை',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          )
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date of Birth / பிறந்த தேதி',
            border: OutlineInputBorder(),
            filled: true,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                    ? 'Select Date of Birth'
                    : DateFormat('MM/dd/yyyy').format(_selectedDate!),
              ),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
      RegistrationProvider provider, SplashProvider splashProvider) {
    return ElevatedButton(
      onPressed: () => _submitForm(provider, splashProvider),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Calculate age
        final age = DateTime.now().year - picked.year;
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _submitForm(
      RegistrationProvider provider, SplashProvider splashProvider) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date of birth')),
        );
        return;
      }

      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(_selectedDate!);
      print(formattedDate);
      final registration = RegistrationModel(
        name: _nameController.text,
        address_line: _addressController.text,
        district: _selectedDistrict!,
        emergencyMobileNo: _onlineRegNoController.text,
        onlineRegNo: _onlineRegNoController.text,
        bloodGroup: _selectedBloodGroup!,
        dateOfBirth: formattedDate,
        mobileNo: _phoneController.text..replaceAll(' ', ''),
        aadharImage: _convertToBase64(_aadhaarPhoto)!,
        profileImage: _convertToBase64(_userPhoto)!,
        // aadharImage: '',
        //profileImage: '',
        aadharCardNo: _aadhaarController.text.replaceAll(' ', ''),
      );

      final success = await provider.submitBullTamer(registration, context);

      if (success && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Registration submitted successfully'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    _clearForm();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        _clearForm();
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

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _onlineRegNoController.dispose();
    _ageController.dispose();

    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _onlineRegNoController.clear();
    _ageController.clear();
    _phoneController.clear();
    _aadhaarController.clear();
    setState(() {
      _selectedBloodGroup = null;
      _selectedDistrict = null;
      _selectedDate = null;
      _userPhoto = null;
      _aadhaarPhoto = null;
    });
  }
}
