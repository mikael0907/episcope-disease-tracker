//lib/screens/case_statistics_trend_screen.dart

import 'package:disease_tracker/models/disease_cases_model.dart';
import 'package:disease_tracker/providers/disease_data_provider.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:disease_tracker/shared/theme.dart';
import 'package:disease_tracker/shared/user_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CaseStatisticsAndTrendsScreen extends ConsumerWidget {
  const CaseStatisticsAndTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all necessary providers
    final trendingDiseasesAsync = ref.watch(dbTrendingDiseasesProvider);
    final dailyCasesAsync = ref.watch(dailyNewCasesProvider(30));
    final totalCountAsync = ref.watch(totalReportsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const StyledText(
          text: "Case Statistics & Trends",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh all data
              ref.invalidate(dbTrendingDiseasesProvider);
              ref.invalidate(dailyNewCasesProvider(30));
              ref.invalidate(totalReportsCountProvider);
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dbTrendingDiseasesProvider);
          ref.invalidate(dailyNewCasesProvider(30));
          ref.invalidate(totalReportsCountProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Total Cases Summary Card
                totalCountAsync.when(
                  data: (count) => _buildSummaryCard(context, count),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => _buildErrorCard('Failed to load total count'),
                ),
                const SizedBox(height: 24),

                // Number of Cases by Disease Chart
                trendingDiseasesAsync.when(
                  data: (diseases) => diseases.isNotEmpty
                      ? _numberofCasesByDiseaseChart(context, diseases)
                      : _buildNoDataCard('No disease reports available'),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => _buildErrorCard('Failed to load disease data'),
                ),
                const SizedBox(height: 24),

                // Disease Distribution Pie Chart
                trendingDiseasesAsync.when(
                  data: (diseases) => diseases.isNotEmpty
                      ? _diseaseReports(context, diseases)
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // New Cases Trend Line
                dailyCasesAsync.when(
                  data: (cases) => cases.isNotEmpty
                      ? _newCasesTrendLine(context, cases)
                      : _buildNoDataCard('No daily case data available'),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => _buildErrorCard('Failed to load daily cases'),
                ),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const UserNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int totalCount) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.analytics,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            const Text(
              'Total Reports in Database',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat('#,###').format(totalCount),
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberofCasesByDiseaseChart(BuildContext context, List<DiseaseCases> trendingDiseases) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StyledText(
              text: "Cases by Disease Type",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            const Text(
              'Distribution of reported diseases',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                  labelRotation: -45,
                ),
                primaryYAxis: const NumericAxis(
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF1E293B),
                  ),
                  title: AxisTitle(
                    text: 'Number of Cases',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: const ChartTitle(
                  text: 'Cases by Disease',
                  textStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                legend: const Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  BarSeries<DiseaseCases, String>(
                    xValueMapper: (DiseaseCases data, _) => data.disease,
                    yValueMapper: (DiseaseCases data, _) => data.cases,
                    pointColorMapper: (DiseaseCases data, _) => data.color,
                    dataSource: trendingDiseases,
                    borderRadius: BorderRadius.circular(4),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diseaseReports(BuildContext context, List<DiseaseCases> diseases) {
    // Convert to percentage data for pie chart
    final total = diseases.fold<int>(0, (sum, disease) => sum + disease.cases);
    
    final diseaseReports = diseases.map((disease) {
      final percentage = (disease.cases / total * 100).toStringAsFixed(1);
      return DiseaseReports(
        disease.disease,
        disease.cases,
        '$percentage%',
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StyledText(
              text: "Disease Distribution",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            const Text(
              'Percentage breakdown of reported diseases',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                title: const ChartTitle(
                  text: 'Disease Distribution',
                  textStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  textStyle: TextStyle(fontSize: 11),
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <PieSeries>[
                  PieSeries<DiseaseReports, String>(
                    explode: true,
                    explodeIndex: 0,
                    explodeOffset: '10%',
                    dataSource: diseaseReports,
                    xValueMapper: (DiseaseReports data, _) => data.diseases,
                    yValueMapper: (DiseaseReports data, _) => data.listingPercentage,
                    dataLabelMapper: (DiseaseReports data, _) => data.text,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    pointColorMapper: (DiseaseReports data, int index) {
                      final colors = [
                        const Color(0xFF10B981),
                        const Color(0xFF3B82F6),
                        const Color(0xFFFACC15),
                        const Color(0xFFEF4444),
                        const Color(0xFF8B5CF6),
                      ];
                      return colors[index % colors.length];
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newCasesTrendLine(BuildContext context, List<DailyCases> dailyCases) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StyledText(
              text: "New Cases Over Time",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            Text(
              'Daily trend for the last ${dailyCases.length} days',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.days,
                  dateFormat: DateFormat.MMMd(),
                  title: const AxisTitle(
                    text: 'Date',
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                  ),
                  labelRotation: -45,
                  interval: dailyCases.length > 15 ? 3 : 1,
                ),
                primaryYAxis: const NumericAxis(
                  title: AxisTitle(
                    text: "Number of Cases",
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                ),
                title: const ChartTitle(
                  text: 'New Cases Trend',
                  textStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                legend: const Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y cases',
                ),
                series: <CartesianSeries>[
                  LineSeries<DailyCases, DateTime>(
                    xValueMapper: (DailyCases data, _) => data.date,
                    yValueMapper: (DailyCases data, _) => data.count,
                    color: AppColors.success,
                    width: 3,
                    dataSource: dailyCases,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      width: 8,
                      height: 8,
                      borderWidth: 2,
                      borderColor: Colors.white,
                    ),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(fontFamily: "Poppins", fontSize: 10),
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}