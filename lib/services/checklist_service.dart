import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pediaid/models/checklist.dart';

/// Service zum Laden von Checklisten aus dem lokalen Speicher oder
/// den mitgelieferten JSON‑Dateien. Beim ersten Start werden die
/// Checklisten aus den Assets geladen und in SharedPreferences
/// persistiert. Spätere Aufrufe lesen aus dem Speicher, damit auch
/// offline Aktualisierungen möglich bleiben.
class ChecklistService {
  static const String _storageKey = 'checklists';
  static const String _assetPath = 'assets/data/checklists.json';

  Future<List<Checklist>> getAllChecklists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      await _loadInitialData();
      return getAllChecklists();
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Checklist.fromJson(json)).toList();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final assetString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(assetString);
      final checklists = jsonList.map((e) => Checklist.fromJson(e as Map<String, dynamic>)).toList();
      final encoded = json.encode(checklists.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Fallback auf leere Liste, falls Laden fehlschlägt
      await prefs.setString(_storageKey, json.encode([]));
    }
  }

  /// Überschreibt den lokalen Speicher mit den Assets, z.B. nach einem Update.
  Future<void> reloadDataFromAssets() async {
    await _loadInitialData();
  }
}