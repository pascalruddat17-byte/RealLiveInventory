import 'package:flutter/material.dart';

import '../../core/inventory_controller.dart';
import '../../widgets/item_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.controller,
    required this.onOpenRoom,
  });

  final InventoryController controller;
  final VoidCallback onOpenRoom;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.controller.searchQuery);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.controller.searchResults;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Suche',
            hintText: 'Ding zum Schrauben, USB C Kabel, Arduino Sachen ...',
            border: OutlineInputBorder(),
          ),
          onChanged: widget.controller.search,
        ),
        const SizedBox(height: 16),
        if (widget.controller.searchQuery.trim().isEmpty)
          const _InfoCard(
            icon: Icons.tips_and_updates_outlined,
            text: 'Suche nach Namen, Fähigkeiten, Tags, Kategorien oder Marke.',
          )
        else if (results.isEmpty)
          const _InfoCard(
            icon: Icons.search_off_outlined,
            text: 'Keine passenden Gegenstände gefunden.',
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${results.length} Treffer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: widget.onOpenRoom,
                icon: const Icon(Icons.view_in_ar_outlined),
                label: const Text('Im Raum zeigen'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...results.map(
            (result) => ItemTile(
              item: result.item,
              location: widget.controller.locationFor(result.item),
              onTap: () {
                widget.controller.selectItem(result.item.id);
                widget.onOpenRoom();
              },
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.score.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Text('Score'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
