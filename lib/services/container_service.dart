import '../models/item.dart';

class ContainerService {
  const ContainerService();

  bool canPlaceInside({
    required List<Item> items,
    required String itemId,
    required String? targetContainerId,
  }) {
    if (targetContainerId == null) {
      return true;
    }
    if (itemId == targetContainerId) {
      return false;
    }

    final byId = {for (final item in items) item.id: item};
    final target = byId[targetContainerId];
    if (target == null || !target.isContainer) {
      return false;
    }

    var cursor = target.containerId;
    while (cursor != null) {
      if (cursor == itemId) {
        return false;
      }
      cursor = byId[cursor]?.containerId;
    }

    return true;
  }

  List<Item> childrenOf(List<Item> items, String containerId) {
    return items.where((item) => item.containerId == containerId).toList();
  }

  String describeLocation(List<Item> items, Item item) {
    final chain = <String>[];
    final byId = {for (final value in items) value.id: value};
    var cursor = item.containerId;
    while (cursor != null) {
      final parent = byId[cursor];
      if (parent == null) {
        break;
      }
      chain.add(parent.name);
      cursor = parent.containerId;
    }
    if (chain.isEmpty) {
      return item.position == null ? 'Noch nicht platziert' : 'Im Raum';
    }
    return chain.reversed.join(' > ');
  }
}
