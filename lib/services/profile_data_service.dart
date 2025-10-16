import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Service zum Laden von Länder‑, Bundesland‑ und Bereichsprofilen aus
/// `assets/data/profiles.json`.
class ProfileDataService {
  static const String _assetPath = 'assets/data/profiles.json';

  Future<List<CountryProfile>> loadCountries() async {
    final dataString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> jsonData = json.decode(dataString);
    final List<dynamic> countries = jsonData['countries'] ?? [];
    return countries.map((e) => CountryProfile.fromJson(e)).toList();
  }
}

class CountryProfile {
  final String code;
  final String name;
  final List<StateProfile> states;

  CountryProfile({required this.code, required this.name, required this.states});

  factory CountryProfile.fromJson(Map<String, dynamic> json) {
    final List<dynamic> stateList = json['states'] ?? [];
    return CountryProfile(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      states: stateList.map((e) => StateProfile.fromJson(e)).toList(),
    );
  }
}

class StateProfile {
  final String code;
  final String name;
  final List<AreaProfile> areas;

  StateProfile({required this.code, required this.name, required this.areas});

  factory StateProfile.fromJson(Map<String, dynamic> json) {
    final List<dynamic> areaList = json['areas'] ?? [];
    return StateProfile(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      areas: areaList.map((e) => AreaProfile.fromJson(e)).toList(),
    );
  }
}

class AreaProfile {
  final String code;
  final String name;

  AreaProfile({required this.code, required this.name});

  factory AreaProfile.fromJson(Map<String, dynamic> json) {
    return AreaProfile(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}