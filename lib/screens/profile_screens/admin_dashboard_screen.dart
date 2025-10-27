//lib/screens/profile_screens/admin_dashboard_screen.dart

import 'package:disease_tracker/models/case_report_models.dart';
import 'package:disease_tracker/models/research_access_model.dart';
import 'package:disease_tracker/providers/controllers/auth_provider.dart';
import 'package:disease_tracker/providers/controllers/research_access/research_access_provider.dart';
import 'package:disease_tracker/providers/report_case_provider.dart';
import 'package:disease_tracker/shared/admin_navigation_bar.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentTabIndex = 0;
  final List<String> _tabTitles = [
    'Dashboard',
    'Pending',
    'Confirmed',
    'Rejected',
    'False',
    'Management',
    'Research Requests',
  ];

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(caseReportProvider);
    final pendingReports =
        ref.watch(caseReportProvider.notifier).getPendingReports();
    final confirmedReports = ref
        .watch(caseReportProvider.notifier)
        .getReportsByStatus('Confirmed');
    final rejectedReports = ref
        .watch(caseReportProvider.notifier)
        .getReportsByStatus('Rejected');
    final falseReports = ref
        .watch(caseReportProvider.notifier)
        .getReportsByStatus('False');

    return Scaffold(
      appBar: AppBar(
        title: const StyledText(
          text: "Admin Dashboard",
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Segmented Navigation
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SegmentedButton<int>(
                segments:
                    _tabTitles.asMap().entries.map((entry) {
                      return ButtonSegment<int>(
                        value: entry.key,
                        label: Text(entry.value),
                      );
                    }).toList(),
                selected: {_currentTabIndex},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _currentTabIndex = newSelection.first;
                  });
                },
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: _buildCurrentTabContent(
              context,
              reports: reports,
              pendingReports: pendingReports,
              confirmedReports: confirmedReports,
              rejectedReports: rejectedReports,
              falseReports: falseReports,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildCurrentTabContent(
    BuildContext context, {
    required List<CaseReport> reports,
    required List<CaseReport> pendingReports,
    required List<CaseReport> confirmedReports,
    required List<CaseReport> rejectedReports,
    required List<CaseReport> falseReports,
  }) {
    switch (_currentTabIndex) {
      case 0: // Dashboard
        return _buildDashboardView(
          context,
          reports: reports,
          pendingReports: pendingReports,
          confirmedReports: confirmedReports,
          rejectedReports: rejectedReports,
          falseReports: falseReports,
        );
      case 1: // Pending
        return _buildReportsListView(context, pendingReports, true);
      case 2: // Confirmed
        return _buildReportsListView(context, confirmedReports);
      case 3: // Rejected
        return _buildReportsListView(context, rejectedReports);
      case 4: // False
        return _buildReportsListView(context, falseReports);
      case 5: // Management
        return _buildManagementSection(context);
      case 6: // Research Requests
        return _buildResearchRequestSection(context);
      default:
        return const Center(child: Text('Select a tab'));
    }
  }

  Widget _buildDashboardView(
    BuildContext context, {
    required List<CaseReport> reports,
    required List<CaseReport> pendingReports,
    required List<CaseReport> confirmedReports,
    required List<CaseReport> rejectedReports,
    required List<CaseReport> falseReports,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(context, reports),
          const SizedBox(height: 24),
          _buildReportsCard(
            context,
            "Pending Case Reports",
            pendingReports,
            showActions: true,
          ),
          const SizedBox(height: 16),
          _buildReportsCard(context, "Confirmed Cases", confirmedReports),
          const SizedBox(height: 16),
          _buildReportsCard(context, "Rejected Reports", rejectedReports),
          const SizedBox(height: 16),
          _buildReportsCard(context, "False Reports", falseReports),
          const SizedBox(height: 24),
          Center(
            child: StyledButton(
              text: "Logout",
              onPressed:
                  () => ref.read(authControllerProvider.notifier).signOut(),
              color: const Color(0xFFEF4444),
              icon: Icons.logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsListView(
    BuildContext context,
    List<CaseReport> reports, [
    bool showActions = false,
  ]) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No reports found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReportItem(context, reports[index], showActions),
        );
      },
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    List<CaseReport> reports,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StyledText(
              text: "Case Statistics & Trends",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  "Total Reports",
                  reports.length.toString(),
                ),
                _buildStatItem(
                  context,
                  "Pending",
                  reports.where((r) => r.status == 'Pending').length.toString(),
                ),
                _buildStatItem(
                  context,
                  "Confirmed",
                  reports
                      .where((r) => r.status == 'Confirmed')
                      .length
                      .toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildReportsCard(
    BuildContext context,
    String title,
    List<CaseReport> reports, {
    bool showActions = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: StyledText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${reports.length} items"),
              ],
            ),
            const SizedBox(height: 12),
            if (reports.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("No reports found"),
              )
            else
              Column(
                children: [
                  for (final report in reports.take(3))
                    _buildReportItem(context, report, showActions),
                  if (reports.length > 3)
                    TextButton(
                      onPressed: () {
                        _showAllReportsDialog(
                          context,
                          title,
                          reports,
                          showActions,
                        );
                      },
                      child: const Text("View All"),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    CaseReport report,
    bool showActions,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.disease == "Other (Specify)" 
                      ? report.customDisease ?? "Other" 
                      : report.disease,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.status,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "ID: ${report.id.substring(0, 8)}...",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text("Reported by: ${report.userName}"),
          Text(
            "Location: ${report.location}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text("Date: ${DateFormat('MMM dd, yyyy').format(report.onsetDate)}"),
          Text("Severity: ${report.severity}"),
          Text("Cases: ${report.numberOfCases}"),
          if (showActions) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Confirm"),
                    onPressed: () => _updateReportStatus(context, report, 'Confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text("Reject"),
                    onPressed: () => _updateReportStatus(context, report, 'Rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.warning, size: 16),
                    label: const Text("False"),
                    onPressed: () => _updateReportStatus(context, report, 'False'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'False':
        return Colors.orange;
      default: // Pending
        return Colors.blue;
    }
  }

  void _updateReportStatus(
    BuildContext context,
    CaseReport report,
    String newStatus,
  ) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Report Status'),
        content: Text(
          'Are you sure you want to mark this report as $newStatus?\n\n'
          'Disease: ${report.disease == "Other (Specify)" ? report.customDisease : report.disease}\n'
          'Reported by: ${report.userName}\n'
          'ID: ${report.id.substring(0, 8)}...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Update the specific report status
              ref
                  .read(caseReportProvider.notifier)
                  .updateReportStatus(report.id, newStatus);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Report ${report.id.substring(0, 8)}... marked as $newStatus"),
                  backgroundColor: _getStatusColor(newStatus),
                ),
              );

              // Refresh the UI
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatus),
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showAllReportsDialog(
    BuildContext context,
    String title,
    List<CaseReport> reports,
    bool showActions,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              children: [
                AppBar(
                  title: Text(title),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      return _buildReportItem(
                        context,
                        reports[index],
                        showActions,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StyledText(
                text: "Management & Actions",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildManagementButton(
                    context,
                    "Manage Users",
                    Icons.group,
                    onPressed: () {
                      // Navigate to user management
                    },
                  ),
                  _buildManagementButton(
                    context,
                    "Verify Cases",
                    Icons.verified_user,
                    onPressed: () {
                      // Navigate to pending cases
                      setState(() {
                        _currentTabIndex = 1;
                      });
                    },
                  ),
                  _buildManagementButton(
                    context,
                    "System Logs",
                    Icons.history,
                    onPressed: () {
                      // Navigate to system logs
                    },
                  ),
                  _buildManagementButton(
                    context,
                    "Alert Settings",
                    Icons.tune,
                    onPressed: () {
                      // Navigate to alert settings
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementButton(
    BuildContext context,
    String text,
    IconData icon, {
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      style: ElevatedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildResearchRequestSection(BuildContext context) {
    final pendingRequests =
        ref
            .watch(researchAccessControllerProvider.notifier)
            .getPendingRequests();
    final approvedRequests =
        ref
            .watch(researchAccessControllerProvider.notifier)
            .getApprovedRequests();
    final rejectedRequests =
        ref
            .watch(researchAccessControllerProvider.notifier)
            .getRejectedRequests();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                child: Badge(
                  isLabelVisible: pendingRequests.isNotEmpty,
                  label: Text(pendingRequests.length.toString()),
                  child: const Text('Pending'),
                ),
              ),
              const Tab(text: 'Approved'),
              const Tab(text: 'Rejected'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRequestList(pendingRequests, true),
                _buildRequestList(approvedRequests, false),
                _buildRequestList(rejectedRequests, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(
    List<ResearchAccessRequest> requests,
    bool showActions,
  ) {
    if (requests.isEmpty) {
      return const Center(child: Text('No requests found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              request.researchTopic,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('By: ${request.fullName}'),
                Text('Institution: ${request.institution}'),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(request.requestDate)}',
                ),
              ],
            ),
            trailing:
                showActions
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed:
                              () => ref
                                  .read(
                                    researchAccessControllerProvider.notifier,
                                  )
                                  .updateRequestStatus(request.id, 'Approved'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed:
                              () => ref
                                  .read(
                                    researchAccessControllerProvider.notifier,
                                  )
                                  .updateRequestStatus(request.id, 'Rejected'),
                        ),
                      ],
                    )
                    : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            request.status == 'Approved'
                                ? Colors.green
                                : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.status,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
          ),
        );
      },
    );
  }
}