import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pediaid/models/guideline.dart';

/// Service zum Laden von Leitlinieninformationen aus lokalen JSON‑Dateien.
/// Die Leitlinien werden beim ersten Start aus dem Asset geladen und
/// anschließend in den SharedPreferences gespeichert, um Offline‑Updates
/// zu ermöglichen. Eine nachträgliche Aktualisierung kann über
/// [reloadDataFromAssets] durchgeführt werden.
class GuidelineService {
  static const String _storageKey = 'guidelines';
  static const String _assetPath = 'assets/data/guidelines.json';

  Future<List<Guideline>> getAllGuidelines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      await _loadInitialData();
      return getAllGuidelines();
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Guideline.fromJson(json)).toList();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final assetString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(assetString);
      final guidelines = jsonList.map((e) => Guideline.fromJson(e as Map<String, dynamic>)).toList();
      final encoded = json.encode(guidelines.map((g) => g.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      await prefs.setString(_storageKey, json.encode([]));
    }
  }

  Future<void> reloadDataFromAssets() async {
    await _loadInitialData();
  }
}