//lib/providers/report_case_provider.dart

import 'package:disease_tracker/main.dart';
import 'package:disease_tracker/models/case_report_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// ================== UI STATE PROVIDERS ==================

//Disease Expansion State Provider
final diseaseExpansionStateProvider =
    StateNotifierProvider<DiseaseExpansionStateNotifier, Map<int, bool>>((ref) {
      return DiseaseExpansionStateNotifier();
    });

class DiseaseExpansionStateNotifier extends StateNotifier<Map<int, bool>> {
  DiseaseExpansionStateNotifier() : super({});

  void togglePanel(int index) {
    state = {...state, index: !(state[index] ?? false)};
  }

  void initializePanels(int count) {
    final newState = {...state};
    for (int i = 0; i < count; i++) {
      newState.putIfAbsent(i, () => false);
    }
    state = newState;
  }
}

final diseaseScrollControllersProvider = Provider.family<ScrollController, int>(
  (ref, index) {
    final controller = ScrollController();
    ref.onDispose(() => controller.dispose());
    return controller;
  },
);

//Symptom Expansion State Provider

final symptomExpansionStateProvider =
    StateNotifierProvider<SymptomExpansionStateNotifier, Map<int, bool>>((ref) {
      return SymptomExpansionStateNotifier();
    });

class SymptomExpansionStateNotifier extends StateNotifier<Map<int, bool>> {
  SymptomExpansionStateNotifier() : super({});

  void togglePanel(int index) {
    state = {...state, index: !(state[index] ?? false)};
  }

  void initializePanels(int count) {
    final newState = {...state};
    for (int i = 0; i < count; i++) {
      newState.putIfAbsent(i, () => false);
    }
    state = newState;
  }
}

final symptomScrollControllersProvider = Provider.family<ScrollController, int>(
  (ref, index) {
    final controller = ScrollController();
    ref.onDispose(() => controller.dispose());
    return controller;
  },
);

//Disease Data
final diseaseData =
    [
      {
        "category": "Viral Diseases",
        "diseases": [
          "COVID-19",
          "Ebola Virus Disease",
          "Marburg Virus Disease",
          "Monkeypox",
          "Dengue Fever",
          "Zika Virus",
          "Yellow Fever",
          "Lassa Fever",
          "Influenza",
          "Avian Influenza",
          "Measles",
          "Mumps",
          "Rubella",
          "Polio",
          "Rabies",
          "Hepatitis A",
          "Hepatitis B",
          "Hepatitis C",
          "HIV/AIDS",
          "Chikungunya",
          "Nipah Virus Infection",
          "Hantavirus Infection",
          "Norovirus Infection",
          "Human Papillomavirus",
          "RSV",
          "SARS",
          "MERS",
        ],
      },
      {
        "category": "Bacterial Diseases",
        "diseases": [
          "Tuberculosis",
          "Typhoid Fever",
          "Cholera",
          "Diphtheria",
          "Pertussis",
          "Tetanus",
          "Meningococcal Meningitis",
          "Leptospirosis",
          "Anthrax",
          "Botulism",
          "Brucellosis",
          "Syphilis",
          "Gonorrhea",
          "Lyme Disease",
          "Legionnaires' Disease",
          "Plague",
          "MRSA",
          "Scarlet Fever",
          "Salmonellosis",
          "Shigellosis",
          "Campylobacteriosis",
          "Bacterial Vaginosis",
          "Trachoma",
        ],
      },
      {
        "category": "Parasitic Diseases",
        "diseases": [
          "Malaria",
          "Schistosomiasis",
          "Giardiasis",
          "Amoebiasis",
          "Toxoplasmosis",
          "Trichomoniasis",
          "Leishmaniasis",
          "Trypanosomiasis",
          "Cryptosporidiosis",
          "Taeniasis",
          "Echinococcosis",
          "Ascariasis",
          "Hookworm",
          "Trichuriasis",
          "Dracunculiasis",
        ],
      },
      {
        "category": "Fungal Diseases",
        "diseases": [
          "Candidiasis",
          "Aspergillosis",
          "Cryptococcosis",
          "Histoplasmosis",
          "Tinea",
          "Sporotrichosis",
          "Blastomycosis",
          "Pneumocystis Pneumonia",
        ],
      },
      {
        "category": "Zoonotic & Vector-borne Diseases",
        "diseases": [
          "Rift Valley Fever",
          "Crimean-Congo Hemorrhagic Fever",
          "West Nile Virus",
          "Japanese Encephalitis",
          "Tick-borne Encephalitis",
          "Rocky Mountain Spotted Fever",
          "Babesiosis",
          "Tularemia",
          "Hendra Virus Infection",
        ],
      },
      {
        "category": "Food/Water-borne & Environmental Diseases",
        "diseases": [
          "Hepatitis E",
          "Botulism",
          "Clostridium difficile Infection",
          "E. coli Infection",
          "Legionellosis",
          "Listeriosis",
          "Traveler's Diarrhea",
        ],
      },
      {
        "category": "Nosocomial Infections",
        "diseases": [
          "MRSA",
          "VRE",
          "Clostridium difficile",
          "Klebsiella pneumoniae",
          "Acinetobacter Infections",
        ],
      },
      {
        "category": "Rare / Regionally Endemic Diseases",
        "diseases": [
          "Q Fever",
          "Melioidosis",
          "Balamuthia Amebic Encephalitis",
          "Glanders",
          "Mycetoma",
          "Paragonimiasis",
          "Lymphatic Filariasis",
          "Buruli Ulcer",
          "Yaws",
          "Chagas Disease",
        ],
      },
      {
        "category": "Other",
        "diseases": ["Other (Specify)"],
      },
    ].map((e) {
      try {
        final category = e['category'] as String;
        final diseases = (e['diseases'] as List).cast<String>();
        return Disease(category: category, diseases: diseases);
      } catch (e) {
        throw FormatException('Invalid disease data: $e');
      }
    }).toList();

