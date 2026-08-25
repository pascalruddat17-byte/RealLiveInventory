import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/inventory_controller.dart';
import '../../core/inventory_enums.dart';
import '../../models/item.dart';
import '../../models/vector3.dart';
import '../../services/room_scan_service.dart';
import '../../three_d/room_view.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({
    super.key,
    required this.controller,
    this.roomScanService = const MockRoomScanService(),
  });

  final InventoryController controller;
  final RoomScanService roomScanService;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  double cameraAngle = -0.35;
  bool scanning = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.controller.selectedRoom;
    final highlighted = widget.controller.searchResults
        .map((result) => result.item.id)
        .toSet();
    final selected = widget.controller.selectedItem;

    if (room == null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _scanRoom,
          icon: const Icon(Icons.view_in_ar_outlined),
          label: Text(scanning ? 'Scanne ...' : 'Demo-Raumscan starten'),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RoomView(
            room: room,
            items: widget.controller.ownedItems
                .where((item) => item.roomId == room.id)
                .toList(),
            highlightedItemIds: highlighted,
            selectedItemId: selected?.id,
            cameraAngle: cameraAngle,
            onSelectItem: widget.controller.selectItem,
          ),
        ),
        _RoomControls(
          controller: widget.controller,
          selected: selected,
          cameraAngle: cameraAngle,
          onCameraAngleChanged: (value) => setState(() => cameraAngle = value),
          onScanRoom: _scanRoom,
          scanning: scanning,
        ),
      ],
    );
  }

  Future<void> _scanRoom() async {
    setState(() => scanning = true);
    final room = await widget.roomScanService.scanRoom();
    await widget.controller.saveRoom(room);
    if (mounted) {
      setState(() => scanning = false);
    }
  }
}

class _RoomControls extends StatefulWidget {
  const _RoomControls({
    required this.controller,
    required this.selected,
    required this.cameraAngle,
    required this.onCameraAngleChanged,
    required this.onScanRoom,
    required this.scanning,
  });

  final InventoryController controller;
  final Item? selected;
  final double cameraAngle;
  final ValueChanged<double> onCameraAngleChanged;
  final VoidCallback onScanRoom;
  final bool scanning;

  @override
  State<_RoomControls> createState() => _RoomControlsState();
}

class _RoomControlsState extends State<_RoomControls> {
  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.threed_rotation),
                  Expanded(
                    child: Slider(
                      value: widget.cameraAngle,
                      min: -math.pi,
                      max: math.pi,
                      onChanged: widget.onCameraAngleChanged,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Demo-Raumscan',
                    onPressed: widget.scanning ? null : widget.onScanRoom,
                    icon: const Icon(Icons.view_in_ar_outlined),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: selected?.id,
                decoration: const InputDecoration(labelText: 'Gegenstand auswählen'),
                items: widget.controller.ownedItems
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: widget.controller.selectItem,
              ),
              if (selected == null)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Tippe ein Objekt im Raum an oder wähle eines aus.'),
                )
              else
                _PlacementEditor(
                  item: selected,
                  onChanged: (item) {
                    widget.controller.placeItem(
                      itemId: item.id,
                      position: item.position ?? const Vector3.zero(),
                      rotation: item.rotation,
                      size: item.size,
                      model: item.model,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacementEditor extends StatefulWidget {
  const _PlacementEditor({
    required this.item,
    required this.onChanged,
  });

  final Item item;
  final ValueChanged<Item> onChanged;

  @override
  State<_PlacementEditor> createState() => _PlacementEditorState();
}

class _PlacementEditorState extends State<_PlacementEditor> {
  late Vector3 position;
  late Vector3 size;
  late Vector3 rotation;
  late PrimitiveModel model;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _PlacementEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _axisSlider('X', position.x, 0, 4, _setX)),
            Expanded(child: _axisSlider('Y', position.y, 0, 2.5, _setY)),
            Expanded(child: _axisSlider('Z', position.z, 0, 3.2, _setZ)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _axisSlider('Skalierung', size.x, 0.2, 2, _setScale)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<PrimitiveModel>(
                value: model,
                decoration: const InputDecoration(labelText: 'Modell'),
                items: PrimitiveModel.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => model = value);
                    _emit();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _axisSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Text('$label ${value.toStringAsFixed(1)}'),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _sync() {
    position = widget.item.position ?? const Vector3(x: 1, y: 0.5, z: 1);
    size = widget.item.size;
    rotation = widget.item.rotation;
    model = widget.item.model;
  }

  void _setX(double value) {
    setState(() => position = position.copyWith(x: value));
    _emit();
  }

  void _setY(double value) {
    setState(() => position = position.copyWith(y: value));
    _emit();
  }

  void _setZ(double value) {
    setState(() => position = position.copyWith(z: value));
    _emit();
  }

  void _setScale(double value) {
    setState(() => size = Vector3(x: value, y: value, z: value));
    _emit();
  }

  void _emit() {
    widget.onChanged(
      widget.item.copyWith(
        position: position,
        size: size,
        rotation: rotation,
        model: model,
      ),
    );
  }
}
