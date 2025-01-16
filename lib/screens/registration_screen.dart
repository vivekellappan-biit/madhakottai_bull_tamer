// lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/registration_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/ validators.dart';
import '../widgets/custom_text_field.dart';
import '../models/registration_model.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Initialize all controllers in the state
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _onlineRegNoController;
  late final TextEditingController _bloodGroupController;
  late final TextEditingController _ageController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers in initState
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _onlineRegNoController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('பதிவு படிவம் - 2024'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
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
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nameController,
                    label: 'பெயர்',
                    validator: Validators.required,
                  ),
                  CustomTextField(
                    controller: _addressController,
                    label: 'முகவரி',
                    maxLines: 3,
                    validator: Validators.required,
                  ),
                  CustomTextField(
                    controller: _onlineRegNoController,
                    label: 'Online Registration No',
                    keyboardType: TextInputType.number,
                    validator: Validators.required,
                  ),
                  CustomTextField(
                    controller: _bloodGroupController,
                    label: 'Blood Group',
                    validator: Validators.required,
                  ),
                  _buildDatePicker(),
                  CustomTextField(
                    controller: _ageController,
                    label: 'Age',
                    keyboardType: TextInputType.number,
                    validator: Validators.age,
                  ),
                  const SizedBox(height: 20),
                  _buildSubmitButton(provider),
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 100),
          const SizedBox(height: 10),
          Text(
            'Registration Form',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: const Text('Date of Birth'),
      subtitle: Text(
        _selectedDate == null
            ? 'Select Date'
            : DateFormat('dd-MM-yyyy').format(_selectedDate!),
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildSubmitButton(RegistrationProvider provider) {
    return ElevatedButton(
      onPressed: () => _submitForm(provider),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Text('Submit'),
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
        _ageController.text = (DateTime.now().year - picked.year).toString();
      });
    }
  }

  Future<void> _submitForm(RegistrationProvider provider) async {
    if (_formKey.currentState!.validate()) {
      final registration = RegistrationModel(
        name: _nameController.text,
        address: _addressController.text,
        onlineRegNo: _onlineRegNoController.text,
        bloodGroup: _bloodGroupController.text,
        dateOfBirth: _selectedDate,
        age: int.tryParse(_ageController.text),
      );

      final success = await provider.submitRegistration(registration);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration submitted successfully')),
        );
        _formKey.currentState!.reset();
        _clearForm();
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _onlineRegNoController.clear();
    _bloodGroupController.clear();
    _ageController.clear();
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _addressController.dispose();
    _onlineRegNoController.dispose();
    _bloodGroupController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
