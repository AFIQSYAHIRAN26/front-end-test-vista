
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() =>
      _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();

  final ApiService apiService = ApiService();

  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> submitCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.createCompany(
        name: _nameController.text.trim(),
        registrationNumber:
            _registrationController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text('Add New Company'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Company Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter the details below to register a new company.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 28),

              const Text(
                'Company Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter company name',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Company name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Registration Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(
                  hintText: 'Enter registration number',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Registration number is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : submitCompany,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    isLoading
                        ? 'Registering...'
                        : 'Register Company',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
