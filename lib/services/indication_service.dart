import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pediaid/models/indication.dart';

class IndicationService {
  static const String _storageKey = 'indications';
  static const String _assetPath = 'assets/data/indications.json';

  Future<List<Indication>> getAllIndications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      // If no data in local storage, load from bundled assets. Should this
      // fail (e.g. during development), fallback to the built-in sample data.
      await _loadInitialData();
      return getAllIndications();
    }
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Indication.fromJson(json)).toList();
  }

  Future<Indication?> getIndicationById(String id) async {
    final indications = await getAllIndications();
    try {
      return indications.firstWhere((ind) => ind.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      // Attempt to load indication definitions from the bundled JSON asset.
      final assetString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(assetString);
      final indications = jsonList.map((e) => Indication.fromJson(e as Map<String, dynamic>)).toList();
      final encoded = json.encode(indications.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // If loading from assets fails (e.g. during development or missing file),
      // fall back to some hard coded sample data. Using DateTime.now() ensures
      // unique timestamps each run.
      final now = DateTime.now();
      final sampleIndications = [
        Indication(
          id: 'ind_001',
          name: 'Anaphylaxie',
          description: 'Lebensbedrohliche allergische Reaktion',
          iconName: 'warning',
          colorBand: 'red',
          medicationIds: ['med_001'],
          createdAt: now,
          updatedAt: now,
        ),
        Indication(
          id: 'ind_002',
          name: 'Reanimation',
          description: 'Herz-Kreislauf-Stillstand',
          iconName: 'favorite',
          colorBand: 'red',
          medicationIds: ['med_002', 'med_008'],
          createdAt: now,
          updatedAt: now,
        ),
        Indication(
          id: 'ind_003',
          name: 'Krampfanfall',
          description: 'Zerebrale Krampfaktivität',
          iconName: 'flash_on',
          colorBand: 'yellow',
          medicationIds: ['med_003', 'med_007'],
          createdAt: now,
          updatedAt: now,
        ),
        Indication(
          id: 'ind_004',
          name: 'Asthma',
          description: 'Akute Atemwegsobstruktion',
          iconName: 'air',
          colorBand: 'blue',
          medicationIds: ['med_004', 'med_005'],
          createdAt: now,
          updatedAt: now,
        ),
        Indication(
          id: 'ind_005',
          name: 'Bradykardie',
          description: 'Verlangsamter Herzschlag',
          iconName: 'monitor_heart',
          colorBand: 'green',
          medicationIds: ['med_006'],
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final jsonString = json.encode(sampleIndications.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    }
  }

  /// Public wrapper to force reloading indications from the bundled dataset.
  ///
  /// This can be invoked from UI code (e.g. via an update button) to
  /// overwrite any locally stored indications with the contents of the
  /// asset file. If loading fails the existing data remains unchanged.
  Future<void> reloadDataFromAssets() async {
    await _loadInitialData();
  }
}
