import 'package:flutter/material.dart';

import '../models/item.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.location,
    this.onTap,
    this.onArchive,
    this.trailing,
  });

  final Item item;
  final String location;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 12,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: item.photos.isEmpty
              ? const Icon(Icons.inventory_2_outlined)
              : const Icon(Icons.photo_outlined),
        ),
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${item.category} • $location',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ??
            (onArchive == null
                ? null
                : IconButton(
                    tooltip: 'Nicht mehr im Besitz',
                    icon: const Icon(Icons.archive_outlined),
                    onPressed: onArchive,
                  )),
      ),
    );
  }
}
