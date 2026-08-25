import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reallife_inventory/repositories/sqlite_inventory_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('SQLite repository seeds demo data and persists updates', () async {
    final dir = await Directory.systemTemp.createTemp('reallife_inventory_test');
    final path = '${dir.path}${Platform.pathSeparator}inventory.db';

    final repository = SqliteInventoryRepository(databasePath: path);
    await repository.initialize();
    final rooms = await repository.loadRooms();
    final items = await repository.loadItems();

    expect(rooms, isNotEmpty);
    expect(items.any((item) => item.name == 'Akkuschrauber'), isTrue);

    final updated = items.first.copyWith(name: 'Umbenannt');
    await repository.saveItem(updated);

    final repositoryReloaded = SqliteInventoryRepository(databasePath: path);
    await repositoryReloaded.initialize();
    final reloadedItems = await repositoryReloaded.loadItems();

    expect(reloadedItems.any((item) => item.name == 'Umbenannt'), isTrue);

    await dir.delete(recursive: true);
  });
}
