//lib/screens/case_reports.dart


import 'package:disease_tracker/shared/user_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:disease_tracker/providers/report_case_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CaseReportsScreen extends ConsumerWidget {
  const CaseReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseReports = ref.watch(caseReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const StyledText(
          text: "Your Reported Cases",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView.builder(
        itemCount: caseReports.length,
        itemBuilder: (context, index) {
          final report = caseReports[index];
          return ExpansionTile(
            title: Text(
              report.disease == "Other (Specify)"
                  ? report.customDisease ?? "Other"
                  : report.disease,
            ),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(report.onsetDate)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Location", report.location),
                    _buildDetailRow(
                      "Date",
                      DateFormat('MMM dd, yyyy').format(report.onsetDate),
                    ),
                    _buildDetailRow("Severity", report.severity),
                    _buildDetailRow(
                      "Number of Cases",
                      report.numberOfCases.toString(),
                    ),
                    if (report.contactHistory?.isNotEmpty ?? false)
                      _buildDetailRow(
                        "Contact History",
                        report.contactHistory!,
                      ),
                    const SizedBox(height: 8),
                    const StyledText(
                      text: "Symptoms:",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final symptom in report.symptoms)
                          Chip(label: Text(symptom)),
                        if (report.customSymptoms != null)
                          for (final symptom in report.customSymptoms!)
                            if (symptom.isNotEmpty) Chip(label: Text(symptom)),
                      ],
                    ),
                    if (report.photoUrls?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      const StyledText(
                        text: "Photos:",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final url in report.photoUrls!)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (!report.isSynced)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "Not synced",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const UserNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ================== SYNC SERVICE ==================
class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<void> syncReports() async {
   

    // Implement your Firebase sync logic here
    // For each report in unsyncedReports, upload to Firebase

    // After successful sync:
    ref.read(caseReportProvider.notifier).syncReport();
  }
}
