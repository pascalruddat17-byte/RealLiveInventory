import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/demo_data.dart';
import '../models/item.dart';
import '../models/ownership_record.dart';
import '../models/room.dart';
import 'inventory_repository.dart';

class JsonInventoryRepository implements InventoryRepository {
  JsonInventoryRepository({String? databasePath}) : _databasePath = databasePath;

  final String? _databasePath;
  File? _databaseFile;
  List<Room> _rooms = [];
  List<Item> _items = [];
  List<OwnershipRecord> _history = [];

  @override
  Future<void> initialize() async {
    final databaseFile = await _resolveDatabaseFile();
    if (!databaseFile.existsSync()) {
      await databaseFile.parent.create(recursive: true);
      final demo = DemoData.create();
      _rooms = demo.rooms;
      _items = demo.items;
      _history = demo.history;
      await _persist();
      return;
    }

    try {
      final decoded =
          jsonDecode(await databaseFile.readAsString()) as Map<String, Object?>;
      _rooms = _decodeList(decoded['rooms'], Room.fromJson);
      _items = _decodeList(decoded['items'], Item.fromJson);
      _history = _decodeList(decoded['history'], OwnershipRecord.fromJson);
    } on Object {
      final backup = File('${databaseFile.path}.broken');
      if (databaseFile.existsSync()) {
        await databaseFile.copy(backup.path);
      }
      final demo = DemoData.create();
      _rooms = demo.rooms;
      _items = demo.items;
      _history = demo.history;
      await _persist();
    }
  }

  @override
  Future<List<Item>> loadItems() async => List.unmodifiable(_items);

  @override
  Future<List<OwnershipRecord>> loadOwnershipHistory() async {
    return List.unmodifiable(_history);
  }

  @override
  Future<List<Room>> loadRooms() async => List.unmodifiable(_rooms);

  @override
  Future<void> saveItem(Item item) async {
    final index = _items.indexWhere((value) => value.id == item.id);
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    await _persist();
  }

  @override
  Future<void> saveItems(List<Item> items) async {
    _items = List<Item>.from(items);
    await _persist();
  }

  @override
  Future<void> saveOwnershipRecord(OwnershipRecord record) async {
    final index = _history.indexWhere((value) => value.id == record.id);
    if (index == -1) {
      _history.add(record);
    } else {
      _history[index] = record;
    }
    await _persist();
  }

  @override
  Future<void> saveRoom(Room room) async {
    final index = _rooms.indexWhere((value) => value.id == room.id);
    if (index == -1) {
      _rooms.add(room);
    } else {
      _rooms[index] = room;
    }
    await _persist();
  }

  Future<void> _persist() async {
    final databaseFile = await _resolveDatabaseFile();
    await databaseFile.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await databaseFile.writeAsString(
      encoder.convert({
        'rooms': _rooms.map((room) => room.toJson()).toList(),
        'items': _items.map((item) => item.toJson()).toList(),
        'history': _history.map((entry) => entry.toJson()).toList(),
      }),
    );
  }

  Future<File> _resolveDatabaseFile() async {
    final existing = _databaseFile;
    if (existing != null) {
      return existing;
    }

    if (_databasePath != null) {
      _databaseFile = File(_databasePath);
      return _databaseFile!;
    }

    final docs = await getApplicationDocumentsDirectory();
    _databaseFile = File(
      '${docs.path}${Platform.pathSeparator}reallife_inventory${Platform.pathSeparator}inventory.json',
    );
    return _databaseFile!;
  }

  List<T> _decodeList<T>(
    Object? value,
    T Function(Map<String, Object?> json) fromJson,
  ) {
    return (value as List? ?? const [])
        .map((entry) => fromJson(Map<String, Object?>.from(entry as Map)))
        .toList();
  }
}
