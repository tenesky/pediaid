import 'package:flutter/material.dart';
import 'package:pediaid/models/indication.dart';
import 'package:pediaid/models/medication.dart';
import 'package:pediaid/models/patient_data.dart';
import 'package:pediaid/services/medication_service.dart';
import 'package:pediaid/services/favorite_service.dart';
import 'package:pediaid/theme.dart';

class IndicationDetailScreen extends StatefulWidget {
  final Indication indication;
  final PatientData patientData;

  const IndicationDetailScreen({
    super.key,
    required this.indication,
    required this.patientData,
  });

  @override
  State<IndicationDetailScreen> createState() => _IndicationDetailScreenState();
}

class _IndicationDetailScreenState extends State<IndicationDetailScreen> {
  final _medicationService = MedicationService();
  final FavoriteService _favoriteService = FavoriteService();
  List<Medication> _medications = [];
  bool _isLoading = true;
  Set<String> _favoriteMedIds = {};

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final meds = await _medicationService.getMedicationsByIndication(widget.indication.name);
    final favIds = await _favoriteService.getFavorites('medication');
    setState(() {
      _medications = meds;
      _favoriteMedIds = favIds.toSet();
      _isLoading = false;
    });
  }

  Future<void> _toggleFavoriteMedication(Medication med) async {
    await _favoriteService.toggleFavorite('medication', med.id);
    final favIds = await _favoriteService.getFavorites('medication');
    setState(() {
      _favoriteMedIds = favIds.toSet();
    });
  }

  Color _getColorForBand(String colorBand) {
    switch (colorBand) {
      case 'pink': return PediColors.pink;
      case 'red': return PediColors.red;
      case 'yellow': return PediColors.yellow;
      case 'blue': return PediColors.blue;
      case 'green': return PediColors.green;
      case 'orange': return PediColors.orange;
      case 'purple': return PediColors.purple;
      default: return PediColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForBand(widget.indication.colorBand);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.indication.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Vergleich',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Vergleich – Profilabweichungen'),
                  content: const Text('Platzhalter: Unterschiede zwischen Allgemein, Bundesland und Bereich werden hier angezeigt.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Schließen'))],
                ),
              );
            },
          )
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.indication.description,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (widget.patientData.weightKg != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Patientengewicht: ${widget.patientData.weightKg!.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Medikamente',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_medications.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Keine Medikamente verfügbar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._medications.map((med) => _buildMedicationCard(med, color)),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Orientierungswerte – klinische Entscheidung erforderlich.\nQuelle: ERC 2025, DIVI 2024, DGKJ/AWMF – Stand 10/2025',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildMedicationCard(Medication medication, Color accentColor) {
    final weight = widget.patientData.weightKg ?? 20.0;
    final calculatedDose = medication.calculateDose(weight);
    final mgPerMl = medication.mgPerMl();
    final volumeMl = mgPerMl != null ? calculatedDose / mgPerMl : null;
    final isFav = _favoriteMedIds.contains(medication.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(top: BorderSide(color: accentColor, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    medication.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                // Favoriten-Icon
                IconButton(
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.orange : Colors.grey,
                  ),
                  tooltip: isFav ? 'Als Favorit entfernen' : 'Als Favorit merken',
                  onPressed: () => _toggleFavoriteMedication(medication),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    medication.route,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Dosierung', '${medication.dosePerKg} ${medication.unit}/kg'),
            const SizedBox(height: 8),
            _buildInfoRow('Berechnete Dosis', '${calculatedDose.toStringAsFixed(2)} ${medication.unit}', highlight: true, color: accentColor),
            if (volumeMl != null) ...[
              const SizedBox(height: 4),
              _buildInfoRow('≈ Volumen', '${volumeMl.toStringAsFixed(2)} ml', highlight: true, color: accentColor),
            ],
            if (medication.maxDose != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Max. Dosis', '${medication.maxDose} ${medication.unit}'),
            ],
            const SizedBox(height: 8),
            _buildInfoRow('Konzentration', medication.concentration),
            const SizedBox(height: 8),
            _buildInfoRow('Quelle', medication.source),
            if (medication.warning != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PediColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PediColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: PediColors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        medication.warning!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PediColors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            color: highlight ? color : null,
          ),
        ),
      ],
    );
  }
}
