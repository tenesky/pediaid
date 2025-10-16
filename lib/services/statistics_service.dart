import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service zur Erfassung und Abfrage von Nutzungsstatistiken.
/// Für jeden Bereich der App (Indikationen, Rechner, Notfallmodus, Suche, Formeln,
/// Normwerte, Checklisten) wird ein Zähler geführt. Die Werte werden in
/// SharedPreferences gespeichert und bleiben zwischen den App‑Starts erhalten.
class StatisticsService {
  static const String _statsKey = 'usage_stats';

  /// Inkrementiert den Zähler für einen Bereich.
  Future<void> increment(String section) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = prefs.getString(_statsKey);
    Map<String, dynamic> map;
    if (stats == null) {
      map = {};
    } else {
      map = Map<String, dynamic>.from(
        Map<String, dynamic>.from(_decodeJson(stats)),
      );
    }
    final current = (map[section] ?? 0) as int;
    map[section] = current + 1;
    await prefs.setString(_statsKey, _encodeJson(map));
  }

  /// Liefert alle gespeicherten Statistiken als Map<String, int> zurück.
  Future<Map<String, int>> getAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = prefs.getString(_statsKey);
    if (stats == null) return {};
    final decoded = Map<String, dynamic>.from(_decodeJson(stats));
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  /// Setzt alle Statistiken zurück.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
  }

  Map<String, dynamic> _decodeJson(String jsonString) {
    return jsonString.isEmpty ? {} : Map<String, dynamic>.from(json.decode(jsonString));
  }

  String _encodeJson(Map<String, dynamic> map) {
    return map.isEmpty ? '{}' : json.encode(map);
  }
}