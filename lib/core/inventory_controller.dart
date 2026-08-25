import 'package:flutter/foundation.dart';

import '../models/item.dart';
import '../models/ownership_record.dart';
import '../models/room.dart';
import '../models/vector3.dart';
import '../repositories/inventory_repository.dart';
import '../search/inventory_search_engine.dart';
import '../search/search_result.dart';
import '../services/container_service.dart';
import '../services/id_service.dart';
import 'inventory_enums.dart';

class InventoryController extends ChangeNotifier {
  InventoryController({
    required InventoryRepository repository,
    InventorySearchEngine searchEngine = const InventorySearchEngine(),
    ContainerService containerService = const ContainerService(),
    IdService ids = const IdService(),
  })  : _repository = repository,
        _searchEngine = searchEngine,
        _containerService = containerService,
        _ids = ids;

  final InventoryRepository _repository;
  final InventorySearchEngine _searchEngine;
  final ContainerService _containerService;
  final IdService _ids;

  List<Room> rooms = [];
  List<Item> items = [];
  List<OwnershipRecord> history = [];
  List<SearchResult> searchResults = [];
  String searchQuery = '';
  String? selectedRoomId;
  String? selectedItemId;
  bool isLoading = true;
  String? errorMessage;

  List<Item> get ownedItems =>
      items.where((item) => item.ownershipStatus.isOwned).toList();

  List<Item> get archivedItems =>
      items.where((item) => !item.ownershipStatus.isOwned).toList();

  Room? get selectedRoom {
    if (rooms.isEmpty) {
      return null;
    }
    return rooms.firstWhere(
      (room) => room.id == selectedRoomId,
      orElse: () => rooms.first,
    );
  }

  Item? get selectedItem {
    if (selectedItemId == null) {
      return null;
    }
    for (final item in items) {
      if (item.id == selectedItemId) {
        return item;
      }
    }
    return null;
  }

  int get soldCount =>
      items.where((item) => item.ownershipStatus == OwnershipStatus.sold).length;

  int get giftedCount => items
      .where((item) => item.ownershipStatus == OwnershipStatus.gifted)
      .length;

  double get totalSales => history
      .where((record) => record.status == OwnershipStatus.sold)
      .fold(0, (sum, record) => sum + (record.salePrice ?? 0));

  Future<void> initialize() async {
    try {
      isLoading = true;
      notifyListeners();
      await _repository.initialize();
      rooms = await _repository.loadRooms();
      items = await _repository.loadItems();
      history = await _repository.loadOwnershipHistory();
      selectedRoomId = rooms.isEmpty ? null : rooms.first.id;
      errorMessage = null;
    } on Object catch (error) {
      errorMessage = 'Die lokalen Daten konnten nicht geladen werden: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    searchQuery = query;
    searchResults = _searchEngine.search(query: query, items: items);
    if (searchResults.isNotEmpty) {
      selectedItemId = searchResults.first.item.id;
    }
    notifyListeners();
  }

  Future<void> saveRoom(Room room) async {
    await _repository.saveRoom(room);
    rooms = await _repository.loadRooms();
    selectedRoomId = room.id;
    notifyListeners();
  }

  Future<void> saveItem(Item item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _repository.saveItem(updated);
    items = await _repository.loadItems();
    if (searchQuery.isNotEmpty) {
      search(searchQuery);
    } else {
      notifyListeners();
    }
  }

  Future<bool> moveItemToContainer(String itemId, String? containerId) async {
    if (!_containerService.canPlaceInside(
      items: items,
      itemId: itemId,
      targetContainerId: containerId,
    )) {
      errorMessage = 'Dieser Container würde eine ungültige Verschachtelung erzeugen.';
      notifyListeners();
      return false;
    }
    final item = items.firstWhere((value) => value.id == itemId);
    await saveItem(item.copyWith(containerId: containerId));
    errorMessage = null;
    return true;
  }

  Future<void> placeItem({
    required String itemId,
    required Vector3 position,
    required Vector3 rotation,
    required Vector3 size,
    required PrimitiveModel model,
  }) async {
    final item = items.firstWhere((value) => value.id == itemId);
    await saveItem(
      item.copyWith(
        position: position,
        rotation: rotation,
        size: size,
        model: model,
      ),
    );
    selectedItemId = itemId;
    notifyListeners();
  }

  Future<void> markNotOwned({
    required Item item,
    required OwnershipStatus status,
    required DateTime date,
    double? salePrice,
    String? person,
    String? note,
  }) async {
    if (status == OwnershipStatus.owned) {
      return;
    }
    final record = OwnershipRecord(
      id: _ids.next('history'),
      itemId: item.id,
      status: status,
      date: date,
      salePrice: salePrice,
      person: person?.trim().isEmpty ?? true ? null : person?.trim(),
      note: note?.trim().isEmpty ?? true ? null : note?.trim(),
      createdAt: DateTime.now(),
    );
    if (!record.hasValidSalePrice) {
      errorMessage = 'Bitte gib einen gültigen Verkaufspreis an.';
      notifyListeners();
      return;
    }

    await _repository.saveOwnershipRecord(record);
    await _repository.saveItem(
      item.copyWith(
        ownershipStatus: status,
        position: null,
        containerId: null,
        updatedAt: DateTime.now(),
      ),
    );
    items = await _repository.loadItems();
    history = await _repository.loadOwnershipHistory();
    errorMessage = null;
    notifyListeners();
  }

  void selectItem(String? itemId) {
    selectedItemId = itemId;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String locationFor(Item item) => _containerService.describeLocation(items, item);
}
