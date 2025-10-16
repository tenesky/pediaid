import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service zum Verwalten von Favoriten. Die Favoriten werden in SharedPreferences
/// als Map gespeichert, die eine Liste von IDs pro Kategorie enthält (z. B.
/// 'indication', 'checklist', 'guideline').
class FavoriteService {
  static const String _prefsKey = 'favorites';

  Future<Map<String, List<String>>> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null || jsonString.isEmpty) return {};
    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, List<String>.from(value as List)));
  }

  Future<void> _saveFavorites(Map<String, List<String>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(data));
  }

  /// Gibt `true` zurück, wenn die ID in der Kategorie als Favorit markiert ist.
  Future<bool> isFavorite(String category, String id) async {
    final data = await _loadFavorites();
    final list = data[category] ?? [];
    return list.contains(id);
  }

  /// Gibt alle Favoriten einer Kategorie zurück. Gibt eine leere Liste zurück,
  /// wenn keine vorhanden.
  Future<List<String>> getFavorites(String category) async {
    final data = await _loadFavorites();
    return List<String>.from(data[category] ?? []);
  }

  /// Fügt einen Favoriten hinzu oder entfernt ihn, wenn er schon existiert.
  Future<void> toggleFavorite(String category, String id) async {
    final data = await _loadFavorites();
    final list = data[category] ?? [];
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    data[category] = list;
    await _saveFavorites(data);
  }

  /// Entfernt alle Favoriten einer Kategorie.
  Future<void> clearCategory(String category) async {
    final data = await _loadFavorites();
    data.remove(category);
    await _saveFavorites(data);
  }

  /// Leert sämtliche Favoriten.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}