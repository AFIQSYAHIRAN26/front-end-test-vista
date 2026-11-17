
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController searchController =
      TextEditingController();

  late Future<List<dynamic>> servicesFuture;

  @override
  void initState() {
    super.initState();
    servicesFuture = apiService.getServices();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Refresh services
  Future<void> refreshServices() async {
    final newFuture = apiService.getServices();

    setState(() {
      servicesFuture = newFuture;
    });

    await newFuture;
  }

  // Open Edit Service Screen
  Future<void> openEditServiceScreen(
    Map<String, dynamic> service,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          service: service,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await refreshServices();
    }
  }

  // Open Add Service Screen
  Future<void> openAddServiceScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddServiceScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await refreshServices();
    }
  }

  // Show Delete Confirmation
  Future<void> showDeleteConfirmation(
    Map<String, dynamic> service,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Service'),
          content: Text(
            'Are you sure you want to delete "${service['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await apiService.deleteService(service['id'] as int);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      await refreshServices();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete service: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filter services
  List<dynamic> filterServices(List<dynamic> services) {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return services;
    }

    return services.where((service) {
      final name =
          service['name']?.toString().toLowerCase() ?? '';

      final description =
          service['description']?.toString().toLowerCase() ?? '';

      final company =
          service['company']?['name']?.toString().toLowerCase() ?? '';

      final price =
          service['price']?.toString().toLowerCase() ?? '';

      return name.contains(query) ||
          description.contains(query) ||
          company.contains(query) ||
          price.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // App Bar
      appBar: AppBar(
        title: const Text(
          'Service Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // Add Service Button
      floatingActionButton: FloatingActionButton(
        onPressed: openAddServiceScreen,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      // Service List
      body: FutureBuilder<List<dynamic>>(
        future: servicesFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Unable to load services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: refreshServices,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final services = snapshot.data ?? [];
          final filteredServices = filterServices(services);

          // Empty Service List
          if (services.isEmpty) {
            return const Center(
              child: Text('No services found.'),
            );
          }

          return RefreshIndicator(
            onRefresh: refreshServices,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Field
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search services...',

                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),

                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Service List Heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '${filteredServices.length} services found',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // No Matching Services
                  if (filteredServices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'No matching services found.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    )

                  // Service Data Table
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth:
                              MediaQuery.of(context).size.width - 32,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty.all(
                                const Color(0xFF2563EB),
                              ),

                              headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),

                              dataRowMinHeight: 65,
                              dataRowMaxHeight: 90,
                              columnSpacing: 30,

                              // Table Headers
                              columns: const [
                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(70),
                                  label: Center(
                                    child: Text('No.'),
                                  ),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(180),
                                  label: Center(
                                    child: Text('Service Name'),
                                  ),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(180),
                                  label: Center(
                                    child: Text('Company'),
                                  ),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(280),
                                  label: Center(
                                    child: Text('Description'),
                                  ),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(140),
                                  label: Center(
                                    child: Text('Price (RM)'),
                                  ),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(100),
                                  label: Center(
                                    child: Text('Actions'),
                                  ),
                                ),
                              ],

                              // Table Rows
                              rows: filteredServices
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;

                                final service =
                                    Map<String, dynamic>.from(
                                  entry.value as Map,
                                );

                                final company = service['company'];

                                return DataRow(
                                  cells: [
                                    // No.
                                    DataCell(
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text('${index + 1}'),
                                      ),
                                    ),

                                    // Service Name
                                    DataCell(
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text(
                                          service['name']?.toString() ?? '-',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Company
                                    DataCell(
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text(
                                          company?['name']?.toString() ??
                                              'Unknown',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    // Description
                                    DataCell(
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          service['description']?.toString() ??
                                              '-',
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    // Price
                                    DataCell(
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text(
                                          service['price']?.toString() ??
                                              '0.00',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Actions
                                    DataCell(
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF2563EB),
                                              ),
                                              tooltip: 'Edit Service',
                                              onPressed: () {
                                                openEditServiceScreen(
                                                  service,
                                                );
                                              },
                                            ),

                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              tooltip: 'Delete Service',
                                              onPressed: () {
                                                showDeleteConfirmation(
                                                  service,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
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
