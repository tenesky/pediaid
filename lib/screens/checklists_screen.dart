import 'package:flutter/material.dart';
import 'package:pediaid/models/checklist.dart';
import 'package:pediaid/services/checklist_service.dart';
import 'package:pediaid/theme.dart';
import 'package:pediaid/services/favorite_service.dart';

/// Bildschirm zur Anzeige interaktiver Checklisten und Algorithmen.
/// Die Daten stammen aus einer lokalen JSON‑Datei und werden via
/// [ChecklistService] geladen. Jede Checkliste lässt sich ausklappen,
/// um die einzelnen Schritte einzusehen.
class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  final _service = ChecklistService();
  List<Checklist> _checklists = [];
  bool _loading = true;

  final _favoriteService = FavoriteService();
  Set<String> _favoriteIds = {};
  bool _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadFavorites();
  }

  Future<void> _load() async {
    final list = await _service.getAllChecklists();
    setState(() {
      _checklists = list;
      _loading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final favs = await _favoriteService.getFavorites('checklist');
    setState(() {
      _favoriteIds = favs.toSet();
      _loadingFavorites = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklisten')),
      body: _loading || _loadingFavorites
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _checklists.length,
              itemBuilder: (context, index) {
                final chk = _checklists[index];
                final bool isFav = _favoriteIds.contains(chk.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ExpansionTile(
                      title: Text(chk.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(chk.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.star : Icons.star_border,
                              color: isFav ? PediColors.orange : Colors.grey[400],
                            ),
                            tooltip: isFav ? 'Als Favorit entfernen' : 'Als Favorit merken',
                            onPressed: () async {
                              await _favoriteService.toggleFavorite('checklist', chk.id);
                              setState(() {
                                if (isFav) {
                                  _favoriteIds.remove(chk.id);
                                } else {
                                  _favoriteIds.add(chk.id);
                                }
                              });
                            },
                          ),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(chk.steps.length, (i) {
                                final step = chk.steps[i];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${i + 1}. ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: PediColors.blue)),
                                      Expanded(
                                        child: Text(step,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Quelle: ${chk.source}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.grey[600])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}