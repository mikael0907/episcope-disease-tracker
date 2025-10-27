//lib/providers/symptom_assessment_provider.dart




import 'package:disease_tracker/models/symptom_assessment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ================== STATE MANAGEMENT ==================
final symptomAssessmentProvider =
    StateNotifierProvider<SymptomAssessmentNotifier, SymptomAssessment>((ref) {
      return SymptomAssessmentNotifier();
    });

class SymptomAssessmentNotifier extends StateNotifier<SymptomAssessment> {
  SymptomAssessmentNotifier()
    : super(
        SymptomAssessment(
          age: 30,
          gender: 'Prefer not to say',
          isPregnant: false,
          location: '',
          hasTraveled: false,
          hadContactWithSick: false,
          isVaccinated: false,
          symptoms: [],
          symptomDuration: 1,
          severity: 'Mild',
          preExistingConditions: [],
          riskLevel: RiskLevel.low,
          recommendations: 'No specific recommendations at this time.',
        ),
      );

  void updateDiseaseFocus(String? disease) {
    state = SymptomAssessment(
      diseaseFocus: disease,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void updateBasicInfo({
    required int age,
    required String gender,
    required bool isPregnant,
    required String location,
  }) {
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: age,
      gender: gender,
      isPregnant: isPregnant,
      location: location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void updateTravelInfo({required bool hasTraveled, String? travelCountry}) {
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: hasTraveled,
      travelCountry: travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void updateContactInfo({
    required bool hadContact,
    required bool isVaccinated,
  }) {
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: hadContact,
      isVaccinated: isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void addSymptom(String symptom) {
    final newSymptoms = [...state.symptoms, symptom];
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: newSymptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(newSymptoms),
      recommendations: _generateRecommendations(newSymptoms),
    );
  }

  void addCustomSymptom(String symptom) {
    final newCustomSymptoms = [...?state.customSymptoms, symptom];
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: newCustomSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void removeSymptom(String symptom) {
    final newSymptoms = state.symptoms.where((s) => s != symptom).toList();
    final newCustomSymptoms =
        state.customSymptoms?.where((s) => s != symptom).toList();
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: newSymptoms,
      customSymptoms: newCustomSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(newSymptoms),
      recommendations: _generateRecommendations(newSymptoms),
    );
  }

  void updateSymptomDuration(int days) {
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: days,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void updateSeverity(String severity) {
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void addPreExistingCondition(String condition) {
    final newConditions = [...state.preExistingConditions, condition];
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: newConditions,
      customConditions: state.customConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void addCustomCondition(String condition) {
    final newCustomConditions = [...?state.customConditions, condition];
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: state.preExistingConditions,
      customConditions: newCustomConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  void removeCondition(String condition) {
    final newConditions =
        state.preExistingConditions.where((c) => c != condition).toList();
    final newCustomConditions =
        state.customConditions?.where((c) => c != condition).toList();
    state = SymptomAssessment(
      diseaseFocus: state.diseaseFocus,
      age: state.age,
      gender: state.gender,
      isPregnant: state.isPregnant,
      location: state.location,
      hasTraveled: state.hasTraveled,
      travelCountry: state.travelCountry,
      hadContactWithSick: state.hadContactWithSick,
      isVaccinated: state.isVaccinated,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      symptomDuration: state.symptomDuration,
      severity: state.severity,
      preExistingConditions: newConditions,
      customConditions: newCustomConditions,
      riskLevel: _calculateRiskLevel(),
      recommendations: _generateRecommendations(),
    );
  }

  RiskLevel _calculateRiskLevel([List<String>? symptoms]) {
    final currentSymptoms = symptoms ?? state.symptoms;
    int riskScore = 0;

    // Age factor
    if (state.age < 5 || state.age > 65) riskScore += 1;
    if (state.age > 80) riskScore += 1;

    // Pregnancy factor
    if (state.isPregnant) riskScore += 1;

    // Travel factor
    if (state.hasTraveled) riskScore += 1;

    // Contact factor
    if (state.hadContactWithSick) riskScore += 2;

    // Pre-existing conditions
    riskScore += state.preExistingConditions.length;

    // Symptom severity
    if (state.severity == 'Moderate') riskScore += 1;
    if (state.severity == 'Severe') riskScore += 2;

    // Disease-specific risk factors
    if (state.diseaseFocus != null) {
      final diseaseData = diseaseInfo[state.diseaseFocus!];
      if (diseaseData != null) {
        final questions = diseaseData['questions'] as List<String>;
        for (final question in questions) {
          if (currentSymptoms.contains(question)) {
            // Higher risk for certain symptoms
            if (question.contains('bleeding') ||
                question.contains('shortness of breath') ||
                question.contains('yellowing') ||
                question.contains('seizures')) {
              riskScore += 2;
            } else {
              riskScore += 1;
            }
          }
        }
      }
    }

    // Symptom duration
    if (state.symptomDuration > 7) riskScore += 1;
    if (state.symptomDuration > 14) riskScore += 1;

    // Vaccination status (reduces risk)
    if (state.isVaccinated) riskScore -= 2;

    // Determine risk level
    if (riskScore >= 5) return RiskLevel.high;
    if (riskScore >= 3) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  String _generateRecommendations([List<String>? symptoms]) {
    final riskLevel = _calculateRiskLevel(symptoms);
    

    switch (riskLevel) {
      case RiskLevel.high:
        return 'Seek immediate medical attention. Your symptoms and risk factors suggest a potentially serious condition.';
      case RiskLevel.moderate:
        return 'Consult a healthcare provider within 24 hours. Monitor your symptoms closely.';
      case RiskLevel.low:
        return 'Rest and monitor your symptoms. Seek medical advice if symptoms worsen or persist.';
    }
  }
}

// ================== DATA ==================
final diseaseOptions = [
  "Malaria",
  "COVID-19",
  "Dengue",
  "Tuberculosis (TB)",
  "Cholera",
  "Influenza (Flu)",
  "Measles",
  "Typhoid",
  "Meningitis",
  "Yellow Fever",
  "Hepatitis B/C",
  "HIV",
  "Monkeypox",
  "Zika Virus",
  "Lassa Fever",
  "Other (Specify)",
];

final generalSymptoms = [
  "Fever",
  "Chills",
  "Headache",
  "Nausea",
  "Vomiting",
  "Diarrhea",
  "Rash",
  "Skin ulcers",
  "Muscle aches",
  "Joint pain",
  "Chest pain",
  "Cough",
  "Dry cough",
  "Productive cough",
  "Sore throat",
  "Loss of smell",
  "Loss of taste",
  "Runny nose",
  "Nasal congestion",
  "Night sweats",
  "Jaundice (yellow skin)",
  "Eye redness",
  "Seizures",
  "Confusion",
  "Fatigue",
  "Weight loss",
  "Swollen lymph nodes",
  "Abdominal pain",
  "Bleeding (gums/nose)",
  "Shortness of breath",
  "Other (Specify)",
];

final preExistingConditions = [
  "Diabetes",
  "Hypertension",
  "Asthma",
  "HIV/AIDS",
  "Cancer",
  "Heart disease",
  "Chronic lung disease",
  "Kidney disease",
  "Liver disease",
  "Autoimmune disorder",
  "Other (Specify)",
];

// ================== DISEASE INFORMATION ==================
final Map<String, Map<String, dynamic>> diseaseInfo = {
  "Malaria": {
    "questions": [
      "Do you have fever or chills?",
      "Have you had headaches recently?",
      "Are you experiencing joint pain or body aches?",
      "Do you feel nauseous or vomiting?",
      "Have you noticed any yellowing of the eyes?",
      "Any recent mosquito bites or travel to malaria-prone area?",
    ],
    "transmission":
        "Malaria is transmitted through the bite of infected Anopheles mosquitoes.",
    "prevention":
        "Use insecticide-treated mosquito nets, eliminate standing water, and take prophylactic medications if traveling to risk areas.",
    "treatment":
        "Treatment involves antimalarial medications like artemisinin-based combination therapy (ACT).",
  },
  "COVID-19": {
    "questions": [
      "Do you have a persistent dry cough?",
      "Have you experienced loss of taste or smell?",
      "Are you short of breath?",
      "Do you have a sore throat?",
      "Are you vaccinated for COVID-19?",
      "Have you been in contact with a confirmed COVID case?",
    ],
    "transmission":
        "COVID-19 is spread through respiratory droplets, airborne particles, and contaminated surfaces.",
    "prevention":
        "Get vaccinated, wear masks in crowded areas, wash hands frequently, and avoid close contact with sick individuals.",
    "treatment":
        "Supportive care and antiviral drugs like Paxlovid may be used. Severe cases may require hospitalization.",
  },
  "Dengue": {
    "questions": [
      "Do you have a sudden high fever?",
      "Are you experiencing severe headache or pain behind the eyes?",
      "Do you have a skin rash?",
      "Bleeding gums or nosebleeds?",
      "Nausea or vomiting?",
    ],
    "transmission":
        "Dengue is transmitted by the Aedes mosquito, especially Aedes aegypti.",
    "prevention":
        "Use mosquito repellents, avoid mosquito breeding sites, and wear protective clothing.",
    "treatment":
        "Supportive care includes hydration and pain relief. Avoid NSAIDs like ibuprofen or aspirin.",
  },
  "Tuberculosis (TB)": {
    "questions": [
      "Have you had a persistent cough for more than 2 weeks?",
      "Are you coughing up blood?",
      "Are you experiencing night sweats?",
      "Significant weight loss?",
      "Chest pain?",
    ],
    "transmission":
        "Spread through airborne droplets when an infected person coughs or sneezes.",
    "prevention":
        "BCG vaccination, early detection, and proper ventilation in crowded areas.",
    "treatment":
        "Antibiotic therapy over several months using drugs like isoniazid and rifampin.",
  },
  "Cholera": {
    "questions": [
      "Watery diarrhea (looks like rice water)?",
      "Vomiting?",
      "Dehydration symptoms (sunken eyes, dry mouth)?",
      "Recent consumption of untreated water?",
    ],
    "transmission": "Ingesting contaminated water or food.",
    "prevention": "Use safe water, proper sanitation, and hygiene practices.",
    "treatment":
        "Immediate rehydration with ORS and antibiotics in severe cases.",
  },
  "Influenza (Flu)": {
    "questions": [
      "Runny nose or nasal congestion?",
      "Muscle or body aches?",
      "Fever and chills?",
      "Fatigue or weakness?",
      "Sore throat?",
    ],
    "transmission": "Airborne respiratory droplets and contaminated surfaces.",
    "prevention": "Annual flu vaccination and good hygiene.",
    "treatment": "Rest, fluids, antivirals like oseltamivir (Tamiflu).",
  },
  "Measles": {
    "questions": [
      "Rash starting on face and spreading?",
      "High fever?",
      "Cough, runny nose, red eyes?",
      "Have you been vaccinated (MMR)?",
    ],
    "transmission": "Highly contagious via respiratory droplets.",
    "prevention": "MMR vaccination.",
    "treatment":
        "No specific antiviral treatment; supportive care and vitamin A supplements.",
  },
  "Typhoid": {
    "questions": [
      "High fever (especially in afternoon)?",
      "Weakness or fatigue?",
      "Constipation or diarrhea?",
      "Rose-colored spots on chest or abdomen?",
      "Recent travel or street food consumption?",
    ],
    "transmission": "Contaminated food or water.",
    "prevention": "Vaccination, safe drinking water, and hygiene.",
    "treatment": "Antibiotics like ciprofloxacin or azithromycin.",
  },
  "Meningitis": {
    "questions": [
      "Stiff neck?",
      "Light sensitivity?",
      "Confusion or difficulty concentrating?",
      "Seizures?",
      "High fever?",
    ],
    "transmission": "Spread through saliva or respiratory droplets.",
    "prevention": "Vaccination, avoiding close contact with infected persons.",
    "treatment": "Immediate hospitalization and antibiotics or antivirals.",
  },
  "Yellow Fever": {
    "questions": [
      "Sudden fever and chills?",
      "Back pain?",
      "Jaundice (yellow skin/eyes)?",
      "Bleeding from nose or mouth?",
    ],
    "transmission":
        "Spread through infected mosquito bites (Aedes or Haemagogus).",
    "prevention": "Vaccination and mosquito control.",
    "treatment": "No specific cure. Supportive care for symptoms.",
  },
  "Hepatitis B/C": {
    "questions": [
      "Jaundice?",
      "Dark urine?",
      "Fatigue or malaise?",
      "Abdominal pain?",
      "Sexual or needle exposure risk?",
    ],
    "transmission": "Contact with infected body fluids (blood, sex, needles).",
    "prevention": "Vaccination (for B), safe sex, avoiding sharing needles.",
    "treatment":
        "Antiviral medications; some chronic cases may need long-term management.",
  },
  "HIV": {
    "questions": [
      "Recurrent infections?",
      "Night sweats?",
      "Weight loss?",
      "Swollen lymph nodes?",
    ],
    "transmission":
        "Unprotected sex, needle sharing, mother-to-child, or transfusions.",
    "prevention": "Safe sex, PrEP, clean needle programs.",
    "treatment": "Antiretroviral therapy (ART) for lifelong management.",
  },
  "Monkeypox": {
    "questions": [
      "Skin lesions or rashes?",
      "Swollen lymph nodes?",
      "Fever and headache?",
      "Fatigue or back pain?",
      "Any contact with infected animals or people?",
    ],
    "transmission":
        "Contact with infected animals, people, or contaminated objects.",
    "prevention": "Avoid contact with infected sources and practice hygiene.",
    "treatment": "Supportive care; antivirals may be used in severe cases.",
  },
  "Zika Virus": {
    "questions": [
      "Mild fever?",
      "Skin rash?",
      "Conjunctivitis (red eyes)?",
      "Joint pain?",
      "Are you pregnant or planning pregnancy?",
    ],
    "transmission": "Mosquito bites, sexual contact, mother to fetus.",
    "prevention": "Avoid mosquito bites and use protection during sex.",
    "treatment": "Supportive care with rest, fluids, and pain relievers.",
  },
  "Lassa Fever": {
    "questions": [
      "Bleeding from nose/mouth?",
      "Fever?",
      "Chest pain?",
      "Hearing loss?",
      "Recent travel to outbreak zones?",
    ],
    "transmission": "Contact with rodent urine, feces, or infected people.",
    "prevention":
        "Keep food and living spaces rodent-free. Avoid contact with the sick.",
    "treatment": "Antiviral ribavirin is most effective when started early.",
  },
};

//for phone number hotline
final hospitalHotlinesProvider = StateProvider<List<HospitalHotline>>((ref) {
  return [
    HospitalHotline(
      name: "National Emergency",
      phoneNumber: "+1234567890",
      location: "Nationwide",
    ),
    HospitalHotline(
      name: "City General Hospital",
      phoneNumber: "+1987654321",
      location: "Main City",
    ),
    // Add more as needed
  ];
});



