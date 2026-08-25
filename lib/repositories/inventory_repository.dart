import '../models/item.dart';
import '../models/ownership_record.dart';
import '../models/room.dart';

abstract class InventoryRepository {
  Future<void> initialize();
  Future<List<Room>> loadRooms();
  Future<List<Item>> loadItems();
  Future<List<OwnershipRecord>> loadOwnershipHistory();
  Future<void> saveRoom(Room room);
  Future<void> saveItem(Item item);
  Future<void> saveItems(List<Item> items);
  Future<void> saveOwnershipRecord(OwnershipRecord record);
}
