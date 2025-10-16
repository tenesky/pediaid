import 'package:flutter/material.dart';
import 'package:pediaid/models/medication.dart';
import 'package:pediaid/models/patient_data.dart';
import 'package:pediaid/services/medication_service.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/services/settings_service.dart';

class CalculatorScreen extends StatefulWidget {
  final PatientData patientData;

  const CalculatorScreen({super.key, required this.patientData});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _medicationService = MedicationService();
  final _settings = SettingsService();
  List<Medication> _medications = [];
  Medication? _selectedMedication;
  double _weightKg = 20.0;
  bool _isLoading = true;
  WeightUnit _weightUnit = WeightUnit.kg;

  double _kgToLbs(double kg) => kg * 2.2046226218;

  @override
  void initState() {
    super.initState();
    _weightKg = widget.patientData.weightKg ?? 20.0;
    _init();
  }

  Future<void> _init() async {
    final wu = await _settings.getWeightUnit();
    await _loadMedications();
    if (mounted) setState(() => _weightUnit = wu);
  }

  Future<void> _loadMedications() async {
    final meds = await _medicationService.getAllMedications();
    setState(() {
      _medications = meds;
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
      case 'orange': return PediColors.orange;
      case 'purple': return PediColors.purple;
      default: return PediColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medikamentenrechner')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gewichtseingabe',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Gewicht (${_weightUnit == WeightUnit.kg ? 'kg' : 'lbs'})', style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              (_weightUnit == WeightUnit.kg ? _weightKg : _kgToLbs(_weightKg)).toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PediColors.blue,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: PediColors.blue,
                            thumbColor: PediColors.blue,
                            overlayColor: PediColors.blue.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _weightKg,
                            min: 3,
                            max: 80,
                            onChanged: (val) => setState(() => _weightKg = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medikament wählen',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<Medication>(
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Bitte wählen...'),
                            value: _selectedMedication,
                            items: _medications.map((med) => DropdownMenuItem(
                              value: med,
                              child: Text('${med.name} (${med.indication})'),
                            )).toList(),
                            onChanged: (med) => setState(() => _selectedMedication = med),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedMedication != null) ...[
                  const SizedBox(height: 24),
                  _buildResultCard(),
                ],
              ],
            ),
          ),
    );
  }

  Widget _buildResultCard() {
    final med = _selectedMedication!;
    final color = _getColorForBand(med.colorBand);
    final calculatedDose = med.calculateDose(_weightKg);
    final isMaxDoseReached = med.maxDose != null && calculatedDose >= med.maxDose!;
    
    return Card(
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    med.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    med.route,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              med.indication,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'BERECHNETE DOSIS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculatedDose.toStringAsFixed(2)} ${med.unit}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (isMaxDoseReached) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: PediColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Maximaldosis erreicht',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: PediColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Dosierung', '${med.dosePerKg} ${med.unit}/kg'),
            const SizedBox(height: 12),
            _buildDetailRow('Gewicht', '${(_weightUnit == WeightUnit.kg ? _weightKg : _kgToLbs(_weightKg)).toStringAsFixed(1)} ${_weightUnit == WeightUnit.kg ? 'kg' : 'lbs'}'),
            const SizedBox(height: 12),
            _buildDetailRow('Konzentration', med.concentration),
            if (med.maxDose != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Max. Dosis', '${med.maxDose} ${med.unit}'),
            ],
            const SizedBox(height: 12),
            _buildDetailRow('Quelle', med.source),
            if (med.warning != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PediColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PediColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: PediColors.red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        med.warning!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PediColors.red,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
