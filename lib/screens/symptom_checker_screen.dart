//lib/screens/symptom_checker_screen.dart

import 'dart:async';

import 'package:disease_tracker/models/symptom_assessment_model.dart';
import 'package:disease_tracker/providers/symptom_assessment_provider.dart';
import 'package:disease_tracker/screens/healthcare_facility_screen.dart';
import 'package:disease_tracker/screens/selfcare_tips_screen.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:disease_tracker/shared/user_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() =>
      _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends ConsumerState<SymptomCheckerScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final assessment = ref.watch(symptomAssessmentProvider);
    final notifier = ref.read(symptomAssessmentProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const StyledText(
          text: "Symptom Checker",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (int i = 0; i < 5; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            i <= _currentStep
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          StyledText(
            text: "Step ${_currentStep + 1} of 5",
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),

          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Disease Focus
                _buildDiseaseFocusStep(assessment, notifier),
                // Step 2: Basic Info
                _buildBasicInfoStep(assessment, notifier),
                // Step 3: Travel & Contact
                _buildTravelContactStep(assessment, notifier),
                // Step 4: Symptoms
                _buildSymptomsStep(assessment, notifier),
                // Step 5: Results
                _buildResultsStep(assessment),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: StyledButton(
                      text: "Back",
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                        setState(() => _currentStep--);
                      },
                      color: Colors.grey,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: StyledButton(
                    text: _currentStep == 4 ? "Finish" : "Next",
                    onPressed: () {
                      if (_currentStep < 4) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                        setState(() => _currentStep++);
                      } else {
                        Navigator.pushNamed(context, '/home');
                      }
                    },
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildDiseaseFocusStep(
    SymptomAssessment assessment,
    SymptomAssessmentNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StyledText(
            text: "What disease are you concerned about?",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          
          // FIXED: Using FilterChip instead of deprecated Radio
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diseaseOptions.map((disease) {
              return FilterChip(
                label: Text(disease),
                selected: assessment.diseaseFocus == disease,
                onSelected: (selected) {
                  if (selected) {
                    if (disease == "Other (Specify)") {
                      _showDiseaseSpecifyDialog(notifier);
                    } else {
                      notifier.updateDiseaseFocus(disease);
                    }
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDiseaseSpecifyDialog(SymptomAssessmentNotifier notifier) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Specify Disease"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "Enter disease name",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isNotEmpty) {
                notifier.updateDiseaseFocus(value);
              }
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(
    SymptomAssessment assessment,
    SymptomAssessmentNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StyledText(
            text: "Basic Information",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 24),

          // Age
          const StyledText(
            text: "Age",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          Slider(
            value: assessment.age.toDouble(),
            min: 0,
            max: 120,
            divisions: 120,
            label: assessment.age.toString(),
            onChanged: (value) {
              notifier.updateBasicInfo(
                age: value.toInt(),
                gender: assessment.gender,
                isPregnant: assessment.isPregnant,
                location: assessment.location,
              );
            },
          ),
          Center(child: Text("${assessment.age} years")),
          const SizedBox(height: 24),

          // Gender
          const StyledText(
            text: "Gender",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: assessment.gender,
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
              DropdownMenuItem(
                value: 'Prefer not to say',
                child: Text('Prefer not to say'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.updateBasicInfo(
                  age: assessment.age,
                  gender: value,
                  isPregnant: assessment.isPregnant,
                  location: assessment.location,
                );
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pregnancy (if female)
          if (assessment.gender == 'Female')
            CheckboxListTile(
              title: const Text("Are you pregnant?"),
              value: assessment.isPregnant,
              onChanged: (value) {
                notifier.updateBasicInfo(
                  age: assessment.age,
                  gender: assessment.gender,
                  isPregnant: value ?? false,
                  location: assessment.location,
                );
              },
            ),

          // Location
          const SizedBox(height: 16),
          const StyledText(
            text: "Location",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          // FIXED: Using initialValue instead of value for TextFormField
          TextFormField(
            initialValue: assessment.location,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintText: "Enter location or tap icon to detect",
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () => _handleLocationDetection(context, notifier, assessment),
              ),
            ),
            onChanged: (value) => notifier.updateBasicInfo(
              age: assessment.age,
              gender: assessment.gender,
              isPregnant: assessment.isPregnant,
              location: value,
            ),
            showCursor: true,
            cursorColor: Theme.of(context).primaryColor,
            cursorWidth: 2.0,
            cursorHeight: 20,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLocationDetection(
    BuildContext context,
    SymptomAssessmentNotifier notifier,
    SymptomAssessment assessment,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      const SnackBar(content: Text('Detecting your location...')),
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool enabled = await Geolocator.openLocationSettings();
        if (!enabled) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Location permission required')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Enable location in app settings')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      ).timeout(const Duration(seconds: 15));

      try {
        final places = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));

        if (places.isNotEmpty) {
          final place = places.first;
          final address = [
            if (place.street != null) place.street,
            if (place.subLocality != null) place.subLocality,
            if (place.locality != null) place.locality,
            if (place.administrativeArea != null) place.administrativeArea,
            if (place.country != null) place.country,
          ].where((p) => p != null && p.isNotEmpty).join(', ');

          notifier.updateBasicInfo(
            age: assessment.age,
            gender: assessment.gender,
            isPregnant: assessment.isPregnant,
            location: address,
          );
        } else {
          notifier.updateBasicInfo(
            age: assessment.age,
            gender: assessment.gender,
            isPregnant: assessment.isPregnant,
            location: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          );
        }
      } catch (e) {
        notifier.updateBasicInfo(
          age: assessment.age,
          gender: assessment.gender,
          isPregnant: assessment.isPregnant,
          location: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        );
      }

      messenger.showSnackBar(const SnackBar(content: Text('Location updated')));
    } on TimeoutException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Location detection timed out')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().split(':').first}')),
      );
    }
  }

  Widget _buildTravelContactStep(
    SymptomAssessment assessment,
    SymptomAssessmentNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StyledText(
            text: "Travel & Contact History",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 24),

          // Recent Travel - FIXED
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StyledText(
                    text: "Have you traveled recently?",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  // FIXED: Using SegmentedButton instead of RadioListTile
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Yes')),
                      ButtonSegment(value: false, label: Text('No')),
                    ],
                    selected: {assessment.hasTraveled},
                    onSelectionChanged: (Set<bool> newSelection) {
                      final value = newSelection.first;
                      notifier.updateTravelInfo(
                        hasTraveled: value,
                        travelCountry: value ? assessment.travelCountry : null,
                      );
                    },
                  ),
                  if (assessment.hasTraveled) ...[
                    const SizedBox(height: 16),
                    const StyledText(
                      text: "Which country did you visit?",
                      fontSize: 16,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: assessment.travelCountry,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Enter country name",
                      ),
                      onChanged: (value) {
                        notifier.updateTravelInfo(
                          hasTraveled: true,
                          travelCountry: value,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Contact with sick person - FIXED
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StyledText(
                    text: "Have you been in contact with someone who is sick?",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  // FIXED: Using SegmentedButton instead of RadioListTile
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Yes')),
                      ButtonSegment(value: false, label: Text('No')),
                    ],
                    selected: {assessment.hadContactWithSick},
                    onSelectionChanged: (Set<bool> newSelection) {
                      notifier.updateContactInfo(
                        hadContact: newSelection.first,
                        isVaccinated: assessment.isVaccinated,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Vaccination status - FIXED
          if (assessment.diseaseFocus != null &&
              [
                "COVID-19",
                "Measles",
                "Yellow Fever",
                "Hepatitis B",
                "Influenza (Flu)",
                "Tuberculosis (TB)",
                "Typhoid",
                "Meningitis",
              ].contains(assessment.diseaseFocus))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      text: "Are you vaccinated against ${assessment.diseaseFocus}?",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    // FIXED: Using SegmentedButton instead of RadioListTile
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Yes')),
                        ButtonSegment(value: false, label: Text('No')),
                      ],
                      selected: {assessment.isVaccinated},
                      onSelectionChanged: (Set<bool> newSelection) {
                        notifier.updateContactInfo(
                          hadContact: assessment.hadContactWithSick,
                          isVaccinated: newSelection.first,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomsStep(
    SymptomAssessment assessment,
    SymptomAssessmentNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StyledText(
            text: "Symptoms & Health Information",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 24),

          // Symptom duration
          const StyledText(
            text: "How many days have you had symptoms?",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          Slider(
            value: assessment.symptomDuration.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: "${assessment.symptomDuration} days",
            onChanged: (value) {
              notifier.updateSymptomDuration(value.toInt());
            },
          ),
          Center(child: Text("${assessment.symptomDuration} days")),
          const SizedBox(height: 24),

          // Symptom severity
          const StyledText(
            text: "How severe are your symptoms?",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: "Mild", label: Text("Mild")),
              ButtonSegment(value: "Moderate", label: Text("Moderate")),
              ButtonSegment(value: "Severe", label: Text("Severe")),
            ],
            selected: {assessment.severity},
            onSelectionChanged: (Set<String> newSelection) {
              notifier.updateSeverity(newSelection.first);
            },
          ),
          const SizedBox(height: 24),

          // Symptoms checklist
          const StyledText(
            text: "Select your symptoms:",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {},
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const ListTile(title: Text("General Symptoms"));
                },
                body: Column(
                  children: [
                    for (final symptom in generalSymptoms)
                      CheckboxListTile(
                        title: Text(symptom),
                        value: assessment.symptoms.contains(symptom) ||
                            (symptom == "Other (Specify)" &&
                                assessment.customSymptoms != null &&
                                assessment.customSymptoms!.isNotEmpty),
                        onChanged: (bool? value) {
                          if (value == true) {
                            if (symptom == "Other (Specify)") {
                              _showCustomSymptomsDialog(notifier);
                            } else {
                              notifier.addSymptom(symptom);
                            }
                          } else {
                            notifier.removeSymptom(symptom);
                            if (symptom == "Other (Specify)") {
                              notifier.addCustomSymptom('');
                            }
                          }
                        },
                      ),
                  ],
                ),
                isExpanded: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Disease-specific symptoms
          if (assessment.diseaseFocus != null)
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {},
              children: [
                ExpansionPanel(
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text("${assessment.diseaseFocus} Symptoms"),
                    );
                  },
                  body: Column(
                    children: _buildDiseaseSpecificSymptoms(
                      assessment.diseaseFocus!,
                      assessment,
                      notifier,
                    ),
                  ),
                  isExpanded: true,
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Pre-existing conditions
          const StyledText(
            text: "Pre-existing Conditions:",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final condition in preExistingConditions)
                FilterChip(
                  label: Text(condition),
                  selected: assessment.preExistingConditions.contains(condition) ||
                      (condition == "Other (Specify)" &&
                          assessment.customConditions != null &&
                          assessment.customConditions!.isNotEmpty),
                  onSelected: (selected) {
                    if (selected) {
                      if (condition == "Other (Specify)") {
                        _showCustomConditionsDialog(notifier);
                      } else {
                        notifier.addPreExistingCondition(condition);
                      }
                    } else {
                      notifier.removeCondition(condition);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Display selected symptoms
          if (assessment.symptoms.isNotEmpty ||
              (assessment.customSymptoms != null &&
                  assessment.customSymptoms!.isNotEmpty))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StyledText(
                  text: "Selected Symptoms:",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final symptom in assessment.symptoms)
                      Chip(
                        label: Text(symptom),
                        onDeleted: () => notifier.removeSymptom(symptom),
                      ),
                    if (assessment.customSymptoms != null)
                      for (final symptom in assessment.customSymptoms!)
                        if (symptom.isNotEmpty)
                          Chip(
                            label: Text(symptom),
                            onDeleted: () => notifier.removeSymptom(symptom),
                          ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDiseaseSpecificSymptoms(
    String disease,
    SymptomAssessment assessment,
    SymptomAssessmentNotifier notifier,
  ) {
    final diseaseData = diseaseInfo[disease];
    if (diseaseData == null) return [];

    return [
      for (final question in diseaseData['questions'] as List<String>)
        _buildSymptomCheckbox(question, assessment, notifier),
    ];
  }

  List<Widget> _buildDiseaseInfo(String disease) {
    final diseaseData = diseaseInfo[disease];
    if (diseaseData == null) return [];

    return [
      StyledText(text: disease, fontSize: 18, fontWeight: FontWeight.bold),
      const SizedBox(height: 16),
      _buildInfoSection("Transmission", diseaseData['transmission'] as String),
      const SizedBox(height: 12),
      _buildInfoSection("Prevention", diseaseData['prevention'] as String),
      const SizedBox(height: 12),
      _buildInfoSection("Treatment", diseaseData['treatment'] as String),
    ];
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }

  Widget _buildSymptomCheckbox(
    String symptom,
    SymptomAssessment assessment,
    SymptomAssessmentNotifier notifier,
  ) {
    return CheckboxListTile(
      title: Text(symptom),
      value: assessment.symptoms.contains(symptom),
      onChanged: (bool? value) {
        if (value == true) {
          notifier.addSymptom(symptom);
        } else {
          notifier.removeSymptom(symptom);
        }
      },
    );
  }

  Widget _buildResultsStep(SymptomAssessment assessment) {
    Color riskColor;
    String riskText;
    IconData riskIcon;

    switch (assessment.riskLevel) {
      case RiskLevel.high:
        riskColor = Colors.red;
        riskText = "High Risk";
        riskIcon = Icons.warning;
        break;
      case RiskLevel.moderate:
        riskColor = Colors.orange;
        riskText = "Moderate Risk";
        riskIcon = Icons.info;
        break;
      case RiskLevel.low:
        riskColor = Colors.green;
        riskText = "Low Risk";
        riskIcon = Icons.check_circle;
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(riskIcon, size: 64, color: riskColor),
                const SizedBox(height: 16),
                StyledText(
                  text: riskText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const StyledText(
            text: "Recommendations:",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StyledText(text: assessment.recommendations, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          if (assessment.diseaseFocus != null) ...[
            const StyledText(
              text: "Disease Information:",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDiseaseInfo(assessment.diseaseFocus!),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const StyledText(
            text: "Next Steps:",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNextStepTile(
                    icon: Icons.local_hospital,
                    title: "Find Healthcare",
                    subtitle: "Locate nearest healthcare facility",
                  ),
                  const Divider(),
                  _buildNextStepTile(
                    icon: Icons.phone,
                    title: "Call Hotline",
                    subtitle: "Contact local health authorities",
                  ),
                  const Divider(),
                  _buildNextStepTile(
                    icon: Icons.self_improvement,
                    title: "Self-Care Tips",
                    subtitle: "Manage symptoms at home",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextStepAction(
    String action,
    BuildContext context,
    WidgetRef ref,
  ) {
    switch (action) {
      case "Find Healthcare":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HealthcareFacilityScreen()),
        );
        break;
      case "Call Hotline":
        _showHotlineSelectionDialog(context, ref);
        break;
      case "Self-Care Tips":
        final disease = ref.read(symptomAssessmentProvider).diseaseFocus;
        if (disease != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelfCareTipsScreen(disease: disease),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No disease selected')));
        }
        break;
    }
  }

  void _showHotlineSelectionDialog(BuildContext context, WidgetRef ref) {
    final hotlines = ref.read(hospitalHotlinesProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Hotline"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: hotlines.length,
            itemBuilder: (context, index) {
              final hotline = hotlines[index];
              return ListTile(
                title: Text(hotline.name),
                subtitle: Text("${hotline.phoneNumber}\n${hotline.location}"),
                onTap: () {
                  launchUrl(Uri.parse("tel://${hotline.phoneNumber}"));
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _handleNextStepAction(title, context, ref),
    );
  }

  void _showCustomSymptomsDialog(SymptomAssessmentNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        final customSymptoms = <String>[];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Custom Symptoms"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < customSymptoms.length + 1; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: i < customSymptoms.length ? customSymptoms[i] : "Enter symptom",
                                ),
                                onChanged: (value) {
                                  if (i < customSymptoms.length) {
                                    customSymptoms[i] = value;
                                  }
                                },
                              ),
                            ),
                            if (i < customSymptoms.length)
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    customSymptoms.removeAt(i);
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          customSymptoms.add("");
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    for (final symptom in customSymptoms) {
                      if (symptom.isNotEmpty) {
                        notifier.addCustomSymptom(symptom);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCustomConditionsDialog(SymptomAssessmentNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        final customConditions = <String>[];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Custom Conditions"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < customConditions.length + 1; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: i < customConditions.length ? customConditions[i] : "Enter condition",
                                ),
                                onChanged: (value) {
                                  if (i < customConditions.length) {
                                    customConditions[i] = value;
                                  }
                                },
                              ),
                            ),
                            if (i < customConditions.length)
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    customConditions.removeAt(i);
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          customConditions.add("");
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    for (final condition in customConditions) {
                      if (condition.isNotEmpty) {
                        notifier.addCustomCondition(condition);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class SymptomAssessmentSyncService {
  final Ref ref;

  SymptomAssessmentSyncService(this.ref);

  Future<void> syncAssessments() async {
    // Implement Firebase sync logic here
  }
}