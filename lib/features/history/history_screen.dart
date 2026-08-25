import 'package:flutter/material.dart';

import '../../core/inventory_controller.dart';
import '../../core/inventory_enums.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.controller});

  final InventoryController controller;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  OwnershipStatus? filter;

  @override
  Widget build(BuildContext context) {
    final archived = widget.controller.archivedItems.where((item) {
      return filter == null || item.ownershipStatus == filter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Nicht mehr im Besitz',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Alle'),
              selected: filter == null,
              onSelected: (_) => setState(() => filter = null),
            ),
            ...OwnershipStatus.values
                .where((value) => value != OwnershipStatus.owned)
                .map(
                  (value) => ChoiceChip(
                    label: Text(value.label),
                    selected: filter == value,
                    onSelected: (_) => setState(() => filter = value),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Text('Verkauft: ${widget.controller.soldCount}')),
                Expanded(
                  child: Text(
                    'Einnahmen: ${widget.controller.totalSales.toStringAsFixed(2)} €',
                  ),
                ),
                Expanded(
                  child: Text('Verschenkt: ${widget.controller.giftedCount}'),
                ),
              ],
            ),
          ),
        ),
        if (archived.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Keine Einträge für diesen Filter.'),
            ),
          )
        else
          ...archived.map((item) {
            final hasRecord = widget.controller.history.any(
              (entry) => entry.itemId == item.id,
            );
            return Card(
              child: ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: Text(item.name),
                subtitle: Text(
                  '${item.ownershipStatus.label}'
                  '${hasRecord ? ' • Historie gespeichert' : ''}',
                ),
              ),
            );
          }),
      ],
    );
  }
}
