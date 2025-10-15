import 'package:flutter/material.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/utils/formulas.dart';

class FormulasScreen extends StatefulWidget {
  const FormulasScreen({super.key});

  @override
  State<FormulasScreen> createState() => _FormulasScreenState();
}

class _FormulasScreenState extends State<FormulasScreen> {
  bool _useMonths = false;
  int _ageMonths = 12;
  double _ageYears = 1.0;
  double _weightKg = 10.0;
  double _heightCm = 75.0;
  double _hr = 120.0;
  double _sbp = 90.0;
  bool _neonate = false;

  @override
  Widget build(BuildContext context) {
    final estWeight = _useMonths
        ? PediFormulas.estWeightKgByMonths(_ageMonths)
        : PediFormulas.estWeightKgByYears(_ageYears);
    final estHeight = _useMonths
        ? PediFormulas.estHeightCmByMonths(_ageMonths)
        : PediFormulas.estHeightCmByYears(_ageYears);
    final bsa = PediFormulas.bsaMosteller(_heightCm, _weightKg);
    final fluidsDaily = PediFormulas.fluidsDailyHollidaySegar(_weightKg);
    final fluidsHourly = PediFormulas.fluidsHourly421(_weightKg);
    final defib = PediFormulas.defibrillationEnergyJ(_weightKg);
    final bloodVol = PediFormulas.bloodVolumeMl(_weightKg);
    final si = PediFormulas.shockIndex(heartRate: _hr, systolicBP: _sbp);
    final o2 = PediFormulas.oxygenConsumptionMlPerMin(weightKg: _weightKg, neonate: _neonate);

    return Scaffold(
      appBar: AppBar(title: const Text('Faustformeln')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Eingaben'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Alter in Jahren')),
                        ButtonSegment(value: true, label: Text('Alter in Monaten')),
                      ],
                      selected: {_useMonths},
                      onSelectionChanged: (v) => setState(() => _useMonths = v.first),
                    ),
                    const SizedBox(height: 12),
                    if (_useMonths)
                      _buildSlider('Alter (Monate)', _ageMonths.toDouble(), 0, 24, (v) => setState(() => _ageMonths = v.round()), PediColors.pink)
                    else
                      _buildSlider('Alter (Jahre)', _ageYears, 0, 18, (v) => setState(() => _ageYears = v), PediColors.pink),
                    const SizedBox(height: 12),
                    _buildSlider('Gewicht (kg)', _weightKg, 2, 80, (v) => setState(() => _weightKg = v), PediColors.blue),
                    const SizedBox(height: 12),
                    _buildSlider('Größe (cm)', _heightCm, 45, 180, (v) => setState(() => _heightCm = v), PediColors.green),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildSlider('Puls (bpm)', _hr, 40, 200, (v) => setState(() => _hr = v), PediColors.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSlider('syst. RR (mmHg)', _sbp, 50, 140, (v) => setState(() => _sbp = v), PediColors.yellow)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Switch(
                          value: _neonate,
                          onChanged: (v) => setState(() => _neonate = v),
                          activeColor: PediColors.purple,
                        ),
                        const SizedBox(width: 8),
                        const Text('Neugeborenes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSection('Berechnungen'),
            _resultCard(context,
              title: 'Gewichtsschätzung',
              value: '${estWeight.toStringAsFixed(1)} kg',
              subtitle: _useMonths ? '(Monate/2) + 4' : '(Alter × 2) + 8 (1–10 J.)',
            ),
            _resultCard(context,
              title: 'Größenschätzung',
              value: '${estHeight.toStringAsFixed(0)} cm',
              subtitle: _useMonths ? '50 cm + (Monate × 2)' : '(Alter × 6) + 77 cm (1–12 J.)',
            ),
            _resultCard(context,
              title: 'KOF (Mosteller)',
              value: '${bsa.toStringAsFixed(2)} m²',
              subtitle: '√((cm × kg) / 3600)',
            ),
            _resultCard(context,
              title: 'Flüssigkeitsbedarf (Tag)',
              value: '${fluidsDaily.toStringAsFixed(0)} ml/Tag',
              subtitle: 'Holliday-Segar 100/50/20',
            ),
            _resultCard(context,
              title: 'Erhaltung (4-2-1)',
              value: '${fluidsHourly.toStringAsFixed(0)} ml/h',
              subtitle: '4-2-1 Regel',
            ),
            _resultCard(context,
              title: 'Defibrillation',
              value: '${defib.toStringAsFixed(0)} J',
              subtitle: '4 J/kg (biphasisch)',
            ),
            _resultCard(context,
              title: 'Blutvolumen',
              value: '${bloodVol.toStringAsFixed(0)} ml',
              subtitle: '≈ 80 ml/kg',
            ),
            _resultCard(context,
              title: 'Schockindex',
              value: si.isFinite ? si.toStringAsFixed(2) : '-',
              subtitle: 'Puls / syst. RR  (Kinder >1 = Warnhinweis)',
              extra: si > 1.0 ? _warningChip('Warnhinweis', PediColors.red) : _okChip('Unauffällig', PediColors.green),
            ),
            _resultCard(context,
              title: 'O₂-Bedarf',
              value: '${o2.toStringAsFixed(0)} ml/min',
              subtitle: _neonate ? 'Neugeborene ~8 ml/kg/min' : 'Kinder ~6 ml/kg/min',
            ),
            const SizedBox(height: 24),
            _sourceFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(value.toStringAsFixed(0), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _resultCard(BuildContext context, {required String title, required String value, String? subtitle, Widget? extra}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (extra != null) extra,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ],
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: PediColors.blue,
              ),
            ),
            const SizedBox(height: 8),
            _sourceLine(context),
          ],
        ),
      ),
    );
  }

  Widget _sourceLine(BuildContext context) {
    return Text(
      'Quelle: ERC 2025, DIVI 2024, DGKJ/AWMF – Stand 10/2025',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
    );
  }

  Widget _sourceFooter(BuildContext context) {
    return Center(
      child: Text(
        'Orientierungswerte – klinische Entscheidung erforderlich.\nQuelle: ERC 2025, DIVI 2024, DGKJ/AWMF – Stand 10/2025',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Widget _warningChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _okChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
