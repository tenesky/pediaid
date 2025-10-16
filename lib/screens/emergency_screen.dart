import 'package:flutter/material.dart';
import 'package:pediaid/models/patient_data.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/models/indication.dart';
import 'package:pediaid/services/indication_service.dart';
import 'package:pediaid/screens/indication_detail_screen.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show FontFeature;

class EmergencyScreen extends StatefulWidget {
  final PatientData patientData;

  const EmergencyScreen({super.key, required this.patientData});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _indicationService = IndicationService();
  List<Indication> _emergencyIndications = [];
  bool _isLoading = true;
  double _weight = 20.0;

  @override
  void initState() {
    super.initState();
    _loadEmergencyIndications();
  }

  Future<void> _loadEmergencyIndications() async {
    final indications = await _indicationService.getAllIndications();
    setState(() {
      _emergencyIndications = indications.where((ind) => 
        ind.name == 'Anaphylaxie' || 
        ind.name == 'Reanimation' || 
        ind.name == 'Krampfanfall'
      ).toList();
      _weight = widget.patientData.weightKg ?? 20.0;
      _isLoading = false;
    });
  }

  Color _getColorForBand(String colorBand) {
    switch (colorBand) {
      case 'pink': return PediColors.pink;
      case 'red': return PediColors.red;
      case 'yellow': return PediColors.yellow;
      case 'blue': return PediColors.blue;
      case 'green': return PediColors.green;
      default: return PediColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('NOTFALLMODUS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _weightCard(context),
                const SizedBox(height: 24),
                Expanded(child: _gridPrimary(context)),
                const SizedBox(height: 12),
                Text(
                  'Orientierungswerte – klinische Entscheidung erforderlich.\nQuelle: ERC 2025, DIVI 2024, DGKJ/AWMF – Stand 10/2025',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Zurück zur Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _weightCard(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'GEWICHT',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.5,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_weight.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 12),
              _weightChips(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weightChips() {
    final bands = <double, Color>{
      5: PediColors.pink,
      10: PediColors.red,
      15: PediColors.purple,
      20: PediColors.yellow,
      30: PediColors.blue,
      40: PediColors.orange,
      50: PediColors.green,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: bands.entries.map((e) {
          final selected = (_weight - e.key).abs() < 0.1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              selected: selected,
              label: Text('${e.key.toStringAsFixed(0)} kg'),
              selectedColor: e.value,
              labelStyle: TextStyle(color: selected ? Colors.white : e.value),
              backgroundColor: e.value.withValues(alpha: 0.15),
              onSelected: (_) {
                HapticFeedback.lightImpact();
                setState(() => _weight = e.key);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _gridPrimary(BuildContext context) {
    final tiles = _emergencyIndications.take(4).toList();
    return GridView.builder(
      // Im Notfallmodus sollen die Karten groß und leicht bedienbar sein. Durch
      // Verwendung einer Spalte werden die Kacheln über die gesamte Breite
      // dargestellt. childAspectRatio > 1 sorgt für zusätzliche Höhe.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final ind = tiles[index];
        final color = _getColorForBand(ind.colorBand);
        return _emergencyTile(context, ind, color);
      },
    );
  }

  Widget _emergencyTile(BuildContext context, Indication ind, Color color) {
    final keyDose = _buildKeyDose(ind);
    final keySecond = _buildKeySecond(ind);
    return InkWell(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ind.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 8),
            if (keyDose != null) keyDose,
            const SizedBox(height: 6),
            if (keySecond != null) keySecond,
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IndicationDetailScreen(indication: ind, patientData: PatientData(ageYears: widget.patientData.ageYears, weightKg: _weight, heightCm: widget.patientData.heightCm)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                child: const Text('Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildKeyDose(Indication ind) {
    // Show a compact primary dose card line
    if (ind.name == 'Anaphylaxie') {
      final doseMg = 0.01 * _weight; // mg/kg IM
      final ml = doseMg / 1.0; // 1 mg/ml
      return _doseRow('Adrenalin IM', '${doseMg.toStringAsFixed(2)} mg  •  ${ml.toStringAsFixed(2)} ml');
    }
    if (ind.name == 'Reanimation') {
      final j = 4.0 * _weight;
      return _doseRow('Defibrillation', '${j.toStringAsFixed(0)} J');
    }
    if (ind.name == 'Krampfanfall') {
      final doseMg = 0.2 * _weight; // Midazolam bukkal/nasal
      final ml = doseMg / 5.0; // 5 mg/ml
      return _doseRow('Midazolam', '${doseMg.toStringAsFixed(1)} mg  •  ${ml.toStringAsFixed(2)} ml');
    }
    return null;
  }

  Widget? _buildKeySecond(Indication ind) {
    if (ind.name == 'Reanimation') {
      final doseMg = 0.01 * _weight; // Adrenalin IV 0.01 mg/kg
      return _doseRow('Adrenalin IV', '${doseMg.toStringAsFixed(2)} mg');
    }
    if (ind.name == 'Asthma') {
      final doseMg = 0.15 * _weight; // Salbutamol
      return _doseRow('Salbutamol inh.', '${doseMg.toStringAsFixed(1)} mg');
    }
    return null;
  }

  Widget _doseRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
