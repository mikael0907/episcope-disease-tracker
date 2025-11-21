//lib/screens/home.dart

import 'package:disease_tracker/models/disease_cases_model.dart';
import 'package:disease_tracker/providers/controllers/current_user_provider.dart';
import 'package:disease_tracker/providers/disease_data_provider.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:disease_tracker/shared/theme.dart';
import 'package:disease_tracker/shared/user_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int _selectedDaysFilter = 30; // Default to 30 days

  @override
  Widget build(BuildContext context) {
    // Get current user from provider
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.firstName ?? 'User';
    final isAdmin =
        currentUser?.role == 'admin' || currentUser?.role == 'government';

    // Watch home screen data
    final homeDataAsync = ref.watch(homeScreenDataProvider);

    return Scaffold(
      backgroundColor: AppThemes.light.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppThemes.light.primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/img/episcope_favicon.png',
            height: 26,
            width: 26,
          ),
        ),
        title: const StyledText(
          text: "EpiVigil",
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 28,
              color: Colors.white,
            ),
            tooltip: "Notifications",
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: StyledText(
              text: "Welcome, $userName",
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: homeDataAsync.when(
        data:
            (homeData) =>
                _buildHomeContent(context, homeData, currentUser?.id, isAdmin),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading data: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(homeScreenDataProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
      bottomNavigationBar: const UserNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    Map<String, dynamic> homeData,
    String? userId,
    bool isAdmin,
  ) {
    final totalCases = homeData['totalCases'] as int;
    final lastUpdated = homeData['lastUpdated'] as DateTime;
    final trendingDiseases = homeData['trendingDiseases'] as Map<String, int>;

    // Watch daily cases based on selected filter
    final dailyCasesAsync = ref.watch(
      dailyNewCasesProvider(_selectedDaysFilter),
    );

    // Get user's report count
    final userReportsAsync =
        userId != null
            ? ref.watch(userReportsCountProvider(userId))
            : const AsyncValue.data(0);

    // Convert trending diseases to chart data
    final colors = [
      const Color(0xFF10B981), // Green
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFFACC15), // Yellow
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF84CC16), // Lime
      const Color(0xFFF97316), // Orange
      const Color(0xFF6366F1), // Indigo
    ];

    // Process trending diseases - ensure we have proper data
    //lib/screens/home.dart

    // Replace lines 133-141 with this:

    // Process trending diseases - ensure we have proper data
    final trendingDiseasesEntries =
        trendingDiseases.entries.where((entry) => entry.value > 0).toList();

    trendingDiseasesEntries.sort((a, b) => b.value.compareTo(a.value));

    final trendingDiseasesList =
        trendingDiseasesEntries.take(5).toList().asMap().entries.map((entry) {
          final diseaseEntry = entry.value;
          final diseaseName = diseaseEntry.key;
          final cases = diseaseEntry.value;
          final color = colors[entry.key % colors.length];

          return DiseaseCases(diseaseName, cases, color);
        }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(homeScreenDataProvider);
        ref.invalidate(dailyNewCasesProvider(_selectedDaysFilter));
        if (userId != null) {
          ref.invalidate(userReportsCountProvider(userId));
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _createTotalCases(context, totalCases, lastUpdated),
            const SizedBox(height: 24),

            // Add Admin Access Card if user is admin
            if (isAdmin) ...[
              _buildAdminAccessCard(context),
              const SizedBox(height: 24),
            ],

            // Show trending diseases chart only if we have data
            if (trendingDiseasesList.isNotEmpty) ...[
              _trendingDiseasesChart(trendingDiseasesList),
              const SizedBox(height: 24),
            ] else ...[
              _buildNoDataCard(
                'No disease data available. Reports will appear here once users start reporting cases.',
              ),
              const SizedBox(height: 24),
            ],

            // Daily cases chart with filter
            dailyCasesAsync.when(
              data:
                  (dailyCases) =>
                      dailyCases.isNotEmpty
                          ? _newDailyCasesChart(dailyCases)
                          : _buildNoDataCard(
                            'No daily case data available for the selected period',
                          ),
              loading:
                  () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              error:
                  (error, stack) =>
                      _buildErrorCard('Failed to load daily cases'),
            ),
            const SizedBox(height: 24),

            userReportsAsync.when(
              data: (count) => _yourReportsCard(context, count),
              loading:
                  () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              error: (error, stack) => _yourReportsCard(context, 0),
            ),
            const SizedBox(height: 24),
            StyledButton(
              icon: Icons.report,
              text: "Report A Case",
              onPressed: () {
                Navigator.pushNamed(context, '/report');
              },
            ),
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _createTotalCases(
    BuildContext context,
    int totalCases,
    DateTime lastUpdated,
  ) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeAgo =
          '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      timeAgo =
          '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      timeAgo =
          '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const StyledText(
            text: "Total Cases Reported",
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          StyledText(
            text: NumberFormat('#,###').format(totalCases),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          StyledText(
            text: "Updated $timeAgo",
            fontSize: 14,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAccessCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(
                Icons.admin_panel_settings,
                color: Colors.blue,
                size: 40,
              ),
              title: Text(
                'Admin Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text('Manage reports and system settings'),
            ),
            const SizedBox(height: 8),
            StyledButton(
              text: "Open Admin Dashboard",
              onPressed: () {
                Navigator.pushNamed(context, '/admin-dashboard');
              },
              color: Colors.blue,
              icon: Icons.dashboard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _trendingDiseasesChart(List<DiseaseCases> trendingDiseases) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  "Trending Diseases",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Most reported diseases in the system',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: SfCartesianChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF1E293B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  labelRotation: -45,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF1E293B),
                  ),
                  title: const AxisTitle(text: 'Number of Cases'),
                  majorGridLines: const MajorGridLines(
                    width: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : point.y cases',
                  header: 'Disease Cases',
                ),
                series: <CartesianSeries<DiseaseCases, String>>[
                  BarSeries<DiseaseCases, String>(
                    dataSource: trendingDiseases,
                    xValueMapper: (DiseaseCases data, _) => data.disease,
                    yValueMapper: (DiseaseCases data, _) => data.cases,
                    color: const Color(0xFF3B82F6),
                    pointColorMapper: (DiseaseCases data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    width: 0.6,
                    spacing: 0.2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDiseaseLegend(trendingDiseases),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseLegend(List<DiseaseCases> diseases) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          diseases.asMap().entries.map((entry) {
            final disease = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: disease.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key + 1}. ${disease.disease}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _newDailyCasesChart(List<DailyCases> dailyCases) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const StyledText(
                  text: "New Cases (Daily)",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                // Time frame selector
                DropdownButton<int>(
                  value: _selectedDaysFilter,
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('Last 7 Days')),
                    DropdownMenuItem(value: 14, child: Text('Last 14 Days')),
                    DropdownMenuItem(value: 30, child: Text('Last 30 Days')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDaysFilter = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Daily trend for the last $_selectedDaysFilter days',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                legend: const Legend(isVisible: false),
                primaryXAxis: DateTimeAxis(
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF1E293B),
                    fontSize: 10,
                  ),
                  dateFormat: DateFormat('MM/dd'),
                  intervalType: DateTimeIntervalType.days,
                  interval: dailyCases.length > 15 ? 3 : 1,
                  labelRotation: -45,
                ),
                primaryYAxis: const NumericAxis(
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF1E293B),
                  ),
                  title: AxisTitle(text: 'Cases'),
                ),
                series: <CartesianSeries>[
                  LineSeries<DailyCases, DateTime>(
                    dataSource: dailyCases,
                    xValueMapper: (DailyCases data, _) => data.date,
                    yValueMapper: (DailyCases data, _) => data.count,
                    color: const Color(0xFF3B82F6),
                    width: 3,
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
                      textStyle: TextStyle(fontFamily: 'Poppins', fontSize: 9),
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y cases',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yourReportsCard(BuildContext context, int userReportedCases) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StyledText(
              text: 'Your Reports',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NumberFormat('#,###').format(userReportedCases),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Cases Logged',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                StyledButton(
                  text: "View All",
                  onPressed: () {
                    Navigator.pushNamed(context, '/cases');
                  },
                  color: const Color(0xFF10B981),
                ),
              ],
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
