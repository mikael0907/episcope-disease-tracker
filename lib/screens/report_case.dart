
//lib/screens/report_case.dart

import 'dart:io';
import 'package:disease_tracker/models/case_report_models.dart';
import 'package:disease_tracker/providers/controllers/current_user_provider.dart';
import 'package:disease_tracker/providers/report_case_provider.dart';
import 'package:disease_tracker/services/supabase_storage_service.dart';
import 'package:disease_tracker/shared/styled_button.dart';
import 'package:disease_tracker/shared/styled_text.dart';
import 'package:disease_tracker/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class ReportCaseScreen extends ConsumerWidget {
  const ReportCaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(reportFormProvider);
    final formNotifier = ref.read(reportFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemes.light.primaryColor,
        title: StyledText(
          text: "Report A New Case",
          fontSize: 24,
          color: AppThemes.light.canvasColor,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDiseaseDropDown(formState, formNotifier, context, ref),
            const SizedBox(height: 16),
            _buildLocationInput(formState, formNotifier, context),
            const SizedBox(height: 16),
            _buildSymptomsSelector(formState, formNotifier, context, ref),
            const SizedBox(height: 16),
            _buildSeveritySelector(formState, formNotifier, context),
            const SizedBox(height: 16),
            _buildDatePicker(formState, formNotifier, context),
            const SizedBox(height: 16),
            _buildContactHistory(formState, formNotifier, context),
            const SizedBox(height: 16),
            _buildNumberOfCases(formState, formNotifier, context),
            const SizedBox(height: 16),
            _buildPhotoUpload(formState, formNotifier, context, ref),
            const SizedBox(height: 24),
            StyledButton(
              text: "Submit Report",
              onPressed: () async {
                final currentUser = ref.read(currentUserProvider);
                
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Please sign in to report a case')),
                  );
                  return;
                }

                if (formState.disease.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Please select a disease')),
                  );
                  return;
                }

                if (formState.location.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Please enter a location')),
                  );
                  return;
                }

                if (formState.symptoms.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Please select at least one symptom')),
                  );
                  return;
                }

                debugPrint('📝 Submitting report...');
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                try {
                  final report = CaseReport(
                    id: '',
                    disease: formState.disease,
                    customDisease: formState.customDisease,
                    location: formState.location,
                    symptoms: formState.symptoms,
                    customSymptoms: formState.customSymptoms,
                    severity: formState.severity,
                    onsetDate: formState.onsetDate,
                    contactHistory: formState.contactHistory,
                    numberOfCases: formState.numberOfCases,
                    photoUrls: formState.photoUrls,
                    isSynced: false,
                    userId: currentUser.id,
                    userName: currentUser.userName,
                    userEmail: currentUser.email,
                    status: 'Pending',
                  );
                  
                  ref.read(caseReportProvider.notifier).addReport(report);
                  
                  debugPrint('✅ Report added to provider');
                  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Report submitted successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  
                } catch (e) {
                  debugPrint('❌ Error submitting report: $e');
                  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to submit report: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              color: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseDropDown(
    CaseReport state,
    ReportFormNotifier notifier,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Disease Name",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        ExpansionPanelList(
          expansionCallback: (int panelIndex, bool isExpanded) {
            ref
                .read(diseaseExpansionStateProvider.notifier)
                .togglePanel(panelIndex);
          },
          children: [
            for (final entry in diseaseData.asMap().entries)
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      entry.value.category,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                body: Column(
                  children: [
                    for (final disease in entry.value.diseases)
  ListTile(
    title: Text(disease),
    leading: Icon(
      state.disease == disease 
          ? Icons.radio_button_checked 
          : Icons.radio_button_unchecked,
      color: state.disease == disease 
          ? Theme.of(context).primaryColor 
          : null,
    ),
    onTap: () {
      if (disease == 'Other (Specify)') {
                            final controller = TextEditingController();
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Specify Disease"),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Disease Name",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          notifier.updateDisease(
                                            "Other (Specify)",
                                            customDisease: controller.text,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                            );
                          } else {
                            notifier.updateDisease(disease);
                          }
                        },
                      ),
                  ],
                ),
                isExpanded:
                    ref.watch(diseaseExpansionStateProvider)[entry.key] ??
                    false,
              ),
          ],
        ),
        if (state.disease.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: StyledText(
              text:
                  state.disease == "Other (Specify)" &&
                          state.customDisease != null
                      ? "Specified: ${state.customDisease}"
                      : "Selected Disease: ${state.disease}",
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildLocationInput(
    CaseReport state,
    ReportFormNotifier notifier,
    BuildContext context,
  ) {
    final locationController = TextEditingController(text: state.location);

    locationController.selection = TextSelection.fromPosition(
      TextPosition(offset: locationController.text.length),
    );

    locationController.addListener(() {
      if (locationController.text != state.location) {
        notifier.updateLocation(locationController.text);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Location",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: locationController,
          autofocus: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: "Type location or tap icon to detect",
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📍 Getting your location...'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  LocationPermission permission = await Geolocator.checkPermission();
                  
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      throw Exception('Location permissions are denied');
                    }
                  }
                  
                  if (permission == LocationPermission.deniedForever) {
                    throw Exception('Location permissions are permanently denied. Please enable them in settings.');
                  }

                  final position = await Geolocator.getCurrentPosition(
                    locationSettings: const LocationSettings(
                      accuracy: LocationAccuracy.high,
                      timeLimit: Duration(seconds: 10),
                    ),
                  );

                  debugPrint('📍 Location found: ${position.latitude}, ${position.longitude}');

                  try {
                    final placemarks = await placemarkFromCoordinates(
                      position.latitude,
                      position.longitude,
                    );

                    if (placemarks.isNotEmpty) {
                      final place = placemarks.first;
                      final address = [
                        place.street,
                        place.subLocality,
                        place.locality,
                        place.administrativeArea,
                        place.country,
                      ]
                          .where((element) => element != null && element.isNotEmpty)
                          .join(', ');

                      debugPrint('📍 Address found: $address');

                      locationController.text = address;
                      locationController.selection = TextSelection.fromPosition(
                        TextPosition(offset: address.length),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Location detected successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      final fallbackAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
                      locationController.text = fallbackAddress;
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📍 Location found (showing coordinates)'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  } catch (geocodingError) {
                    debugPrint('⚠️ Geocoding error: $geocodingError');
                    final fallbackAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
                    locationController.text = fallbackAddress;
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📍 Location found (showing coordinates)'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }

                } on TimeoutException catch (e) {
                  debugPrint('❌ Location timeout: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⏱️ Location request timed out. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('❌ Location error: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Location error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSymptomsSelector(
    CaseReport state,
    ReportFormNotifier notifier,
    BuildContext context,
    WidgetRef ref,
  ) {
    final symptomExpansionStates = ref.watch(symptomExpansionStateProvider);
    final symptomExpansionNotifier = ref.read(
      symptomExpansionStateProvider.notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Select Symptoms",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        ExpansionPanelList(
          expansionCallback: (int panelIndex, bool isExpanded) {
            symptomExpansionNotifier.togglePanel(panelIndex);
          },
          children: [
            for (final entry in symptomsData.asMap().entries)
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(entry.value.category),
                    onTap:
                        () => symptomExpansionNotifier.togglePanel(entry.key),
                  );
                },
                body: Column(
                  children: [
                    for (final symptom in entry.value.symptoms)
                      CheckboxListTile(
                        title: Text(symptom),
                        value:
                            state.symptoms.contains(symptom) ||
                            (symptom == 'Other (Specify)' &&
                                state.customSymptoms != null &&
                                state.customSymptoms!.isNotEmpty),
                        onChanged: (bool? value) {
                          if (value == true) {
                            if (symptom == "Other (Specify)") {
                              _showCustomSymptomsDialog(notifier, context);
                            } else {
                              notifier.updateSymptom(symptom);
                            }
                          } else {
                            notifier.removeSymptom(symptom);
                            if (symptom == "Other (Specify)") {
                              notifier.updateCustomSymptom('');
                            }
                          }
                        },
                      ),
                  ],
                ),
                isExpanded: symptomExpansionStates[entry.key] ?? false,
              ),
          ],
        ),
        if (state.symptoms.isNotEmpty ||
            (state.customSymptoms != null && state.customSymptoms!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final symptom in state.symptoms)
                  Chip(
                    label: Text(symptom),
                    onDeleted: () => notifier.removeSymptom(symptom),
                  ),
                if (state.customSymptoms != null)
                  for (final symptom in state.customSymptoms!)
                    if (symptom.isNotEmpty)
                      Chip(
                        label: Text(symptom),
                        onDeleted: () => notifier.removeSymptom(symptom),
                      ),
              ],
            ),
          ),
      ],
    );
  }

  void _showCustomSymptomsDialog(
    ReportFormNotifier notifier,
    BuildContext context,
  ) {
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
                                  hintText:
                                      i < customSymptoms.length
                                          ? customSymptoms[i]
                                          : "Enter symptom",
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
                        notifier.updateCustomSymptom(symptom);
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

  Widget _buildSeveritySelector(
    CaseReport state,
    ReportFormNotifier notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Severity",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: "Mild", label: Text("Mild")),
            ButtonSegment(value: "Moderate", label: Text("Moderate")),
            ButtonSegment(value: "Severe", label: Text("Severe")),
            ButtonSegment(value: "Critical", label: Text("Critical")),
          ],
          selected: {state.severity},
          onSelectionChanged: (Set<String> newSelection) {
            notifier.updateSeverity(newSelection.first);
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    CaseReport state,
    ReportFormNotifier notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Date of Onset",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Select Date',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        SfDateRangePicker(
                          initialSelectedDate: state.onsetDate,
                          minDate: DateTime(1900),
                          maxDate: DateTime.now(),
                          selectionMode: DateRangePickerSelectionMode.single,
                          onSelectionChanged: (args) {
                            if (args.value is DateTime) {
                              notifier.updateOnsetDate(args.value as DateTime);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(state.onsetDate)),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactHistory(
    CaseReport state,
    ReportFormNotifier notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Contact History",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.contactHistory,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: "Describe any known contact with infected individuals",
          ),
          maxLines: 3,
          onChanged: notifier.updateContactHistory,
        ),
      ],
    );
  }

  Widget _buildNumberOfCases(
    CaseReport state,
    ReportFormNotifier notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Number of Cases",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (state.numberOfCases > 1) {
                  notifier.updateNumberOfCases(state.numberOfCases - 1);
                }
              },
            ),
            Text(state.numberOfCases.toString()),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                notifier.updateNumberOfCases(state.numberOfCases + 1);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoUpload(CaseReport state, ReportFormNotifier notifier, BuildContext context, WidgetRef ref) {
    final photoUrlController = TextEditingController();
    final storageService = SupabaseStorageService();
    final currentUser = ref.watch(currentUserProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText(
          text: "Photo Evidence",
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Upload photos of symptoms, rashes, or affected areas. You can take photos with your camera, select from gallery, or add URLs. Maximum 5 photos.",
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 12),
        
        // Upload buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (state.photoUrls != null && state.photoUrls!.length >= 5)
                    ? null
                    : () async {
                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ Please sign in to upload photos'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final cameraStatus = await Permission.camera.request();
                        
                        if (!cameraStatus.isGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Camera permission denied'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        final ImagePicker picker = ImagePicker();
                        final XFile? photo = await picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 1920,
                          maxHeight: 1080,
                          imageQuality: 85,
                        );

                        if (photo != null) {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      'Uploading photo...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          try {
                            final file = File(photo.path);
                            final url = await storageService.uploadPhoto(file, currentUser.id);

                            if (context.mounted) {
                              Navigator.pop(context);
                            }

                            if (url != null) {
                              notifier.updatePhotoUrl(url);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Photo uploaded successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ Failed to upload photo'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint('❌ Upload error: $e');
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Upload error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (state.photoUrls != null && state.photoUrls!.length >= 5)
                    ? null
                    : () async {
                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ Please sign in to upload photos'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final photosStatus = await Permission.photos.request();
                        
                        if (!photosStatus.isGranted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Gallery permission denied'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1920,
                          maxHeight: 1080,
                          imageQuality: 85,
                        );

                        if (image != null) {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      'Uploading photo...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          try {
                            final file = File(image.path);
                            final url = await storageService.uploadPhoto(file, currentUser.id);

                            if (context.mounted) {
                              Navigator.pop(context);
                            }

                            if (url != null) {
                              notifier.updatePhotoUrl(url);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Photo uploaded successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ Failed to upload photo'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint('❌ Upload error: $e');
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Upload error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Divider with "OR"
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // URL Input
        TextFormField(
          controller: photoUrlController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: "https://example.com/photo.jpg",
            labelText: "Add photo URL",
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_link),
              onPressed: () {
                final url = photoUrlController.text.trim();
                if (url.isNotEmpty && _isValidUrl(url)) {
                  final currentPhotos = state.photoUrls ?? [];
                  if (currentPhotos.length >= 5) {
                    _showUploadLimitDialog(context);
                    return;
                  }
                  notifier.updatePhotoUrl(url);
                  photoUrlController.clear();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Photo URL added'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Please enter a valid URL'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
          keyboardType: TextInputType.url,
          enabled: state.photoUrls == null || state.photoUrls!.length < 5,
        ),
        const SizedBox(height: 8),
        
        // Display uploaded photos
        if (state.photoUrls != null && state.photoUrls!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                '${state.photoUrls!.length} photo${state.photoUrls!.length > 1 ? 's' : ''} uploaded',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final url in state.photoUrls!)
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                debugPrint('❌ Image load error: $exception');
                              },
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _showDeleteConfirmation(
                              context,
                              url,
                              notifier,
                              storageService,
                              currentUser?.id ?? '',
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        
        // Upload limit warning
        if (state.photoUrls != null && state.photoUrls!.length >= 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Maximum 5 photos reached",
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String url,
    ReportFormNotifier notifier,
    SupabaseStorageService storageService,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                if (url.contains('case_photos')) {
                  await storageService.deletePhoto(url);
                  debugPrint('✅ Photo deleted from storage');
                }
                
                notifier.removePhotoUrl(url);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Photo deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('❌ Delete error: $e');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⚠️ Photo removed from report but may still exist in storage'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUploadLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Limit Reached'),
        content: const Text('You can only upload up to 5 photos per report. Please delete existing photos to add new ones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}