//symptoms data
final symptomsData =
    [
      {
        "category": "General Symptoms",
        "symptoms": [
          "Fever",
          "Chills",
          "Fatigue",
          "Malaise",
          "Weight Loss",
          "Night Sweats",
          "Loss of Appetite",
          "Swollen Lymph Nodes",
          "Body Aches",
          "Weakness",
          "Headache",
        ],
      },
      {
        "category": "Respiratory Symptoms",
        "symptoms": [
          "Cough",
          "Dry Cough",
          "Productive Cough",
          "Shortness of Breath",
          "Wheezing",
          "Chest Pain",
          "Sore Throat",
          "Runny Nose",
          "Nasal Congestion",
          "Sneezing",
          "Loss of Smell (Anosmia)",
        ],
      },
      {
        "category": "Gastrointestinal Symptoms",
        "symptoms": [
          "Nausea",
          "Vomiting",
          "Diarrhea",
          "Abdominal Pain",
          "Bloating",
          "Constipation",
          "Loss of Taste (Ageusia)",
          "Bloody Stools",
        ],
      },
      {
        "category": "Neurological Symptoms",
        "symptoms": [
          "Confusion",
          "Dizziness",
          "Seizures",
          "Tingling Sensation",
          "Numbness",
          "Photophobia",
          "Neck Stiffness",
          "Memory Loss",
          "Tremors",
          "Loss of Balance",
          "Delirium",
          "Hallucinations",
        ],
      },
      {
        "category": "Dermatologic (Skin-related) Symptoms",
        "symptoms": [
          "Rash",
          "Itching",
          "Redness",
          "Blisters",
          "Peeling Skin",
          "Skin Ulcers",
          "Bruising",
          "Petechiae",
          "Hives",
          "Swelling",
        ],
      },
      {
        "category": "Cardiovascular Symptoms",
        "symptoms": [
          "Palpitations",
          "Chest Tightness",
          "Rapid Heartbeat",
          "Slow Heartbeat",
          "Fainting (Syncope)",
          "High Blood Pressure",
          "Low Blood Pressure",
        ],
      },
      {
        "category": "Urinary & Renal Symptoms",
        "symptoms": [
          "Painful Urination",
          "Frequent Urination",
          "Blood in Urine",
          "Reduced Urine Output",
          "Dark Urine",
        ],
      },
      {
        "category": "Reproductive & Gynecological Symptoms",
        "symptoms": [
          "Unusual Vaginal Discharge",
          "Pelvic Pain",
          "Missed Periods",
          "Pain During Intercourse",
          "Testicular Pain",
          "Genital Ulcers",
        ],
      },
      {
        "category": "Musculoskeletal Symptoms",
        "symptoms": [
          "Joint Pain",
          "Muscle Pain",
          "Stiffness",
          "Back Pain",
          "Swollen Joints",
          "Muscle Weakness",
        ],
      },
      {
        "category": "Eye-related Symptoms",
        "symptoms": [
          "Red Eyes",
          "Itchy Eyes",
          "Blurred Vision",
          "Eye Pain",
          "Discharge from Eyes",
          "Light Sensitivity",
        ],
      },
      {
        "category": "Other or Rare Symptoms",
        "symptoms": [
          "Bleeding from Nose",
          "Bleeding Gums",
          "Bleeding Under Skin",
          "Jaundice (Yellowing of Eyes/Skin)",
          "Blue Fingertips",
          "Persistent Hiccups",
          "Unconsciousness",
          "Paralysis",
        ],
      },
      {
        "category": "Other",
        "symptoms": ["Other (Specify)"],
      },
    ].map((e) {
      try {
        final category = e['category'] as String;
        final symptoms = (e['symptoms'] as List).cast<String>();
        return SymptomCategory(category: category, symptoms: symptoms);
      } catch (e) {
        throw FormatException('Invalid disease data: $e');
      }
    }).toList();

