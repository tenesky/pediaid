import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pediaid/models/medication.dart';

class MedicationService {
  static const String _storageKey = 'medications';
  static const String _assetPath = 'assets/data/medications.json';

  Future<List<Medication>> getAllMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      await _loadInitialData();
      return getAllMedications();
    }
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Medication.fromJson(json)).toList();
  }

  Future<Medication?> getMedicationById(String id) async {
    final medications = await getAllMedications();
    try {
      return medications.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Medication>> getMedicationsByIndication(String indication) async {
    final medications = await getAllMedications();
    return medications.where((med) => med.indication == indication).toList();
  }

  Future<List<Medication>> searchMedications(String query) async {
    final medications = await getAllMedications();
    final lowerQuery = query.toLowerCase();
    return medications.where((med) => 
      med.name.toLowerCase().contains(lowerQuery) ||
      med.indication.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final assetString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(assetString);
      final meds = jsonList.map((e) => Medication.fromJson(e as Map<String, dynamic>)).toList();
      final encoded = json.encode(meds.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      final now = DateTime.now();
      final sampleMedications = [
        Medication(
          id: 'med_001',
          name: 'Adrenalin',
          indication: 'Anaphylaxie',
          dosePerKg: 0.01,
          unit: 'mg',
          maxDose: 0.5,
          route: 'IM',
          concentration: '1:1000 (1 mg/ml)',
          source: 'ERC 2025',
          warning: 'Bei Anaphylaxie sofort verabreichen',
          colorBand: 'red',
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med_002',
          name: 'Adrenalin',
          indication: 'Reanimation',
          dosePerKg: 0.01,
          unit: 'mg',
          maxDose: 1.0,
          route: 'IV',
          concentration: '1:10000 (0.1 mg/ml)',
          source: 'ERC 2025',
          warning: 'Alle 3–5 Minuten wiederholen',
          colorBand: 'red',
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med_003',
          name: 'Midazolam',
          indication: 'Krampfanfall',
          dosePerKg: 0.2,
          unit: 'mg',
          maxDose: 10.0,
          route: 'bukkal/nasal',
          concentration: '5 mg/ml',
          source: 'DIVI 2024',
          warning: 'Atemdepression möglich',
          colorBand: 'yellow',
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med_004',
          name: 'Salbutamol',
          indication: 'Asthma',
          dosePerKg: 0.15,
          unit: 'mg',
          maxDose: 5.0,
          route: 'inhalativ',
          concentration: '0.5 mg/ml',
          source: 'DGKJ 2023',
          warning: 'Bei schwerer Atemnot wiederholen',
          colorBand: 'blue',
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med_005',
          name: 'Prednisolon',
          indication: 'Asthma',
          dosePerKg: 2.0,
          unit: 'mg',
          maxDose: 60.0,
          route: 'PO/IV',
          concentration: 'variabel',
          source: 'DGKJ 2023',
          warning: null,
          colorBand: 'blue',
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med_006',
          name: 'Atropin',
          indication: 'Bradykardie',
          dosePerKg: 0.02,
          unit: 'mg',
          maxDose: 0.5,
          route: 'IV',
          concentration: '0.5 mg/ml',
          source: 'ERC 2025',
          warning: 'Mindestdosis 0.1 mg',
          colorBand: 'green',
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med_007',
          name: 'Diazepam',
          indication: 'Krampfanfall',
          dosePerKg: 0.3,
          unit: 'mg',
          maxDose: 10.0,
          route: 'rektal',
          concentration: '5 mg/ml',
          source: 'DIVI 2024',
          warning: 'Atemdepression möglich',
          colorBand: 'yellow',
          createdAt: now,
          updatedAt: now,
        ),
        Medication(
          id: 'med_008',
          name: 'Amiodaron',
          indication: 'Reanimation',
          dosePerKg: 5.0,
          unit: 'mg',
          maxDose: 300.0,
          route: 'IV',
          concentration: '50 mg/ml',
          source: 'ERC 2025',
          warning: 'Nach 3. Defibrillation',
          colorBand: 'red',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final jsonString = json.encode(sampleMedications.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    }
  }

  /// Public wrapper to force reloading medications from the bundled dataset.
  ///
  /// This can be invoked from UI code (e.g. via an update button) to
  /// overwrite any locally stored medications with the contents of the
  /// asset file. If loading fails the existing data remains unchanged.
  Future<void> reloadDataFromAssets() async {
    await _loadInitialData();
  }
}
