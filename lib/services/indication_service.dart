import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pediaid/models/indication.dart';

class IndicationService {
  static const String _storageKey = 'indications';

  Future<List<Indication>> getAllIndications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) {
      await _initializeSampleData();
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

  Future<void> _initializeSampleData() async {
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

    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(sampleIndications.map((i) => i.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
