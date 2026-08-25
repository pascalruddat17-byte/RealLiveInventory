import 'package:flutter/material.dart';

import '../core/inventory_enums.dart';
import '../models/item.dart';

class ArchiveItemDialog extends StatefulWidget {
  const ArchiveItemDialog({
    super.key,
    required this.item,
    required this.onSubmit,
  });

  final Item item;
  final Future<void> Function({
    required OwnershipStatus status,
    required DateTime date,
    double? salePrice,
    String? person,
    String? note,
  }) onSubmit;

  @override
  State<ArchiveItemDialog> createState() => _ArchiveItemDialogState();
}

class _ArchiveItemDialogState extends State<ArchiveItemDialog> {
  OwnershipStatus status = OwnershipStatus.sold;
  final priceController = TextEditingController(text: '20');
  final personController = TextEditingController();
  final noteController = TextEditingController();
  DateTime date = DateTime.now();
  bool saving = false;

  @override
  void dispose() {
    priceController.dispose();
    personController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showPrice = status == OwnershipStatus.sold;
    final showPerson =
        status == OwnershipStatus.sold || status == OwnershipStatus.gifted;
    return AlertDialog(
      title: Text('${widget.item.name} archivieren'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<OwnershipStatus>(
              value: status,
              decoration: const InputDecoration(labelText: 'Grund'),
              items: OwnershipStatus.values
                  .where((value) => value != OwnershipStatus.owned)
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => status = value);
                }
              },
            ),
            if (showPrice)
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Verkaufspreis'),
                keyboardType: TextInputType.number,
              ),
            if (showPerson)
              TextField(
                controller: personController,
                decoration: InputDecoration(
                  labelText:
                      status == OwnershipStatus.sold ? 'Verkauft an' : 'Verschenkt an',
                ),
              ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Notiz'),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.event_outlined),
                const SizedBox(width: 8),
                Expanded(child: Text(_dateLabel(date))),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: date,
                    );
                    if (picked != null) {
                      setState(() => date = picked);
                    }
                  },
                  child: const Text('Ändern'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton.icon(
          onPressed: saving ? null : _submit,
          icon: const Icon(Icons.check),
          label: const Text('Speichern'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => saving = true);
    await widget.onSubmit(
      status: status,
      date: date,
      salePrice:
          status == OwnershipStatus.sold ? double.tryParse(priceController.text) : null,
      person: personController.text,
      note: noteController.text,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _dateLabel(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.'
        '${value.month.toString().padLeft(2, '0')}.${value.year}';
  }
}
