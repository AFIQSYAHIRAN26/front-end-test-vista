
import 'package:flutter/material.dart';

import '../models/company.dart';
import '../services/api_service.dart';

class EditServiceScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const EditServiceScreen({
    super.key,
    required this.service,
  });

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final ApiService apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;

  int? selectedCompanyId;

  late Future<List<Company>> companiesFuture;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.service['name']?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.service['description']?.toString() ?? '',
    );

    priceController = TextEditingController(
      text: widget.service['price']?.toString() ?? '',
    );

    selectedCompanyId = widget.service['companyId'] as int?;

    companiesFuture = apiService.getCompanies();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();

    super.dispose();
  }

  Future<void> updateService() async {
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
      await apiService.updateService(
        id: widget.service['id'] as int,
        companyId: selectedCompanyId!,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service updated successfully!'),
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
        title: const Text('Edit Service'),
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
                'Update Service Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Service ID: ${widget.service['id']}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 28),

              // Company
              const Text(
                'Company',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              FutureBuilder<List<Company>>(
                future: companiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Failed to load companies: ${snapshot.error}',
                    );
                  }

                  final companies = snapshot.data ?? [];

                  if (companies.isEmpty) {
                    return const Text(
                      'No companies available.',
                    );
                  }

                  return DropdownButtonFormField<int>(
                    value: selectedCompanyId,
                    decoration: const InputDecoration(
                      hintText: 'Select company',
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
                  );
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
                controller: nameController,
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
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter service description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
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
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter service price',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixText: 'RM ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null ||
                      !price.isFinite ||
                      price < 0) {
                    return 'Please enter a valid price';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : updateService,

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
