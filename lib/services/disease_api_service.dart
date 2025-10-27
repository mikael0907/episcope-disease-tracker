//lib/services/disease_api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiseaseApiService {
  // COVID-19 API
  static const String covidApiUrl = 'https://disease.sh/v3/covid-19/all';
  
  // WHO Global Health Observatory APIs
  static const String whoBaseUrl = 'https://ghoapi.azureedge.net/api';

  /// Fetch COVID-19 global data
  static Future<Map<String, dynamic>> fetchCovidData() async {
    try {
      final response = await http.get(Uri.parse(covidApiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'disease': 'COVID-19',
          'cases': data['cases'] ?? 0,
          'todayCases': data['todayCases'] ?? 0,
          'deaths': data['deaths'] ?? 0,
          'recovered': data['recovered'] ?? 0,
          'active': data['active'] ?? 0,
        };
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching COVID data: $e');
      return {};
    }
  }

  /// Fetch Tuberculosis data from WHO
  static Future<Map<String, dynamic>> fetchTbData() async {
    try {
      final response = await http.get(Uri.parse('$whoBaseUrl/TB_1'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['value'] as List?;
        
        if (values != null && values.isNotEmpty) {
          final latest = values.first;
          return {
            'disease': 'Tuberculosis',
            'cases': _parseNumericValue(latest['NumericValue']),
            'year': latest['TimeDim'] ?? 'Unknown',
            'region': latest['SpatialDim'] ?? 'Global',
          };
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching TB data: $e');
      return {};
    }
  }

  /// Fetch Malaria data from WHO
  static Future<Map<String, dynamic>> fetchMalariaData() async {
    try {
      final response = await http.get(Uri.parse('$whoBaseUrl/MALARIA_EST_CASES'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['value'] as List?;
        
        if (values != null && values.isNotEmpty) {
          final latest = values.first;
          return {
            'disease': 'Malaria',
            'cases': _parseNumericValue(latest['NumericValue']),
            'year': latest['TimeDim'] ?? 'Unknown',
            'region': latest['SpatialDim'] ?? 'Global',
          };
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching Malaria data: $e');
      return {};
    }
  }

  /// Fetch HIV data from WHO
  static Future<Map<String, dynamic>> fetchHivData() async {
    try {
      final response = await http.get(Uri.parse('$whoBaseUrl/HIV_0000000001'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['value'] as List?;
        
        if (values != null && values.isNotEmpty) {
          final latest = values.first;
          return {
            'disease': 'HIV/AIDS',
            'cases': _parseNumericValue(latest['NumericValue']),
            'year': latest['TimeDim'] ?? 'Unknown',
            'region': latest['SpatialDim'] ?? 'Global',
          };
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching HIV data: $e');
      return {};
    }
  }

  /// Fetch Typhoid data from WHO
  static Future<Map<String, dynamic>> fetchTyphoidData() async {
    try {
      final response = await http.get(Uri.parse('$whoBaseUrl/WHS4_100'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['value'] as List?;
        
        if (values != null && values.isNotEmpty) {
          final latest = values.first;
          return {
            'disease': 'Typhoid',
            'cases': _parseNumericValue(latest['NumericValue']),
            'year': latest['TimeDim'] ?? 'Unknown',
            'region': latest['SpatialDim'] ?? 'Global',
          };
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching Typhoid data: $e');
      return {};
    }
  }

  /// Fetch Cholera data from WHO
  static Future<Map<String, dynamic>> fetchCholeraData() async {
    try {
      final response = await http.get(Uri.parse('$whoBaseUrl/WHS4_544'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['value'] as List?;
        
        if (values != null && values.isNotEmpty) {
          final latest = values.first;
          return {
            'disease': 'Cholera',
            'cases': _parseNumericValue(latest['NumericValue']),
            'year': latest['TimeDim'] ?? 'Unknown',
            'region': latest['SpatialDim'] ?? 'Global',
          };
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching Cholera data: $e');
      return {};
    }
  }

  /// Fetch all trending diseases data
  static Future<List<Map<String, dynamic>>> fetchAllTrendingDiseases() async {
    try {
      final results = await Future.wait([
        fetchCovidData(),
        fetchMalariaData(),
        fetchTbData(),
        fetchHivData(),
        fetchTyphoidData(),
        fetchCholeraData(),
      ]);

      return results.where((data) => data.isNotEmpty).toList();
    } catch (e) {
      debugPrint('Error fetching all diseases: $e');
      return [];
    }
  }

  /// Helper method to parse numeric values
  static int _parseNumericValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }
}