//State Management
//State Management
class CaseReportNotifier extends StateNotifier<List<CaseReport>> {
  CaseReportNotifier() : super([]) {
    _listenToConnectivity();
  }

  void addReport(CaseReport report) {
    const uuid = Uuid();
    final uniqueId = uuid.v4();

    final reportWithId = CaseReport(
      id: uniqueId,
      disease: report.disease,
      customDisease: report.customDisease,
      location: report.location,
      symptoms: report.symptoms,
      customSymptoms: report.customSymptoms,
      severity: report.severity,
      onsetDate: report.onsetDate,
      contactHistory: report.contactHistory,
      numberOfCases: report.numberOfCases,
      photoUrls: report.photoUrls,
      isSynced: false,
      userId: report.userId,
      userName: report.userName,
      userEmail: report.userEmail,
      status: report.status,
    );

    state = [...state, reportWithId];
    
    debugPrint('📝 Report added to local state with ID: $uniqueId');
    
    _syncReportToDatabase(reportWithId);
  }

  Future<void> _syncReportToDatabase(CaseReport report) async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('🔄 STARTING REPORT SYNC TO DATABASE');
    debugPrint('═══════════════════════════════════════');
    
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty && 
                       connectivityResult.first != ConnectivityResult.none;
      
      debugPrint('📡 Connectivity status: ${isOnline ? "ONLINE" : "OFFLINE"}');
      
