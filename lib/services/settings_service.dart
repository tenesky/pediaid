import 'package:shared_preferences/shared_preferences.dart';

enum WeightUnit { kg, lbs }
enum LengthUnit { cm, inch }

class SettingsService {
  static const String _disclaimerKey = 'disclaimer_accepted';
  static const String _lastUpdateKey = 'last_update_date';

  // Units and defaults
  static const String _weightUnitKey = 'unit_weight';
  static const String _lengthUnitKey = 'unit_length';
  static const String _defaultAgeYearsKey = 'default_age_years';
  static const String _defaultWeightKgKey = 'default_weight_kg';

  // Regional profiles
  static const String _profileLevelKey = 'profile_level'; // general | state | area
  static const String _profileStateKey = 'profile_state';
  static const String _profileAreaKey = 'profile_area';
  static const String _profileFilterOnlyKey = 'profile_filter_only'; // bool

  // Neues Feld für Länderprofile
  static const String _profileCountryKey = 'profile_country';

  // Accessibility
  static const String _a11yLargeTextKey = 'a11y_large_text';
  static const String _a11yHighContrastKey = 'a11y_high_contrast';

  // Disclaimer
  Future<bool> hasAcceptedDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerKey) ?? false;
  }

  Future<void> acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerKey, true);
  }

  // Update date
  Future<String> getLastUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateKey) ?? '10/2025';
  }

  // Regional profile getters/setters
  Future<String> getProfileLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileLevelKey) ?? 'general';
  }

  Future<void> setProfileLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileLevelKey, level);
  }

  Future<String?> getProfileState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileStateKey);
  }

  Future<void> setProfileState(String? state) async {
    final prefs = await SharedPreferences.getInstance();
    if (state == null) {
      await prefs.remove(_profileStateKey);
    } else {
      await prefs.setString(_profileStateKey, state);
    }
  }

  Future<String?> getProfileArea() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileAreaKey);
  }

  Future<void> setProfileArea(String? area) async {
    final prefs = await SharedPreferences.getInstance();
    if (area == null) {
      await prefs.remove(_profileAreaKey);
    } else {
      await prefs.setString(_profileAreaKey, area);
    }
  }

  // Länderprofil
  Future<String?> getProfileCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileCountryKey);
  }

  Future<void> setProfileCountry(String? country) async {
    final prefs = await SharedPreferences.getInstance();
    if (country == null) {
      await prefs.remove(_profileCountryKey);
    } else {
      await prefs.setString(_profileCountryKey, country);
    }
  }

  Future<bool> getProfileFilterOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileFilterOnlyKey) ?? false;
  }

  Future<void> setProfileFilterOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileFilterOnlyKey, value);
  }

  // Accessibility
  Future<bool> getLargeTextEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_a11yLargeTextKey) ?? false;
  }

  Future<void> setLargeTextEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_a11yLargeTextKey, value);
  }

  Future<bool> getHighContrastEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_a11yHighContrastKey) ?? false;
  }

  Future<void> setHighContrastEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_a11yHighContrastKey, value);
  }

  Future<void> setLastUpdateDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateKey, date);
  }

  // Unit preferences
  Future<WeightUnit> getWeightUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_weightUnitKey) ?? 'kg';
    return value == 'lbs' ? WeightUnit.lbs : WeightUnit.kg;
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightUnitKey, unit == WeightUnit.lbs ? 'lbs' : 'kg');
  }

  Future<LengthUnit> getLengthUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lengthUnitKey) ?? 'cm';
    return value == 'inch' ? LengthUnit.inch : LengthUnit.cm;
  }

  Future<void> setLengthUnit(LengthUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lengthUnitKey, unit == LengthUnit.inch ? 'inch' : 'cm');
  }

  // Default values
  Future<double> getDefaultAgeYears() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_defaultAgeYearsKey) ?? 5.0;
  }

  Future<void> setDefaultAgeYears(double ageYears) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_defaultAgeYearsKey, ageYears);
  }

  Future<double> getDefaultWeightKg() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_defaultWeightKgKey) ?? 20.0;
  }

  Future<void> setDefaultWeightKg(double weightKg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_defaultWeightKgKey, weightKg);
  }
}
