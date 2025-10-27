class ResearchAccessRequest {
  final String id;
  final String fullName;
  final String institution;
  final String researchTopic;
  final String ethicalApprovalPath;
  final bool hasConsent;
  final String userId;
  final String
  userEmail; //Automatically autofilled from the person's email used to signup or an option beside it, "Use another email" which onClick would allow the person input a different email of his or her choice. Note this and implement it asap
  final String status;
  final DateTime requestDate;

  ResearchAccessRequest({
    required this.id,
    required this.fullName,
    required this.institution,
    required this.researchTopic,
    required this.ethicalApprovalPath,
    required this.hasConsent,
    required this.userId,
    required this.userEmail,
    this.status = 'Pending',
    required this.requestDate,
  });

  ResearchAccessRequest copyWith({
    String? id,
    String? fullName,
    String? institution,
    String? researchTopic,
    String? ethicalApprovalPath,
    bool? hasConsent,
    String? userId,
    String? userEmail,
    String? status,
    DateTime? requestDate,
  }) {
    return ResearchAccessRequest(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      institution: institution ?? this.institution,
      researchTopic: researchTopic ?? this.researchTopic,
      ethicalApprovalPath: ethicalApprovalPath ?? this.ethicalApprovalPath,
      hasConsent: hasConsent ?? this.hasConsent,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "fullName": fullName,
      "institution": institution,
      "researchTopic": researchTopic,
      "ethicalApprovalPath": ethicalApprovalPath,
      "hasConsent": hasConsent,
      "userId": userId,
      "userEmail": userEmail,
      "status": status,
      "requestDate": requestDate.toIso8601String(),
    };
  }

  static ResearchAccessRequest fromMap(Map<String, dynamic> map) {
    return ResearchAccessRequest(
      id: map['id'],
      fullName: map['firstName'],
      institution: map['institution'],
      researchTopic: map['researchTopic'],
      ethicalApprovalPath: map['ethicalApprovalPath'],
      hasConsent: map['hasConsent'],
      userId: map['userId'],
      userEmail: map['userEmail'],
      status: map['status'],
      requestDate: DateTime.parse(map['requestDate']),
    );
  }

  bool get isValid =>
      fullName.isNotEmpty &&
      institution.isNotEmpty &&
      researchTopic.isNotEmpty &&
      hasConsent &&
      userId.isNotEmpty &&
      userEmail.isNotEmpty;
}
