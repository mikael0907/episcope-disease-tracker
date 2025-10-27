

//lib/models/symptom_assessment_model.dart



// ================== MODELS ==================
enum RiskLevel { low, moderate, high }

class SymptomAssessment {
  final String? diseaseFocus;
  final int age;
  final String gender;
  final bool isPregnant;
  final String location;
  final bool hasTraveled;
  final String? travelCountry;
  final bool hadContactWithSick;
  final bool isVaccinated;
  final List<String> symptoms;
  final List<String>? customSymptoms;
  final int symptomDuration;
  final String severity;
  final List<String> preExistingConditions;
  final List<String>? customConditions;
  final RiskLevel riskLevel;
  final String recommendations;

  SymptomAssessment({
    this.diseaseFocus,
    required this.age,
    required this.gender,
    required this.isPregnant,
    required this.location,
    required this.hasTraveled,
    this.travelCountry,
    required this.hadContactWithSick,
    required this.isVaccinated,
    required this.symptoms,
    this.customSymptoms,
    required this.symptomDuration,
    required this.severity,
    required this.preExistingConditions,
    this.customConditions,
    required this.riskLevel,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'diseaseFocus': diseaseFocus,
      'age': age,
      'gender': gender,
      'isPregnant': isPregnant,
      'location': location,
      'hasTraveled': hasTraveled,
      'travelCountry': travelCountry,
      'hadContactWithSick': hadContactWithSick,
      'isVaccinated': isVaccinated,
      'symptoms': symptoms,
      'customSymptoms': customSymptoms,
      'symptomDuration': symptomDuration,
      'severity': severity,
      'preExistingConditions': preExistingConditions,
      'customConditions': customConditions,
      'riskLevel': riskLevel.toString(),
      'recommendations': recommendations,
    };
  }
}

//For the phone number hotline
class HospitalHotline {
  final String name;
  final String phoneNumber;
  final String location;

  HospitalHotline({
    required this.name,
    required this.phoneNumber,
    required this.location,
  });
}