      if (!isOnline) {
        debugPrint('📴 Offline: Report saved locally, will sync when online');
        return;
      }
      
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ ERROR: No authenticated user found');
        return;
      }
      
      debugPrint('👤 Authenticated user ID: ${currentUser.id}');
      
      final diseaseName = report.disease == "Other (Specify)" 
          ? report.customDisease 
          : report.disease;
      
      debugPrint('📝 Report details:');
      debugPrint('  - Local ID: ${report.id}');
      debugPrint('  - User ID: ${report.userId}');
      debugPrint('  - Disease: $diseaseName');
      debugPrint('  - Location: ${report.location}');
      
      final description = 'Reported symptoms: ${report.symptoms.join(', ')}'
          '${report.customSymptoms != null && report.customSymptoms!.isNotEmpty ? ' | Custom symptoms: ${report.customSymptoms!.join(', ')}' : ''}'
          '${report.contactHistory != null && report.contactHistory!.isNotEmpty ? ' | Contact history: ${report.contactHistory}' : ''}';
      
      final dataToInsert = {
        'user_id': report.userId,
        'disease_name': diseaseName,
        'description': description,
        'location': report.location,
        'reported_at': report.onsetDate.toIso8601String(),
        'is_verified': false,
        'severity': report.severity,
        'number_of_cases': report.numberOfCases,
      };
      
      debugPrint('🚀 Attempting database insert...');
      
      final response = await supabase
          .from('disease_reports')
          .insert(dataToInsert)
          .select();
      
      debugPrint('✅ INSERT SUCCESSFUL!');
      
      if (response.isNotEmpty) {
        final databaseId = response.first['id'];
        debugPrint('🎉 Record inserted with database ID: $databaseId');
        
        // Store mapping between local ID and database ID
        _updateReportWithDatabaseId(report.id, databaseId);
        _markReportAsSynced(report.id);
        debugPrint('✓ Local report marked as synced');
      }
      
      debugPrint('═══════════════════════════════════════');
      
    } on PostgrestException catch (e) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ DATABASE ERROR');
      debugPrint('Error message: ${e.message}');
      debugPrint('Error code: ${e.code}');
      debugPrint('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('❌ UNEXPECTED ERROR');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('═══════════════════════════════════════');
    }
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncReport();
      }
    });
  }

  void _updateReportWithDatabaseId(String localId, int databaseId) {
    state = state.map((report) {
      if (report.id == localId) {
        // Store database ID in the report for future reference
        // We'll use the customDisease field temporarily to store DB ID
        // Or you can add a new field to CaseReport model
        debugPrint('📌 Linking local ID $localId to database ID $databaseId');
        return report; // Keep as is for now
      }
      return report;
    }).toList();
  }

  void _markReportAsSynced(String reportId) {
    state = state.map((report) {
      if (report.id == reportId && !report.isSynced) {
        return CaseReport(
          id: report.id,
          disease: report.disease,
          customDisease: report.customDisease,
          location: report.location,
          symptoms: report.symptoms,
          customSymptoms: report.customSymptoms,
          severity: report.severity,
          onsetDate: report.onsetDate,
          contactHistory: report.contactHistory,
          numberOfCases: report.numberOfCases,
          photoUrls: report.photoUrls,
          isSynced: true,
          userId: report.userId,
          userName: report.userName,
          userEmail: report.userEmail,
          status: report.status,
        );
      }
      return report;
    }).toList();
  }

