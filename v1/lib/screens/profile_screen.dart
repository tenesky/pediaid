import 'package:flutter/material.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _settings = SettingsService();

  String _level = 'general';
  String? _state;
  String? _area;
  bool _filterOnly = false;

  final _states = const [
    'Baden-Württemberg','Bayern','Berlin','Brandenburg','Bremen','Hamburg','Hessen','Mecklenburg-Vorpommern','Niedersachsen','Nordrhein-Westfalen','Rheinland-Pfalz','Saarland','Sachsen','Sachsen-Anhalt','Schleswig-Holstein','Thüringen'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final level = await _settings.getProfileLevel();
    final state = await _settings.getProfileState();
    final area = await _settings.getProfileArea();
    final filter = await _settings.getProfileFilterOnly();
    setState(() {
      _level = level;
      _state = state;
      _area = area;
      _filterOnly = filter;
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
                      ButtonSegment(value: 'state', label: Text('Bundesland')),
                      ButtonSegment(value: 'area', label: Text('Bereich')),
                    ],
                    selected: {_level},
                    onSelectionChanged: (v) => setState(() => _level = v.first),
                  ),
                  const SizedBox(height: 16),
                  if (_level != 'general')
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Bundesland',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _state,
                      items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _state = v),
                    ),
                  const SizedBox(height: 12),
                  if (_level == 'area')
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Rettungsdienstbereich (optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.place, color: Colors.blue),
                      ),
                      onChanged: (v) => _area = v.isEmpty ? null : v,
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
    await _settings.setProfileLevel(_level);
    await _settings.setProfileState(_level == 'general' ? null : _state);
    await _settings.setProfileArea(_level == 'area' ? _area : null);
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
