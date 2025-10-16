import 'package:flutter/material.dart';
import 'package:pediaid/models/guideline.dart';
import 'package:pediaid/services/favorite_service.dart';
import 'package:pediaid/services/guideline_service.dart';
import 'package:pediaid/services/statistics_service.dart';

/// Bildschirm zum Durchsuchen der hinterlegten Leitlinien.
/// Nutzer können einen Suchbegriff eingeben und nach Titel, Zusammenfassung
/// oder Detailtext filtern. Der Bildschirm lädt alle Leitlinien aus dem
/// GuidelineService und filtert diese in Echtzeit.
class GuidelineSearchScreen extends StatefulWidget {
  const GuidelineSearchScreen({super.key});

  @override
  State<GuidelineSearchScreen> createState() => _GuidelineSearchScreenState();
}

class _GuidelineSearchScreenState extends State<GuidelineSearchScreen> {
  final GuidelineService _guidelineService = GuidelineService();
  final StatisticsService _statsService = StatisticsService();
  final FavoriteService _favoriteService = FavoriteService();

  final TextEditingController _controller = TextEditingController();
  List<Guideline> _all = [];
  List<Guideline> _filtered = [];
  bool _loading = true;

  // Favoriten
  bool _loadingFavorites = true;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    // Statistik erhöhen
    _statsService.increment('guidelines');
  }

  Future<void> _loadData() async {
    final list = await _guidelineService.getAllGuidelines();
    setState(() {
      _all = list;
      _filtered = list;
      _loading = false;
    });
    // Favoriten laden
    final favIds = await _favoriteService.getFavorites('guideline');
    setState(() {
      _favoriteIds = favIds.toSet();
      _loadingFavorites = false;
    });
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((g) {
          final t = g.title.toLowerCase();
          final s = g.summary.toLowerCase();
          final d = g.details.toLowerCase();
          return t.contains(query) || s.contains(query) || d.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _toggleFavorite(Guideline guideline) async {
    await _favoriteService.toggleFavorite('guideline', guideline.id);
    final favIds = await _favoriteService.getFavorites('guideline');
    setState(() {
      _favoriteIds = favIds.toSet();
    });
  }

  /// Wählt ein Icon basierend auf dem optionalen iconName der Leitlinie.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitlinien suchen'),
      ),
      body: (_loading || _loadingFavorites)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Suchbegriff eingeben',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => _onSearchChanged(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: Text('Keine passenden Leitlinien gefunden.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey)),
                          )
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final guideline = _filtered[index];
                              final isFav = _favoriteIds.contains(guideline.id);
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Icon mit farbigem Hintergrund
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getIconForGuideline(guideline.iconName),
                                            size: 28,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      guideline.title,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      isFav ? Icons.star : Icons.star_border,
                                                      color: isFav ? Colors.orange : Colors.grey,
                                                    ),
                                                    tooltip: isFav ? 'Als Favorit entfernen' : 'Als Favorit merken',
                                                    onPressed: () => _toggleFavorite(guideline),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                guideline.summary,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                guideline.details,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Quelle: ${guideline.source}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}