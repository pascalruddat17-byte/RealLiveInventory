import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/demo_data.dart';
import '../models/item.dart';
import '../models/ownership_record.dart';
import '../models/room.dart';
import 'inventory_repository.dart';

class SqliteInventoryRepository implements InventoryRepository {
  SqliteInventoryRepository({String? databasePath}) : _databasePath = databasePath;

  final String? _databasePath;
  Database? _database;

  @override
  Future<void> initialize() async {
    final db = await _open();
    final roomCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM rooms'),
        ) ??
        0;
    if (roomCount == 0) {
      final demo = DemoData.create();
      await db.transaction((txn) async {
        for (final room in demo.rooms) {
          await _insertRoom(txn, room);
        }
        for (final item in demo.items) {
          await _insertItem(txn, item);
        }
        for (final record in demo.history) {
          await _insertHistory(txn, record);
        }
      });
    }
  }

  @override
  Future<List<Item>> loadItems() async {
    final rows = await (await _open()).query('items', orderBy: 'name COLLATE NOCASE');
    return rows.map((row) => Item.fromJson(_decode(row['data']))).toList();
  }

  @override
  Future<List<OwnershipRecord>> loadOwnershipHistory() async {
    final rows = await (await _open()).query('ownership_history', orderBy: 'date DESC');
    return rows.map((row) => OwnershipRecord.fromJson(_decode(row['data']))).toList();
  }

  @override
  Future<List<Room>> loadRooms() async {
    final rows = await (await _open()).query('rooms', orderBy: 'name COLLATE NOCASE');
    return rows.map((row) => Room.fromJson(_decode(row['data']))).toList();
  }

  @override
  Future<void> saveItem(Item item) async {
    await _insertItem(await _open(), item);
  }

  @override
  Future<void> saveItems(List<Item> items) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('items');
      for (final item in items) {
        await _insertItem(txn, item);
      }
    });
  }

  @override
  Future<void> saveOwnershipRecord(OwnershipRecord record) async {
    await _insertHistory(await _open(), record);
  }

  @override
  Future<void> saveRoom(Room room) async {
    await _insertRoom(await _open(), room);
  }

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final path = await _resolvePath();
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE rooms (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            data TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE items (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            room_id TEXT,
            container_id TEXT,
            ownership_status TEXT NOT NULL,
            data TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE ownership_history (
            id TEXT PRIMARY KEY,
            item_id TEXT NOT NULL,
            status TEXT NOT NULL,
            date TEXT NOT NULL,
            data TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_items_room ON items(room_id)');
        await db.execute('CREATE INDEX idx_items_container ON items(container_id)');
        await db.execute('CREATE INDEX idx_history_item ON ownership_history(item_id)');
      },
    );
    return _database!;
  }

  Future<String> _resolvePath() async {
    if (_databasePath != null) {
      return _databasePath;
    }
    final docs = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(docs.path, 'reallife_inventory'));
    await directory.create(recursive: true);
    return p.join(directory.path, 'inventory.db');
  }

  Future<void> _insertRoom(DatabaseExecutor db, Room room) {
    return db.insert(
      'rooms',
      {
        'id': room.id,
        'name': room.name,
        'data': jsonEncode(room.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _insertItem(DatabaseExecutor db, Item item) {
    return db.insert(
      'items',
      {
        'id': item.id,
        'name': item.name,
        'room_id': item.roomId,
        'container_id': item.containerId,
        'ownership_status': item.ownershipStatus.name,
        'data': jsonEncode(item.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _insertHistory(DatabaseExecutor db, OwnershipRecord record) {
    return db.insert(
      'ownership_history',
      {
        'id': record.id,
        'item_id': record.itemId,
        'status': record.status.name,
        'date': record.date.toIso8601String(),
        'data': jsonEncode(record.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _decode(Object? data) {
    return Map<String, Object?>.from(jsonDecode(data as String) as Map);
  }
}
