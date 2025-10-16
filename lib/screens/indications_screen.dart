import 'package:flutter/material.dart';
import 'package:pediaid/models/indication.dart';
import 'package:pediaid/models/patient_data.dart';
import 'package:pediaid/services/indication_service.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/screens/indication_detail_screen.dart';
import 'package:pediaid/services/settings_service.dart';
import 'package:pediaid/services/favorite_service.dart';

class IndicationsScreen extends StatefulWidget {
  final PatientData patientData;

  const IndicationsScreen({super.key, required this.patientData});

  @override
  State<IndicationsScreen> createState() => _IndicationsScreenState();
}

class _IndicationsScreenState extends State<IndicationsScreen> {
  final _indicationService = IndicationService();
  final _settings = SettingsService();
  List<Indication> _indications = [];
  bool _isLoading = true;
  String _profileBadge = '';
  bool _filterOnly = false;

  // Favoritenverwaltung
  final _favoriteService = FavoriteService();
  Set<String> _favoriteIds = {};
  bool _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadIndications();
    _loadFavorites();
  }

  Future<void> _loadIndications() async {
    final indications = await _indicationService.getAllIndications();
    final level = await _settings.getProfileLevel();
    final state = await _settings.getProfileState();
    final area = await _settings.getProfileArea();
    final filter = await _settings.getProfileFilterOnly();
    final country = await _settings.getProfileCountry();
    final regionOrCountry = level == 'country' ? country : state;
    setState(() {
      _indications = indications;
      _isLoading = false;
      _profileBadge = _composeProfile(level, regionOrCountry, area);
      _filterOnly = filter;
    });
  }

  Future<void> _loadFavorites() async {
    final favs = await _favoriteService.getFavorites('indication');
    setState(() {
      _favoriteIds = favs.toSet();
      _loadingFavorites = false;
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

  IconData _getIconForName(String iconName) {
    switch (iconName) {
      case 'warning': return Icons.warning;
      case 'favorite': return Icons.favorite;
      case 'flash_on': return Icons.flash_on;
      case 'air': return Icons.air;
      case 'monitor_heart': return Icons.monitor_heart;
      default: return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indikationen')),
      body: _isLoading || _loadingFavorites
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_profileBadge, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.blue)),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Nur Profilregeln'),
                    selected: _filterOnly,
                    onSelected: (v) async {
                      await _settings.setProfileFilterOnly(v);
                      setState(() => _filterOnly = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._indications.map((indication) {
                final color = _getColorForBand(indication.colorBand);
                final icon = _getIconForName(indication.iconName);
                final bool isFav = _favoriteIds.contains(indication.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IndicationDetailScreen(
                            indication: indication,
                            patientData: widget.patientData,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(color: color, width: 6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, size: 32, color: color),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          indication.name,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text('$_profileBadge', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.blue)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    indication.description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            // Favoritenstern und Pfeil
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isFav ? Icons.star : Icons.star_border,
                                    color: isFav ? PediColors.orange : Colors.grey[400],
                                  ),
                                  tooltip: isFav ? 'Als Favorit entfernen' : 'Als Favorit merken',
                                  onPressed: () async {
                                    await _favoriteService.toggleFavorite('indication', indication.id);
                                    setState(() {
                                      if (isFav) {
                                        _favoriteIds.remove(indication.id);
                                      } else {
                                        _favoriteIds.add(indication.id);
                                      }
                                    });
                                  },
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
    );
  }

  String _composeProfile(String level, String? region, String? area) {
    // region repräsentiert entweder Land (bei Level 'country') oder Bundesland (bei Level 'state'/'area')
    if (level == 'area' && (region != null || area != null)) {
      return 'Profil: ${region ?? '-'} – ${area ?? '-'}';
    }
    if (level == 'state' && region != null) {
      return 'Profil: $region';
    }
    if (level == 'country' && region != null) {
      return 'Profil: $region';
    }
    return 'Profil: Allgemein';
  }
}
