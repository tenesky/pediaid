import 'package:flutter/material.dart';
import 'package:pediaid/models/guideline.dart';
import 'package:pediaid/services/guideline_service.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/services/statistics_service.dart';

/// Bildschirm, der Unterschiede zwischen allgemeinen und regionalen Leitlinien
/// aufzeigt. Nutzer können eine Leitlinie auswählen und sehen, ob es für das
/// aktuell eingestellte Profil (Bundesland, Bereich oder Land) spezielle
/// Abweichungen gibt.
class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final GuidelineService _guidelineService = GuidelineService();
  final SettingsService _settingsService = SettingsService();
  final StatisticsService _statsService = StatisticsService();

  List<Guideline> _guidelines = [];
  bool _loadingGuidelines = true;
  Guideline? _selected;
  String _regionLabel = '';

  @override
  void initState() {
    super.initState();
    _loadGuidelines();
    _loadProfile();
    // Statistik erhöhen
    _statsService.increment('comparison');
  }

  Future<void> _loadGuidelines() async {
    final list = await _guidelineService.getAllGuidelines();
    setState(() {
      _guidelines = list;
      _loadingGuidelines = false;
      if (list.isNotEmpty) {
        _selected = list.first;
      }
    });
  }

  Future<void> _loadProfile() async {
    final level = await _settingsService.getProfileLevel();
    String? label;
    if (level == 'country') {
      label = await _settingsService.getProfileCountry();
    } else if (level == 'state') {
      label = await _settingsService.getProfileState();
    } else if (level == 'area') {
      label = await _settingsService.getProfileArea();
    }
    setState(() {
      _regionLabel = label ?? '–';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leitlinienvergleich')),
      body: _loadingGuidelines
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<Guideline>(
                    value: _selected,
                    isExpanded: true,
                    onChanged: (val) {
                      setState(() => _selected = val);
                    },
                    items: _guidelines
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g.title),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  if (_selected != null) ...[
                    Text('Allgemeine Leitlinie',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildGuidelineCard(_selected!, false),
                    const SizedBox(height: 16),
                    Text('Regionale Abweichung (${_regionLabel.isNotEmpty ? _regionLabel : '–'})',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildRegionalCard(_selected!),
                  ],
                ],
              ),
            ),
    );
  }

  /// Baut eine Karte für die ausgewählte Leitlinie (allgemein).
  Widget _buildGuidelineCard(Guideline guideline, bool isRegional) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guideline.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isRegional ? Colors.red : Colors.black)),
            const SizedBox(height: 8),
            Text(guideline.summary,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(guideline.details,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text('Quelle: ${guideline.source}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  /// Sucht in den Leitlinien nach einer Variante mit Bezug zum aktuellen Profil.
  Widget _buildRegionalCard(Guideline selected) {
    if (_regionLabel.isEmpty || _regionLabel == '–') {
      return const Text('Keine Region ausgewählt.',
          style: TextStyle(color: Colors.grey));
    }
    // Prüfe alle Leitlinien auf Nennung der Region im Source-Feld.
    final matches = _guidelines.where((g) {
      final sourceLower = g.source.toLowerCase();
      final regionLower = _regionLabel.toLowerCase();
      return sourceLower.contains(regionLower) && g.id != selected.id;
    }).toList();
    if (matches.isEmpty) {
      return const Text('Keine abweichenden Leitlinien für die ausgewählte Region.',
          style: TextStyle(color: Colors.grey));
    }
    // Es können mehrere abweichende Leitlinien vorhanden sein – zeige alle.
    return Column(
      children: matches
          .map((g) => _buildGuidelineCard(g, true))
          .toList(),
    );
  }
}