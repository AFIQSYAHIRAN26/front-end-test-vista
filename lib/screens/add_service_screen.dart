
import 'package:flutter/material.dart';

import '../models/company.dart';
import '../services/api_service.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final ApiService apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _priceController =
      TextEditingController();

  late Future<List<Company>> companiesFuture;

  int? selectedCompanyId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    companiesFuture = apiService.getCompanies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  Future<void> submitService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a company'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.createService(
        companyId: selectedCompanyId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service created successfully!'),
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
        title: const Text(
          'Add New Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: FutureBuilder<List<Company>>(
        future: companiesFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load companies'),
                    const SizedBox(height: 12),
                    Text('${snapshot.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          companiesFuture = apiService.getCompanies();
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final companies = snapshot.data ?? [];

          if (companies.isEmpty) {
            return const Center(
              child: Text(
                'No companies found. Please add a company first.',
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Dropdown
                  const Text(
                    'Select Company',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    value: selectedCompanyId,
                    decoration: const InputDecoration(
                      hintText: 'Choose a company',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),

                    items: companies.map((company) {
                      return DropdownMenuItem<int>(
                        value: company.id,
                        child: Text(company.name),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedCompanyId = value;
                      });
                    },

                    validator: (value) {
                      if (value == null) {
                        return 'Please select a company';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Service Name
                  const Text(
                    'Service Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter service name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Service name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter service description',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Price
                  const Text(
                    'Price (RM)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter service price',
                      prefixText: 'RM ',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }

                      final price = double.tryParse(value.trim());

                      if (price == null || price < 0) {
                        return 'Enter a valid non-negative price';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitService,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),

                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Add Service',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
}
