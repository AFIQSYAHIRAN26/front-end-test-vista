
import 'package:flutter/material.dart';

import 'models/company.dart';
import 'services/api_service.dart';
import 'screens/company_screen.dart';
import 'screens/service_screen.dart';

void main() {
  runApp(const VistaApp());
}

class VistaApp extends StatelessWidget {
  const VistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vista Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

// ============================================================
// DASHBOARD SCREEN
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService apiService = ApiService();

  late Future<List<Company>> companiesFuture;
  late Future<int> servicesCountFuture;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // Load dashboard statistics
  void loadDashboardData() {
    companiesFuture = apiService.getCompanies();
    servicesCountFuture = apiService.getServicesCount();
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    setState(() {
      loadDashboardData();
    });

    try {
      await Future.wait([
        companiesFuture,
        servicesCountFuture,
      ]);
    } catch (_) {
      // Errors are displayed by the FutureBuilder widgets.
    }
  }

  // Open management screen
  Future<void> openManagementScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );

    if (!mounted) return;

    setState(() {
      loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'VISTA',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: refreshDashboard,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF475569),
            ),
          ),

          const SizedBox(width: 8),

          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFDBEAFE),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF2563EB),
                size: 21,
              ),
            ),
          ),
        ],
      ),

      // DASHBOARD BODY
      body: RefreshIndicator(
        onRefresh: refreshDashboard,
        color: const Color(0xFF2563EB),

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // WELCOME BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                      Color(0xFF1E40AF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB)
                          .withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MANAGEMENT PORTAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Welcome to Vista!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Manage your companies and services '
                      'from one centralised dashboard.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 18,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          'Your business overview at a glance',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // OVERVIEW SECTION
              const SectionHeader(
                title: 'Overview',
                subtitle: 'Summary of your registered data',
              ),

              const SizedBox(height: 16),

              // STATISTICS CARDS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // COMPANIES
                  Expanded(
                    child: FutureBuilder<List<Company>>(
                      future: companiesFuture,

                      builder: (context, snapshot) {
                        String value = '...';
                        String description = 'Loading data';

                        if (snapshot.hasData) {
                          value = snapshot.data!.length.toString();
                          description = 'Registered companies';
                        } else if (snapshot.hasError) {
                          value = '—';
                          description = 'Unable to load';
                        }

                        return DashboardStatCard(
                          title: 'Companies',
                          value: value,
                          description: description,
                          icon: Icons.business_rounded,
                          iconColor: const Color(0xFF2563EB),
                          iconBackground: const Color(0xFFDBEAFE),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // SERVICES
                  Expanded(
                    child: FutureBuilder<int>(
                      future: servicesCountFuture,

                      builder: (context, snapshot) {
                        String value = '...';
                        String description = 'Loading data';

                        if (snapshot.hasData) {
                          value = snapshot.data.toString();
                          description = 'Available services';
                        } else if (snapshot.hasError) {
                          value = '—';
                          description = 'Unable to load';
                        }

                        return DashboardStatCard(
                          title: 'Services',
                          value: value,
                          description: description,
                          icon: Icons.miscellaneous_services_rounded,
                          iconColor: const Color(0xFF16A34A),
                          iconBackground: const Color(0xFFDCFCE7),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // MANAGEMENT SECTION
              const SectionHeader(
                title: 'Management',
                subtitle: 'Manage your business information',
              ),

              const SizedBox(height: 16),

              // COMPANY MANAGEMENT
              ManagementCard(
                title: 'Company Management',
                description:
                    'View, register, update and manage companies.',
                icon: Icons.business_outlined,
                iconColor: const Color(0xFF2563EB),
                iconBackground: const Color(0xFFDBEAFE),
                onTap: () => openManagementScreen(
                  const CompanyScreen(),
                ),
              ),

              const SizedBox(height: 14),

              // SERVICE MANAGEMENT
              ManagementCard(
                title: 'Service Management',
                description:
                    'View, create, update and manage services.',
                icon: Icons.miscellaneous_services_outlined,
                iconColor: const Color(0xFF16A34A),
                iconBackground: const Color(0xFFDCFCE7),
                onTap: () => openManagementScreen(
                  const ServiceScreen(),
                ),
              ),

              const SizedBox(height: 28),

              // INFORMATION SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE8EDF5),
                  ),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Vista',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Vista provides a centralised platform '
                            'to manage company information and '
                            'their associated services.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FOOTER
              const Center(
                child: Text(
                  'VISTA MANAGEMENT SYSTEM  •  VERSION 1.0',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DASHBOARD STATISTICS CARD
// ============================================================

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EDF5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MANAGEMENT CARD
// ============================================================

class ManagementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const ManagementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8EDF5),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF94A3B8),
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
