//lib/models/case_report_models.dart


class Disease {
  final String category;
  final List<String> diseases;

  Disease({required this.category, required this.diseases});
}

class SymptomCategory {
  final String category;
  final List<String> symptoms;

  SymptomCategory({required this.category, required this.symptoms});
}

// In your models/case_report_models.dart - Replace the entire CaseReport class

class CaseReport {
  final String id;
  final String disease;
  final String? customDisease;
  final String location;
  final List<String> symptoms;
  final List<String>? customSymptoms;
  final String severity;
  final DateTime onsetDate;
  final String? contactHistory;
  final int numberOfCases;
  final List<String>? photoUrls;
  final bool isSynced;
  final String userId;
  final String userName;
  final String userEmail;
  final String status;

  CaseReport({
    required this.id,
    required this.disease,
    this.customDisease,
    required this.location,
    required this.symptoms,
    this.customSymptoms,
    required this.severity,
    required this.onsetDate,
    this.contactHistory,
    required this.numberOfCases,
    this.photoUrls,
    this.isSynced = false,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'disease': disease,
      'customDisease': customDisease,
      'location': location,
      'symptoms': symptoms,
      'customSymptoms': customSymptoms,
      'severity': severity,
      'onsetDate': onsetDate.toIso8601String(),
      'contactHistory': contactHistory,
      'numberOfCases': numberOfCases,
      'photoUrls': photoUrls,
      'isSynced': isSynced,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'status': status,
    };
  }

  static CaseReport fromMap(Map<String, dynamic> map) {
    return CaseReport(
      id: map['id'] ?? '',
      disease: map['disease'],
      customDisease: map['customDisease'],
      location: map['location'],
      symptoms: List<String>.from(map['symptoms']),
      customSymptoms: map['customSymptoms'] != null
          ? List<String>.from(map['customSymptoms'])
          : null,
      severity: map['severity'],
      onsetDate: DateTime.parse(map['onsetDate']),
      contactHistory: map['contactHistory'],
      numberOfCases: map['numberOfCases'],
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls']) : null,
      isSynced: map['isSynced'] ?? false,
      userId: map['userId'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      status: map['status'] ?? 'Pending',
    );
  }
}

class CaseReportSummary {
  final String disease;
  final int numberOfCases;

  CaseReportSummary(this.disease, this.numberOfCases);

  Map<String, dynamic> toMap() {
    return {"disease": disease, "numberOfCases": numberOfCases};
  }

  static CaseReportSummary fromMap(Map<String, dynamic> map) {
    return CaseReportSummary(map['disease'], map['numberOfCases']);
  }
}
