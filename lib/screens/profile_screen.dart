import 'package:flutter/material.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/services/profile_data_service.dart';
import 'package:pediaid/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _settings = SettingsService();
  final _profileDataService = ProfileDataService();

  String _level = 'general';
  String? _state;
  String? _area;
  String? _country;
  bool _filterOnly = false;

  // Dynamisch geladene Listen für Länder, Bundesländer und Bereiche.
  List<CountryProfile> _countryProfiles = [];
  List<StateProfile> _availableStates = [];
  List<AreaProfile> _availableAreas = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final level = await _settings.getProfileLevel();
    final state = await _settings.getProfileState();
    final area = await _settings.getProfileArea();
    final country = await _settings.getProfileCountry();
    final filter = await _settings.getProfileFilterOnly();
    // Lade Länderprofile aus JSON.
    final countries = await _profileDataService.loadCountries();
    // Bestimme verfügbare Staaten und Bereiche basierend auf gespeicherten Werten.
    List<StateProfile> states = [];
    List<AreaProfile> areas = [];
    CountryProfile? selectedCountry;
    if (country != null) {
      selectedCountry = countries.firstWhere(
        (c) => c.name == country || c.code == country,
        orElse: () => countries.isNotEmpty ? countries.first : CountryProfile(code: '', name: '', states: []),
      );
      states = selectedCountry.states;
    }
    if (state != null && selectedCountry != null) {
      final s = selectedCountry.states.firstWhere(
        (st) => st.name == state || st.code == state,
        orElse: () => StateProfile(code: '', name: '', areas: []),
      );
      areas = s.areas;
    }
    setState(() {
      _level = level;
      _state = state;
      _area = area;
      _country = country;
      _filterOnly = filter;
      _countryProfiles = countries;
      _availableStates = states;
      _availableAreas = areas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile – Leitlinien')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Profil-Ebene'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'general', label: Text('Allgemein')),
                      ButtonSegment(value: 'country', label: Text('Land')),
                      ButtonSegment(value: 'state', label: Text('Bundesland')),
                      ButtonSegment(value: 'area', label: Text('Bereich')),
                    ],
                    selected: {_level},
                    onSelectionChanged: (v) {
                      final selectedLevel = v.first;
                      setState(() {
                        _level = selectedLevel;
                        // Reset nachgeordnete Felder, wenn sich die Ebene ändert.
                        if (selectedLevel == 'general') {
                          _country = null;
                          _state = null;
                          _area = null;
                          _availableStates = [];
                          _availableAreas = [];
                        } else if (selectedLevel == 'country') {
                          _state = null;
                          _area = null;
                          // Staatenliste basiert auf gewähltem Land, falls vorhanden
                          final selected = _countryProfiles.firstWhere(
                            (c) => c.name == _country,
                            orElse: () => CountryProfile(code: '', name: '', states: []),
                          );
                          _availableStates = selected.states;
                          _availableAreas = [];
                        } else if (selectedLevel == 'state') {
                          _area = null;
                          // Bereichsliste basiert auf gewähltem Bundesland
                          final selectedState = _availableStates.firstWhere(
                            (s) => s.name == _state,
                            orElse: () => StateProfile(code: '', name: '', areas: []),
                          );
                          _availableAreas = selectedState.areas;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Abhängig von der gewählten Ebene die passenden Eingabefelder anzeigen
                  if (_level == 'country')
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Land',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _country,
                      items: _countryProfiles.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _country = v;
                          // Aktualisiere die Staatenliste beim Länderwechsel
                          final selected = _countryProfiles.firstWhere((c) => c.name == v, orElse: () => CountryProfile(code: '', name: '', states: []));
                          _availableStates = selected.states;
                          _state = null;
                          _availableAreas = [];
                          _area = null;
                        });
                      },
                    )
                  else if (_level == 'state' || _level == 'area')
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Bundesland',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _state,
                      items: _availableStates.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _state = v;
                          // Aktualisiere die Bereichsliste beim Bundeslandwechsel
                          final selectedState = _availableStates.firstWhere((s) => s.name == v, orElse: () => StateProfile(code: '', name: '', areas: []));
                          _availableAreas = selectedState.areas;
                          _area = null;
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  if (_level == 'area')
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Rettungsdienstbereich',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _area,
                      items: _availableAreas.map((a) => DropdownMenuItem(value: a.name, child: Text(a.name))).toList(),
                      onChanged: (v) => setState(() => _area = v),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSection('Filter'),
          Card(
            child: SwitchListTile(
              value: _filterOnly,
              onChanged: (v) => setState(() => _filterOnly = v),
              title: const Text('Nur Profilregeln anzeigen'),
              subtitle: const Text('Fallback: Bereich > Bundesland > Allgemein'),
              activeColor: PediColors.blue,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Speichern'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PediColors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showCompareDialog(context),
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Vergleich – Abweichungen anzeigen (Demo)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _save() async {
    // Speichere Profilstufe
    await _settings.setProfileLevel(_level);
    // Je nach Ebene: state, area und country speichern oder zurücksetzen
    if (_level == 'state' || _level == 'area') {
      await _settings.setProfileState(_state);
    } else {
      await _settings.setProfileState(null);
    }
    if (_level == 'area') {
      await _settings.setProfileArea(_area);
    } else {
      await _settings.setProfileArea(null);
    }
    if (_level == 'country') {
      await _settings.setProfileCountry(_country);
    } else {
      await _settings.setProfileCountry(null);
    }
    // Filteroption speichern
    await _settings.setProfileFilterOnly(_filterOnly);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil gespeichert')));
      Navigator.pop(context);
    }
  }

  void _showCompareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vergleich: Allgemein vs. Profil'),
          content: const Text('Platzhalter: Unterschiede zwischen Allgemein, Bundesland und Bereich werden hier als Liste dargestellt.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Schließen')),
          ],
        );
      },
    );
  }
}
