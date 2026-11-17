
import 'package:flutter/material.dart';

import '../models/company.dart';
import '../services/api_service.dart';

class EditCompanyScreen extends StatefulWidget {
  final Company company;

  const EditCompanyScreen({
    super.key,
    required this.company,
  });

  @override
  State<EditCompanyScreen> createState() =>
      _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();

  final ApiService apiService = ApiService();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Fill the form with existing company information
    _nameController.text = widget.company.name;
    _registrationController.text =
        widget.company.registrationNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> updateCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.updateCompany(
        id: widget.company.id,
        name: _nameController.text.trim(),
        registrationNumber:
            _registrationController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company updated successfully!'),
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
        title: const Text('Edit Company'),
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
                'Update Company Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Company ID: ${widget.company.id}',
                style: const TextStyle(color: Colors.grey),
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
                  onPressed: isLoading ? null : updateCompany,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isLoading ? 'Updating...' : 'Save Changes',
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
