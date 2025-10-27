//lib/providers/disease_data_provider.dart

import 'package:disease_tracker/models/disease_cases_model.dart';
import 'package:disease_tracker/services/disease_api_service.dart';
import 'package:disease_tracker/services/disease_reports_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Combined provider for home screen data (API + Database)
final homeScreenDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    // Fetch API data and Database data in parallel
    final results = await Future.wait([
      DiseaseApiService.fetchCovidData(),
      DiseaseApiService.fetchMalariaData(),
      DiseaseApiService.fetchTbData(),
      DiseaseApiService.fetchHivData(),
      DiseaseApiService.fetchTyphoidData(),
      DiseaseApiService.fetchCholeraData(),
      DiseaseReportsService.getStatisticsSummary(),
      DiseaseReportsService.getDailyNewCases(days: 30),
    ]);
    
    // API disease data
    final covidData = results[0] as Map<String, dynamic>;
    final malariaData = results[1] as Map<String, dynamic>;
    final tbData = results[2] as Map<String, dynamic>;
    final hivData = results[3] as Map<String, dynamic>;
    final typhoidData = results[4] as Map<String, dynamic>;
    final choleraData = results[5] as Map<String, dynamic>;
    
    // Database data
    final dbSummary = results[6] as Map<String, dynamic>;
    final dailyCases = results[7] as List<Map<String, dynamic>>;
    
    // Combine API diseases with database diseases
    final allDiseases = <String, int>{};
    
    // Add API data - only if we get valid data
    if (covidData.isNotEmpty && covidData['cases'] != null) {
      final covidCases = covidData['cases'] as int;
      if (covidCases > 0) {
        allDiseases['COVID-19'] = covidCases;
      }
    }
    if (malariaData.isNotEmpty && malariaData['cases'] != null) {
      final malariaCases = malariaData['cases'] as int;
      if (malariaCases > 0) {
        allDiseases['Malaria'] = malariaCases;
      }
    }
    if (tbData.isNotEmpty && tbData['cases'] != null) {
      final tbCases = tbData['cases'] as int;
      if (tbCases > 0) {
        allDiseases['Tuberculosis'] = tbCases;
      }
    }
    if (hivData.isNotEmpty && hivData['cases'] != null) {
      final hivCases = hivData['cases'] as int;
      if (hivCases > 0) {
        allDiseases['HIV/AIDS'] = hivCases;
      }
    }
    if (typhoidData.isNotEmpty && typhoidData['cases'] != null) {
      final typhoidCases = typhoidData['cases'] as int;
      if (typhoidCases > 0) {
        allDiseases['Typhoid'] = typhoidCases;
      }
    }
    if (choleraData.isNotEmpty && choleraData['cases'] != null) {
      final choleraCases = choleraData['cases'] as int;
      if (choleraCases > 0) {
        allDiseases['Cholera'] = choleraCases;
      }
    }
    
    // Add database diseases
    final dbDiseases = dbSummary['trendingDiseases'] as List<Map<String, dynamic>>;
    for (var disease in dbDiseases) {
      final name = disease['disease'] as String;
      final cases = disease['cases'] as int;
      
      // If disease already exists from API, add the counts together
      if (allDiseases.containsKey(name)) {
        allDiseases[name] = (allDiseases[name] ?? 0) + cases;
      } else {
        allDiseases[name] = cases;
      }
    }
    
    // If no API data was found, use only database data
    if (allDiseases.isEmpty) {
      for (var disease in dbDiseases) {
        final name = disease['disease'] as String;
        final cases = disease['cases'] as int;
        allDiseases[name] = cases;
      }
    }
    
    return {
      'totalCases': dbSummary['totalCases'] as int,
      'lastUpdated': dbSummary['lastUpdated'] as DateTime,
      'trendingDiseases': allDiseases,
      'dailyCases': dailyCases,
    };
  } catch (e) {
    debugPrint('Error in homeScreenDataProvider: $e');
    // Fallback to database only if API fails
    try {
      final dbSummary = await DiseaseReportsService.getStatisticsSummary();
      final dailyCases = await DiseaseReportsService.getDailyNewCases(days: 30);
      
      final dbDiseases = dbSummary['trendingDiseases'] as List<Map<String, dynamic>>;
      final allDiseases = <String, int>{};
      
      for (var disease in dbDiseases) {
        final name = disease['disease'] as String;
        final cases = disease['cases'] as int;
        allDiseases[name] = cases;
      }
      
      return {
        'totalCases': dbSummary['totalCases'] as int,
        'lastUpdated': dbSummary['lastUpdated'] as DateTime,
        'trendingDiseases': allDiseases,
        'dailyCases': dailyCases,
      };
    } catch (fallbackError) {
      debugPrint('Fallback also failed: $fallbackError');
      return {
        'totalCases': 0,
        'lastUpdated': DateTime.now(),
        'trendingDiseases': <String, int>{},
        'dailyCases': <Map<String, dynamic>>[],
      };
    }
  }
});

// Provider for database reports count
final totalReportsCountProvider = FutureProvider<int>((ref) async {
  return await DiseaseReportsService.getTotalReportsCount();
});

// Provider for trending diseases from database ONLY (for case statistics screen)
final dbTrendingDiseasesProvider = FutureProvider<List<DiseaseCases>>((ref) async {
  final data = await DiseaseReportsService.getTrendingDiseases(limit: 10);
  
  final colors = [
    const Color(0xFF10B981),
    const Color(0xFF3B82F6),
    const Color(0xFFFACC15),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFF84CC16),
    const Color(0xFFF97316),
  ];
  
  return data.asMap().entries.map((entry) {
    return DiseaseCases(
      entry.value['disease'] as String,
      entry.value['cases'] as int,
      colors[entry.key % colors.length],
    );
  }).toList();
});

// Provider for daily new cases
final dailyNewCasesProvider = FutureProvider.family<List<DailyCases>, int>((ref, days) async {
  final data = await DiseaseReportsService.getDailyNewCases(days: days);
  
  return data.map((item) {
    return DailyCases(
      item['date'] as DateTime,
      item['count'] as int,
    );
  }).toList();
});

// Provider for user's report count
final userReportsCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  return await DiseaseReportsService.getUserReportsCount(userId);
});