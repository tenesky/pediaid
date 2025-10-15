import 'package:flutter/material.dart';
import 'package:pediaid/models/indication.dart';
import 'package:pediaid/models/patient_data.dart';
import 'package:pediaid/services/indication_service.dart';
import 'package:pediaid/services/medication_service.dart';
import 'package:pediaid/screens/indication_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _indicationService = IndicationService();
  final _medicationService = MedicationService();
  final _controller = TextEditingController();

  List<String> _suggestions = [];
  List<dynamic> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prefetch();
  }

  Future<void> _prefetch() async {
    final inds = await _indicationService.getAllIndications();
    final meds = await _medicationService.getAllMedications();
    setState(() {
      _suggestions = [
        ...inds.map((e) => e.name),
        ...meds.map((e) => e.name),
      ];
      _loading = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final inds = await _indicationService.getAllIndications();
    final meds = await _medicationService.searchMedications(query);
    final indMatches = inds
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _results = [...indMatches, ...meds];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suche')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  RawAutocomplete<String>(
                    textEditingController: _controller,
                    optionsBuilder: (text) {
                      final q = text.text.toLowerCase();
                      if (q.isEmpty) return const Iterable<String>.empty();
                      return _suggestions.where((s) => s.toLowerCase().contains(q)).take(6);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onSubmitted: (v) => _search(v),
                        decoration: InputDecoration(
                          hintText: 'Indikation oder Medikament suchen...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    onSelected: (selection) => _search(selection),
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200, minWidth: 300),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final opt = options.elementAt(index);
                                return ListTile(
                                  title: Text(opt),
                                  onTap: () => onSelected(opt),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        if (item is Indication) {
                          return ListTile(
                            leading: const Icon(Icons.medical_services),
                            title: Text(item.name),
                            subtitle: Text(item.description),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IndicationDetailScreen(
                                  indication: item,
                                  patientData: PatientData(ageYears: 5, weightKg: 20, heightCm: 110),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // medication
                          return ListTile(
                            leading: const Icon(Icons.vaccines),
                            title: Text(item.name),
                            subtitle: Text(item.indication),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