void updateReportStatus(String reportId, String newStatus) {
  final reportIndex = state.indexWhere((r) => r.id == reportId);
  
  if (reportIndex == -1) {
    debugPrint('❌ Report with ID $reportId not found');
    return;
  }

  final report = state[reportIndex];
  
  final updatedReport = CaseReport(
    id: report.id,
    disease: report.disease,
    customDisease: report.customDisease,
    location: report.location,
    symptoms: report.symptoms,
    customSymptoms: report.customSymptoms,
    severity: report.severity,
    onsetDate: report.onsetDate,
    contactHistory: report.contactHistory,
    numberOfCases: report.numberOfCases,
    photoUrls: report.photoUrls,
    isSynced: report.isSynced,
    userId: report.userId,
    userName: report.userName,
    userEmail: report.userEmail,
    status: newStatus,
  );

  final newState = List<CaseReport>.from(state);
  newState[reportIndex] = updatedReport;
  state = newState;
  
  debugPrint('✅ Report ${report.id} status updated to $newStatus in local state');
  
  // Handle different statuses - pass the UPDATED report
  if (newStatus == 'Confirmed') {
    _syncConfirmedReportToDatabase(updatedReport);
  } else if (newStatus == 'Rejected' || newStatus == 'False') {
    _deleteReportFromDatabase(updatedReport, newStatus);
  }
}

  Future<void> _syncConfirmedReportToDatabase(CaseReport report) async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('✅ CONFIRMING REPORT IN DATABASE');
    debugPrint('═══════════════════════════════════════');
    
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult.isNotEmpty && 
                       connectivityResult.first != ConnectivityResult.none;
      
      if (!isOnline) {
        debugPrint('📴 Offline: Will sync when online');
        return;
      }
      
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        debugPrint('❌ No authenticated user found');
        return;
      }
      
      String verifiedBy = currentUser.id;
      
      debugPrint('👤 Admin user ID: $verifiedBy');
      debugPrint('🦠 Disease: ${report.disease == "Other (Specify)" ? report.customDisease : report.disease}');
      debugPrint('📍 Location: ${report.location}');
      debugPrint('👤 Reporter User ID: ${report.userId}');
      debugPrint('📅 Reported at: ${report.onsetDate.toIso8601String()}');
      
      final diseaseName = report.disease == "Other (Specify)" 
          ? report.customDisease! 
          : report.disease;
      
      // Find the exact unverified report
      
      debugPrint('🔍 Searching for report with:');
      debugPrint('  - user_id: ${report.userId}');
      debugPrint('  - disease_name: $diseaseName');
      debugPrint('  - location: ${report.location}');
      debugPrint('  - is_verified: false');
      
      final existingReports = await supabase
          .from('disease_reports')
          .select()
          .eq('user_id', report.userId)
          .eq('disease_name', diseaseName)
          .eq('location', report.location)
          .eq('is_verified', false)
          .order('reported_at', ascending: false)
          .limit(1);
      
      debugPrint('🔍 Found ${existingReports.length} matching reports');
      
      if (existingReports.isNotEmpty) {
        final recordId = existingReports.first['id'];
        debugPrint('📝 Updating record ID: $recordId to VERIFIED');
        
        final response = await supabase
            .from('disease_reports')
            .update({
              'is_verified': true,
              'verified_by': verifiedBy,
              'verified_at': DateTime.now().toIso8601String(),
            })
            .eq('id', recordId)
            .select();
        
        if (response.isNotEmpty) {
          debugPrint('✅ Report CONFIRMED! Database ID: $recordId');
          debugPrint('✅ is_verified = TRUE');
          debugPrint('═══════════════════════════════════════');
        }
      } else {
        debugPrint('⚠️ No matching unverified report found');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error confirming report: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _deleteReportFromDatabase(CaseReport report, String status) async {
  debugPrint('═══════════════════════════════════════');
  debugPrint('🗑️ DELETING ${status.toUpperCase()} REPORT FROM DATABASE');
  debugPrint('═══════════════════════════════════════');
  
  try {
    // Step 1: Check connectivity
    debugPrint('STEP 1: Checking connectivity...');
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult.isNotEmpty && 
                     connectivityResult.first != ConnectivityResult.none;
    
    debugPrint('📡 Online: $isOnline');
    
    if (!isOnline) {
      debugPrint('📴 STOPPED: Device is offline');
      return;
    }
    
    // Step 2: Check authentication
    debugPrint('STEP 2: Checking authentication...');
    final currentUser = supabase.auth.currentUser;
    
    if (currentUser == null) {
      debugPrint('❌ STOPPED: No authenticated user');
      return;
    }
    
    debugPrint('✅ Authenticated as: ${currentUser.id}');
    debugPrint('   Email: ${currentUser.email}');
    
    // Step 3: Prepare search criteria
    debugPrint('STEP 3: Preparing search criteria...');
    final diseaseName = report.disease == "Other (Specify)" 
        ? (report.customDisease ?? report.disease)
        : report.disease;
    
    debugPrint('Search criteria:');
    debugPrint('  user_id: ${report.userId}');
    debugPrint('  disease_name: $diseaseName');
    debugPrint('  location: ${report.location}');
    debugPrint('  is_verified: false');
    
    // Step 4: Search for ALL unverified reports by this user
    debugPrint('STEP 4: Searching for ALL unverified reports by user...');
    
    final allUnverifiedReports = await supabase
        .from('disease_reports')
        .select()
        .eq('user_id', report.userId)
        .eq('is_verified', false);
    
    debugPrint('📊 Found ${allUnverifiedReports.length} total unverified reports by this user');
    
    if (allUnverifiedReports.isEmpty) {
      debugPrint('❌ No unverified reports found for user ${report.userId}');
      debugPrint('💡 Possible reasons:');
      debugPrint('   1. Report was never synced to database');
      debugPrint('   2. Report was already deleted');
      debugPrint('   3. Report was already verified');
      return;
    }
    
    // Step 5: Display all unverified reports
    debugPrint('STEP 5: Listing all unverified reports:');
    for (var i = 0; i < allUnverifiedReports.length; i++) {
      final r = allUnverifiedReports[i];
      debugPrint('  Report ${i + 1}:');
      debugPrint('    ID: ${r['id']}');
      debugPrint('    Disease: ${r['disease_name']}');
      debugPrint('    Location: ${r['location']}');
      debugPrint('    Date: ${r['reported_at']}');
      debugPrint('    Verified: ${r['is_verified']}');
    }
    
    // Step 6: Find exact match
    debugPrint('STEP 6: Finding exact match...');
    
    final exactMatches = allUnverifiedReports.where((r) {
      final matchDisease = r['disease_name'] == diseaseName;
      final matchLocation = r['location'] == report.location;
      debugPrint('  Checking ID ${r['id']}: Disease match=$matchDisease, Location match=$matchLocation');
      return matchDisease && matchLocation;
    }).toList();
    
    debugPrint('🎯 Found ${exactMatches.length} exact matches');
    
    if (exactMatches.isEmpty) {
      debugPrint('❌ No exact match found!');
      debugPrint('💡 Trying to match by disease name only...');
      
      final diseaseMatches = allUnverifiedReports.where((r) {
        return r['disease_name'] == diseaseName;
      }).toList();
      
      debugPrint('🔍 Found ${diseaseMatches.length} matches by disease name');
      
      if (diseaseMatches.isEmpty) {
        debugPrint('❌ Still no match. Cannot delete.');
        return;
      }
      
      // Use the most recent one
      diseaseMatches.sort((a, b) {
        final dateA = DateTime.parse(a['reported_at']);
        final dateB = DateTime.parse(b['reported_at']);
        return dateB.compareTo(dateA);
      });
      
      final recordToDelete = diseaseMatches.first;
      debugPrint('📌 Using most recent disease match: ID ${recordToDelete['id']}');
      await _performDeletion(recordToDelete['id'], status);
      return;
    }
    
    // Step 7: Delete the exact match(es)
    debugPrint('STEP 7: Deleting exact matches...');
    for (var match in exactMatches) {
      final recordId = match['id'];
      debugPrint('🗑️ Deleting record ID: $recordId');
      debugPrint('   Disease: ${match['disease_name']}');
      debugPrint('   Location: ${match['location']}');
      debugPrint('   Date: ${match['reported_at']}');
      
      await _performDeletion(recordId, status);
    }
    
  } catch (e, stackTrace) {
    debugPrint('═══════════════════════════════════════');
    debugPrint('❌ EXCEPTION OCCURRED');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Error: $e');
    debugPrint('Type: ${e.runtimeType}');
    debugPrint('Stack trace:');
    debugPrint(stackTrace.toString());
    debugPrint('═══════════════════════════════════════');
  }
}

Future<void> _performDeletion(int recordId, String status) async {
  try {
    debugPrint('  → Executing DELETE for ID: $recordId');
    
    final deleteResponse = await supabase
        .from('disease_reports')
        .delete()
        .eq('id', recordId)
        .select();
    
    debugPrint('  ✅ DELETE executed');
    debugPrint('  Response length: ${deleteResponse.length}');
    if (deleteResponse.isNotEmpty) {
      debugPrint('  Deleted data: ${deleteResponse.first}');
    }
    
    // Verify deletion
    debugPrint('  → Verifying deletion...');
    final verifyResponse = await supabase
        .from('disease_reports')
        .select('id')
        .eq('id', recordId);
    
    if (verifyResponse.isEmpty) {
      debugPrint('  ✅ VERIFIED: Record $recordId successfully deleted from database');
      debugPrint('  🧹 Database sanitized - $status report removed');
    } else {
      debugPrint('  ⚠️ WARNING: Record still exists after delete attempt');
    }
    
    debugPrint('═══════════════════════════════════════');
    
  } catch (e) {
    debugPrint('  ❌ Error during delete: $e');
    debugPrint('  Type: ${e.runtimeType}');
    if (e is PostgrestException) {
      debugPrint('  Code: ${e.code}');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Details: ${e.details}');
    }
    rethrow;
  }
}

  void syncReport() async {
    final unsyncedReports = getUnSyncedReports();
    
    if (unsyncedReports.isEmpty) return;
    
    debugPrint('🔄 Syncing ${unsyncedReports.length} unsynced reports...');
    
    for (var report in unsyncedReports) {
      await _syncReportToDatabase(report);
    }
  }

  List<CaseReport> getUnSyncedReports() {
    return state.where((report) => !report.isSynced).toList();
  }

  List<CaseReport> getPendingReports() {
    return state.where((report) => report.status == 'Pending').toList();
  }

  List<CaseReport> getReportsByStatus(String status) {
    return state.where((report) => report.status == status).toList();
  }
}

