import 'package:flutter/material.dart';
import 'package:pediaid/models/indication.dart';
import 'package:pediaid/models/guideline.dart';
import 'package:pediaid/models/patient_data.dart';
import 'package:pediaid/models/checklist.dart';
import 'package:pediaid/models/medication.dart';
import 'package:pediaid/services/favorite_service.dart';
import 'package:pediaid/services/indication_service.dart';
import 'package:pediaid/services/checklist_service.dart';
import 'package:pediaid/services/guideline_service.dart';
import 'package:pediaid/services/medication_service.dart';
import 'package:pediaid/screens/indication_detail_screen.dart';
import 'package:pediaid/theme.dart';

/// Bildschirm zur Anzeige aller als Favorit markierten Einträge.
/// Unterstützt Indikationen und Checklisten. Weitere Kategorien können
/// später ergänzt werden.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final IndicationService _indicationService = IndicationService();
  final ChecklistService _checklistService = ChecklistService();
  final GuidelineService _guidelineService = GuidelineService();
  final MedicationService _medicationService = MedicationService();

  List<Indication> _favIndications = [];
  List<Checklist> _favChecklists = [];
  List<Guideline> _favGuidelines = [];
  List<Medication> _favMedications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // Lade IDs der Favoriten
    final favIndIds = await _favoriteService.getFavorites('indication');
    final favChkIds = await _favoriteService.getFavorites('checklist');
    final favGuidIds = await _favoriteService.getFavorites('guideline');
    final favMedIds = await _favoriteService.getFavorites('medication');
    // Lade alle Indikationen/Checklisten
    final allInd = await _indicationService.getAllIndications();
    final allChk = await _checklistService.getAllChecklists();
    final allGuidelines = await _guidelineService.getAllGuidelines();
    final allMeds = await _medicationService.getAllMedications();
    setState(() {
      _favIndications = allInd.where((ind) => favIndIds.contains(ind.id)).toList();
      _favChecklists = allChk.where((chk) => favChkIds.contains(chk.id)).toList();
      _favGuidelines = allGuidelines.where((g) => favGuidIds.contains(g.id)).toList();
      _favMedications = allMeds.where((m) => favMedIds.contains(m.id)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoriten')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_favIndications.isEmpty && _favChecklists.isEmpty && _favGuidelines.isEmpty && _favMedications.isEmpty)
              ? Center(
                  child: Text(
                    'Keine Favoriten vorhanden.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_favIndications.isNotEmpty) ...[
                      Text('Indikationen', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._favIndications.map((indication) {
                        final color = _getColorForBand(indication.colorBand);
                        final icon = _getIconForName(indication.iconName);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => IndicationDetailScreen(indication: indication, patientData: IndicationPatientDataPlaceholder),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Card(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border(
                                    left: BorderSide(color: color, width: 6),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(icon, size: 28, color: color),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(indication.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(indication.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                    if (_favChecklists.isNotEmpty) ...[
                      Text('Checklisten', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._favChecklists.map((chk) {
                        final bool isExpanded = false;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ExpansionTile(
                              title: Text(chk.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text(chk.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...List.generate(chk.steps.length, (i) {
                                        final step = chk.steps[i];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${i + 1}. ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: PediColors.blue)),
                                              Expanded(child: Text(step, style: Theme.of(context).textTheme.bodyMedium)),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 8),
                                      Text('Quelle: ${chk.source}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    if (_favGuidelines.isNotEmpty) ...[
                      Text('Leitlinien', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                    ..._favGuidelines.map((Guideline g) {
                        final icon = _getIconForGuideline(g.iconName);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(g.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(g.summary, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 6),
                                        Text(g.details, style: Theme.of(context).textTheme.bodySmall),
                                        const SizedBox(height: 6),
                                        Text('Quelle: ${g.source}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                    if (_favMedications.isNotEmpty) ...[
                      Text('Medikamente', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._favMedications.map((m) {
                        final Color color = _getColorForBand(m.colorBand);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(m.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(m.route, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Dosierung: ${m.dosePerKg} ${m.unit}/kg', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                  if (m.maxDose != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Max: ${m.maxDose} ${m.unit}', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                  const SizedBox(height: 4),
                                  Text('Konzentration: ${m.concentration}', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 4),
                                  Text('Quelle: ${m.source}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
    );
  }

  // Hilfsfunktionen, um Farbe und Icon aus dem Indikationsmodell zu ermitteln.
  Color _getColorForBand(String colorBand) {
    switch (colorBand) {
      case 'pink':
        return PediColors.pink;
      case 'red':
        return PediColors.red;
      case 'yellow':
        return PediColors.yellow;
      case 'blue':
        return PediColors.blue;
      case 'green':
        return PediColors.green;
      case 'orange':
        return PediColors.orange;
      case 'purple':
        return PediColors.purple;
      default:
        return PediColors.blue;
    }
  }

  IconData _getIconForName(String iconName) {
    switch (iconName) {
      case 'warning':
        return Icons.warning;
      case 'favorite':
        return Icons.favorite;
      case 'flash_on':
        return Icons.flash_on;
      case 'air':
        return Icons.air;
      case 'monitor_heart':
        return Icons.monitor_heart;
      default:
        return Icons.medical_services;
    }
  }

  /// Bestimmt ein Icon für Leitlinien anhand des optionalen iconName.
  IconData _getIconForGuideline(String? iconName) {
    switch (iconName) {
      case 'flash_on':
        return Icons.flash_on;
      case 'medication':
        return Icons.medication;
      case 'warning':
        return Icons.warning;
      case 'science':
        return Icons.science;
      case 'pill':
        return Icons.local_pharmacy;
      case 'bolt':
        return Icons.bolt;
      case 'opacity':
        return Icons.opacity;
      case 'schedule':
        return Icons.schedule;
      case 'info':
        return Icons.info;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.description;
    }
  }

  /// Platzhalter für PatientData in der Favoritenansicht.
  /// Da die Favoritenliste nicht die aktuellen Patientendaten enthält, aber
  /// IndicationDetailScreen diese benötigt, übergeben wir ein Dummy-Objekt.
  PatientData get IndicationPatientDataPlaceholder => PatientData(ageYears: 0, weightKg: 0, heightCm: 0);

}