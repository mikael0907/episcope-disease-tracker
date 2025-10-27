//lib/services/disease_reports_service.dart

import 'package:disease_tracker/main.dart';
import 'package:flutter/foundation.dart';

class DiseaseReportsService {
  /// Fetch total number of reports from database
  static Future<int> getTotalReportsCount() async {
    try {
      final response = await supabase
          .from('disease_reports')
          .select();
      
      return response.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching total reports count: $e');
      }
      return 0;
    }
  }

  /// Fetch reports by disease name
  static Future<List<Map<String, dynamic>>> getReportsByDisease() async {
    try {
      final response = await supabase
          .from('disease_reports')
          .select('disease_name');
      
      if (response.isEmpty) {
        return [];
      }
      
      // Count occurrences of each disease
      final diseaseCount = <String, int>{};
      for (var report in response) {
        if (report['disease_name'] != null) {
          final disease = report['disease_name'] as String;
          diseaseCount[disease] = (diseaseCount[disease] ?? 0) + 1;
        }
      }
      
      // Convert to list of maps
      return diseaseCount.entries.map((entry) {
        return {
          'disease': entry.key,
          'cases': entry.value,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reports by disease: $e');
      }
      return [];
    }
  }

  /// Fetch daily new cases for the specified number of days
  static Future<List<Map<String, dynamic>>> getDailyNewCases({int days = 30}) async {
    try {
      final daysAgo = DateTime.now().subtract(Duration(days: days));
      
      final response = await supabase
          .from('disease_reports')
          .select('reported_at')
          .gte('reported_at', daysAgo.toIso8601String());
      
      if (response.isEmpty) {
        return [];
      }
      
      // Group by date
      final dailyCounts = <String, int>{};
      for (var report in response) {
        if (report['reported_at'] != null) {
          final date = DateTime.parse(report['reported_at'] as String);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
        }
      }
      
      // Convert to list and sort by date
      final result = dailyCounts.entries.map((entry) {
        return {
          'date': DateTime.parse(entry.key),
          'count': entry.value,
        };
      }).toList();
      
      result.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching daily new cases: $e');
      }
      return [];
    }
  }

  /// Fetch most recent report timestamp
  static Future<DateTime?> getMostRecentReportTime() async {
    try {
      final response = await supabase
          .from('disease_reports')
          .select('reported_at')
          .order('reported_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        return DateTime.parse(response.first['reported_at'] as String);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching most recent report: $e');
      }
      return null;
    }
  }

  /// Fetch user's report count
  static Future<int> getUserReportsCount(String userId) async {
    try {
      final response = await supabase
          .from('disease_reports')
          .select()
          .eq('user_id', userId);
      
      return response.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user reports count: $e');
      }
      return 0;
    }
  }

  /// Fetch trending diseases (top most reported)
  static Future<List<Map<String, dynamic>>> getTrendingDiseases({int limit = 10}) async {
    try {
      final reports = await getReportsByDisease();
      
      if (reports.isEmpty) {
        return [];
      }
      
      // Sort by cases and take top diseases
      reports.sort((a, b) => (b['cases'] as int).compareTo(a['cases'] as int));
      
      return reports.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching trending diseases: $e');
      }
      return [];
    }
  }

  /// Fetch statistics summary
  static Future<Map<String, dynamic>> getStatisticsSummary() async {
    try {
      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        getTotalReportsCount(),
        getTrendingDiseases(limit: 10),
        getMostRecentReportTime(),
      ]);
      
      return {
        'totalCases': results[0] as int,
        'trendingDiseases': results[1] as List<Map<String, dynamic>>,
        'lastUpdated': results[2] as DateTime? ?? DateTime.now(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching statistics summary: $e');
      }
      return {
        'totalCases': 0,
        'trendingDiseases': <Map<String, dynamic>>[],
        'lastUpdated': DateTime.now(),
      };
    }
  }
}