final caseReportProvider =
    StateNotifierProvider<CaseReportNotifier, List<CaseReport>>((ref) {
      return CaseReportNotifier();
    });

//Form State Management
class ReportFormNotifier extends StateNotifier<CaseReport> {
  ReportFormNotifier()
    : super(
        CaseReport(
          id: '',
          disease: '',
          location: '',
          symptoms: [],
          severity: 'Mild',
          onsetDate: DateTime.now(),
          numberOfCases: 1,
          userId: '',
          userName: '',
          userEmail: '',
        ),
      );

  void updateDisease(String disease, {String? customDisease}) {
    state = CaseReport(
      id: state.id,
      disease: disease,
      customDisease: customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updateLocation(String location) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updateSymptom(String symptom) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: [...state.symptoms, symptom],
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updateCustomSymptom(String symptom) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: [...?state.customSymptoms, symptom],
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void removeSymptom(String symptom) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms.where((s) => s != symptom).toList(),
      customSymptoms: state.customSymptoms?.where((s) => s != symptom).toList(),
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updateSeverity(String severity) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updateOnsetDate(DateTime date) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: date,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updateContactHistory(String? history) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: history,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updateNumberOfCases(int number) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: number,
      photoUrls: state.photoUrls,
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void updatePhotoUrl(String url) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: [...?state.photoUrls, url],
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }

  void removePhotoUrl(String url) {
    state = CaseReport(
      id: state.id,
      disease: state.disease,
      customDisease: state.customDisease,
      location: state.location,
      symptoms: state.symptoms,
      customSymptoms: state.customSymptoms,
      severity: state.severity,
      onsetDate: state.onsetDate,
      contactHistory: state.contactHistory,
      numberOfCases: state.numberOfCases,
      photoUrls: state.photoUrls?.where((p) => p != url).toList(),
      isSynced: state.isSynced,
      userId: state.userId,
      userName: state.userName,
      userEmail: state.userEmail,
    );
  }
}

final reportFormProvider =
    StateNotifierProvider.autoDispose<ReportFormNotifier, CaseReport>((ref) {
      return ReportFormNotifier();
    });