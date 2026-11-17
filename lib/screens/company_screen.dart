
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/company.dart';
import '../services/api_service.dart';
import 'add_company_screen.dart';
import 'edit_company_screen.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController searchController =
      TextEditingController();

  late Future<List<Company>> companiesFuture;

  Timer? refreshTimer;

  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // Initial company loading
    companiesFuture = apiService.getCompanies();

    // Automatically refresh every 5 seconds
    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        refreshCompanies(showError: false);
      },
    );
  }

  // Refresh company records
  Future<void> refreshCompanies({
    bool showError = true,
  }) async {
    // Prevent overlapping API requests
    if (isRefreshing) return;

    isRefreshing = true;

    try {
      // Request latest company records from backend
      final updatedCompanies = await apiService.getCompanies();

      if (!mounted) return;

      // Update the screen after successful retrieval
      setState(() {
        companiesFuture = Future.value(updatedCompanies);
      });
    } catch (error) {
      // Show error only for manual refresh
      if (mounted && showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to refresh companies: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isRefreshing = false;
    }
  }

  // Search companies
  List<Company> filterCompanies(List<Company> companies) {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return companies;
    }

    return companies.where((company) {
      final name = company.name.toLowerCase();

      final registrationNumber =
          company.registrationNumber.toLowerCase();

      return name.contains(query) ||
          registrationNumber.contains(query);
    }).toList();
  }

  // Add company
  Future<void> openAddCompanyScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCompanyScreen(),
      ),
    );

    if (result == true) {
      await refreshCompanies();
    }
  }

  // Edit company
  Future<void> openEditCompanyScreen(Company company) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCompanyScreen(
          company: company,
        ),
      ),
    );

    if (result == true) {
      await refreshCompanies();
    }
  }

  // Delete confirmation
  Future<void> showDeleteConfirmation(Company company) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Company?'),
          content: Text(
            'Are you sure you want to delete ${company.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await apiService.deleteCompany(company.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      await refreshCompanies();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Stop automatic refreshing
    refreshTimer?.cancel();

    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // App Bar
      appBar: AppBar(
        title: const Text(
          'Company Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // Add Company Button
      floatingActionButton: FloatingActionButton(
        onPressed: openAddCompanyScreen,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: FutureBuilder<List<Company>>(
        future: companiesFuture,

        builder: (context, snapshot) {

          // Initial Loading
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError && !snapshot.hasData) {
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
                      'Unable to load companies',
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
                      onPressed: refreshCompanies,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final companies = snapshot.data ?? [];

          final filteredCompanies = filterCompanies(companies);

          // Company List
          return RefreshIndicator(
            onRefresh: refreshCompanies,

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // Search Bar
                  TextField(
                    controller: searchController,

                    onChanged: (value) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      hintText: 'Search companies...',

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

                  // Table Heading and Result Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Company List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '${filteredCompanies.length} companies found',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // No Matching Companies
                  if (filteredCompanies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'No matching companies found.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    )

                  // Companies Table
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth:
                              MediaQuery.of(context).size.width - 32,
                        ),

                        // Rounded Table Border
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),

                          // Clip rounded corners
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

                              // Table Columns
                              columns: const [
                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(70),
                                  label: Text('No.'),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(220),
                                  label: Text('Company Name'),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(220),
                                  label: Text('Registration Number'),
                                ),

                                DataColumn(
                                  headingRowAlignment:
                                      MainAxisAlignment.center,
                                  columnWidth: FixedColumnWidth(160),
                                  label: Text('Actions'),
                                ),
                              ],

                              // Table Rows
                              rows: filteredCompanies
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final company = entry.value;

                                return DataRow(
                                  cells: [

                                    // Number
                                    DataCell(
                                      Center(
                                        child: Text('${index + 1}'),
                                      ),
                                    ),

                                    // Company Name
                                    DataCell(
                                      Center(
                                        child: Text(
                                          company.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Registration Number
                                    DataCell(
                                      Center(
                                        child: Text(
                                          company.registrationNumber,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    // Edit and Delete Buttons
                                    DataCell(
                                      Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [

                                            // Edit Button
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF2563EB),
                                              ),
                                              tooltip: 'Edit Company',
                                              onPressed: () {
                                                openEditCompanyScreen(
                                                  company,
                                                );
                                              },
                                            ),

                                            // Delete Button
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              tooltip: 'Delete Company',
                                              onPressed: () {
                                                showDeleteConfirmation(
                                                  company,
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