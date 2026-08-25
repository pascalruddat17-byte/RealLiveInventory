import 'package:flutter/material.dart';

import '../../core/inventory_controller.dart';
import '../../core/inventory_enums.dart';
import '../../models/item.dart';
import '../../services/item_recognition_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.controller,
    this.recognitionService = const MockItemRecognitionService(),
  });

  final InventoryController controller;
  final ItemRecognitionService recognitionService;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  ScanStep step = ScanStep.start;
  Item? draft;
  bool busy = false;

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final capabilitiesController = TextEditingController();
  final propertiesController = TextEditingController();
  final brandController = TextEditingController();
  final colorController = TextEditingController();
  final quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    capabilitiesController.dispose();
    propertiesController.dispose();
    brandController.dispose();
    colorController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Gegenstand scannen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ScanStep.values
              .map(
                (value) => Chip(
                  label: Text(value.label),
                  avatar: Icon(
                    value.index <= step.index
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt_outlined, size: 58),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: busy ? null : _recognize,
                  icon: const Icon(Icons.center_focus_strong),
                  label: Text(busy ? 'Erkenne ...' : 'Mock-Scan starten'),
                ),
              ],
            ),
          ),
        ),
        if (draft != null) ...[
          const SizedBox(height: 12),
          _buildForm(context),
        ],
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Kategorie'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Beschreibung'),
              minLines: 1,
              maxLines: 3,
            ),
            TextField(
              controller: capabilitiesController,
              decoration: const InputDecoration(labelText: 'Fähigkeiten'),
            ),
            TextField(
              controller: propertiesController,
              decoration: const InputDecoration(labelText: 'Eigenschaften'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Marke'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: colorController,
                    decoration: const InputDecoration(labelText: 'Farbe'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Menge'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Gegenstand speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recognize() async {
    final roomId = widget.controller.selectedRoom?.id;
    if (roomId == null) {
      return;
    }
    setState(() {
      busy = true;
      step = ScanStep.camera;
    });
    final recognized = await widget.recognitionService.recognizeFromCameraPreview(
      roomId: roomId,
    );
    _fillForm(recognized);
    setState(() {
      draft = recognized;
      busy = false;
      step = ScanStep.edit;
    });
  }

  void _fillForm(Item item) {
    nameController.text = item.name;
    categoryController.text = item.category;
    descriptionController.text = item.description;
    capabilitiesController.text = item.capabilities.join(', ');
    propertiesController.text = item.properties.join(', ');
    brandController.text = item.brand;
    colorController.text = item.color;
    quantityController.text = item.quantity.toString();
  }

  Future<void> _save() async {
    final current = draft;
    if (current == null || nameController.text.trim().isEmpty) {
      return;
    }
    final saved = current.copyWith(
      name: nameController.text.trim(),
      category: categoryController.text.trim(),
      description: descriptionController.text.trim(),
      capabilities: _split(capabilitiesController.text),
      properties: _split(propertiesController.text),
      brand: brandController.text.trim(),
      color: colorController.text.trim(),
      quantity: int.tryParse(quantityController.text) ?? 1,
    );
    await widget.controller.saveItem(saved);
    setState(() {
      step = ScanStep.saved;
      draft = null;
    });
  }

  List<String> _split(String value) {
    return value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }
}
