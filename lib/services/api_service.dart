
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/company.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // GET: Retrieve all companies
  Future<List<Company>> getCompanies() async {
    final url = Uri.parse('$baseUrl/companies');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> companyData = responseData['data'];

        return companyData.map((company) {
          return Company.fromJson(company);
        }).toList();
      }

      throw Exception(
        responseData['message'] ?? 'Failed to retrieve companies',
      );
    }

    throw Exception(
      'Failed to load companies: ${response.statusCode}',
    );
  }

  // POST: Create a new company
  Future<Company> createCompany({
    required String name,
    required String registrationNumber,
  }) async {
    final url = Uri.parse('$baseUrl/companies');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'registrationNumber': registrationNumber,
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      if (responseData['success'] == true) {
        return Company.fromJson(responseData['data']);
      }
    }

    throw Exception(
      responseData['message'] ?? 'Failed to create company',
    );
  }


  // PUT: Update an existing company
  Future<Company> updateCompany({
    required int id,
    required String name,
    required String registrationNumber,
  }) async {
    final url = Uri.parse('$baseUrl/companies/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'registrationNumber': registrationNumber,
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return Company.fromJson(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Failed to update company',
    );
  }

  Future<void> deleteCompany(int id) async {
    final url = Uri.parse('$baseUrl/companies/$id');

    final response = await http.delete(url);

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return;
    }

    throw Exception(
      responseData['message'] ?? 'Failed to delete company',
    );
  }

  Future<int> getServicesCount() async {
    final url = Uri.parse('$baseUrl/services');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> services = responseData['data'];

        return services.length;
      }

      throw Exception(
        responseData['message'] ?? 'Failed to retrieve services',
      );
    }

    throw Exception(
      'Failed to load services: ${response.statusCode}',
    );
  }

  Future<List<dynamic>> getServices() async {
    final url = Uri.parse('$baseUrl/services');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body);

      if (responseData['success'] == true) {
        return responseData['data'] as List<dynamic>;
      }

      throw Exception(
        responseData['message'] ?? 'Failed to retrieve services',
      );
    }

    throw Exception(
      'Failed to load services: ${response.statusCode}',
    );
  }

  Future<void> createService({
    required int companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    final url = Uri.parse('$baseUrl/services');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'companyId': companyId,
        'name': name,
        'description': description,
        'price': price,
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      if (responseData['success'] == true) {
        return;
      }
    }

    throw Exception(
      responseData['message'] ?? 'Failed to create service',
    );
  }

  Future<void> updateService({
    required int id,
    required int companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    final url = Uri.parse('$baseUrl/services/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'companyId': companyId,
        'name': name,
        'description': description,
        'price': price,
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return;
    }

    throw Exception(
      responseData['message'] ?? 'Failed to update service',
    );
  }

  Future<void> deleteService(int id) async {
    final url = Uri.parse('$baseUrl/services/$id');

    final response = await http.delete(url);

    final Map<String, dynamic> responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return;
    }

    throw Exception(
      responseData['message'] ?? 'Failed to delete service',
    );
  }

}
