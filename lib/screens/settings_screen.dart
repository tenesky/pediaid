import 'package:flutter/material.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();

  WeightUnit _weightUnit = WeightUnit.kg;
  LengthUnit _lengthUnit = LengthUnit.cm;
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = true;
  bool _largeText = false;
  bool _highContrast = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final weightUnit = await _settings.getWeightUnit();
    final lengthUnit = await _settings.getLengthUnit();
    final defaultAge = await _settings.getDefaultAgeYears();
    final defaultWeightKg = await _settings.getDefaultWeightKg();
    final largeText = await _settings.getLargeTextEnabled();
    final highContrast = await _settings.getHighContrastEnabled();

    setState(() {
      _weightUnit = weightUnit;
      _lengthUnit = lengthUnit;
      _ageController.text = defaultAge.toStringAsFixed(1);
      final displayWeight = weightUnit == WeightUnit.lbs
          ? _kgToLbs(defaultWeightKg)
          : defaultWeightKg;
      _weightController.text = displayWeight.toStringAsFixed(1);
      _isLoading = false;
      _largeText = largeText;
      _highContrast = highContrast;
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double _kgToLbs(double kg) => kg * 2.2046226218;
  double _lbsToKg(double lbs) => lbs / 2.2046226218;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
            : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('Barrierefreiheit'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Großschrift'),
                        value: _largeText,
                        onChanged: (v) => setState(() => _largeText = v),
                        activeColor: PediColors.blue,
                      ),
                      SwitchListTile(
                        title: const Text('Hochkontrast'),
                        value: _highContrast,
                        onChanged: (v) => setState(() => _highContrast = v),
                        activeColor: PediColors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection('Einheiten'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gewicht', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<WeightUnit>(
                          segments: const [
                            ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                            ButtonSegment(value: WeightUnit.lbs, label: Text('lbs')),
                          ],
                          selected: {_weightUnit},
                          onSelectionChanged: (s) {
                            setState(() {
                              final previous = _weightUnit;
                              _weightUnit = s.first;
                              // Convert current weight input between units to preserve value meaning
                              final current = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0;
                              final converted = previous == WeightUnit.kg && _weightUnit == WeightUnit.lbs
                                  ? _kgToLbs(current)
                                  : previous == WeightUnit.lbs && _weightUnit == WeightUnit.kg
                                      ? _lbsToKg(current)
                                      : current;
                              _weightController.text = converted.toStringAsFixed(1);
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Länge', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<LengthUnit>(
                          segments: const [
                            ButtonSegment(value: LengthUnit.cm, label: Text('cm')),
                            ButtonSegment(value: LengthUnit.inch, label: Text('inch')),
                          ],
                          selected: {_lengthUnit},
                          onSelectionChanged: (s) => setState(() => _lengthUnit = s.first),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection('Standardwerte'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildNumberField(
                          context,
                          label: 'Standardalter (Jahre)',
                          controller: _ageController,
                          icon: Icons.cake,
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          context,
                          label: 'Standardgewicht (${_weightUnit == WeightUnit.kg ? 'kg' : 'lbs'})',
                          controller: _weightController,
                          icon: Icons.monitor_weight,
                        ),
                        const SizedBox(height: 20),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNumberField(BuildContext context, {required String label, required TextEditingController controller, required IconData icon}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: PediColors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _save() async {
    final age = double.tryParse(_ageController.text.replaceAll(',', '.'));
    final weightDisplay = double.tryParse(_weightController.text.replaceAll(',', '.'));

    if (age == null || age < 0 || weightDisplay == null || weightDisplay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gültige Werte eingeben.')),
      );
      return;
    }

    final weightKg = _weightUnit == WeightUnit.lbs ? _lbsToKg(weightDisplay) : weightDisplay;

    await _settings.setWeightUnit(_weightUnit);
    await _settings.setLengthUnit(_lengthUnit);
    await _settings.setDefaultAgeYears(age);
    await _settings.setDefaultWeightKg(weightKg);
    await _settings.setLargeTextEnabled(_largeText);
    await _settings.setHighContrastEnabled(_highContrast);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );
      Navigator.pop(context);
    }
  }
}
