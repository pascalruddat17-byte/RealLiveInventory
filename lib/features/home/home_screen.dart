import 'package:flutter/material.dart';

import '../../core/inventory_controller.dart';
import '../../models/item.dart';
import '../../widgets/archive_item_dialog.dart';
import '../../widgets/item_tile.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onOpenScan,
    required this.onOpenSearch,
    required this.onOpenRoom,
    required this.onOpenHistory,
  });

  final InventoryController controller;
  final VoidCallback onOpenScan;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenRoom;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final owned = controller.ownedItems;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'RealLife Inventory',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Dein echtes Zimmer als durchsuchbares Inventar.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 650 ? 4 : 2,
          childAspectRatio: 1.65,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatCard(
              label: 'Gegenstände im Besitz',
              value: owned.length.toString(),
              icon: Icons.inventory_2_outlined,
            ),
            StatCard(
              label: 'Räume',
              value: controller.rooms.length.toString(),
              icon: Icons.meeting_room_outlined,
            ),
            StatCard(
              label: 'Verkauft',
              value: controller.soldCount.toString(),
              icon: Icons.sell_outlined,
            ),
            StatCard(
              label: 'Verschenkt',
              value: controller.giftedCount.toString(),
              icon: Icons.card_giftcard_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ActionButton(
              icon: Icons.meeting_room_outlined,
              label: 'Zimmer',
              onTap: onOpenRoom,
            ),
            _ActionButton(
              icon: Icons.inventory_2_outlined,
              label: 'Gegenstände',
              onTap: () {},
            ),
            _ActionButton(
              icon: Icons.search,
              label: 'Suche',
              onTap: onOpenSearch,
            ),
            _ActionButton(
              icon: Icons.archive_outlined,
              label: 'Nicht mehr im Besitz',
              onTap: onOpenHistory,
            ),
            _ActionButton(
              icon: Icons.center_focus_strong,
              label: 'Neuen Gegenstand scannen',
              onTap: onOpenScan,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Gegenstände',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        if (owned.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Noch keine Gegenstände vorhanden.'),
            ),
          )
        else
          ...owned.map(
            (item) => ItemTile(
              item: item,
              location: controller.locationFor(item),
              onTap: () => controller.selectItem(item.id),
              onArchive: () => _showArchiveDialog(context, item),
            ),
          ),
      ],
    );
  }

  Future<void> _showArchiveDialog(BuildContext context, Item item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ArchiveItemDialog(
        item: item,
        onSubmit: ({
          required status,
          required date,
          salePrice,
          person,
          note,
        }) {
          return controller.markNotOwned(
            item: item,
            status: status,
            date: date,
            salePrice: salePrice,
            person: person,
            note: note,
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton.tonalIcon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
