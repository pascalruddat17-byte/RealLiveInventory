import 'package:flutter_test/flutter_test.dart';
import 'package:reallife_inventory/core/inventory_enums.dart';
import 'package:reallife_inventory/models/item.dart';
import 'package:reallife_inventory/models/vector3.dart';

void main() {
  test('Item model survives JSON round trip', () {
    final now = DateTime(2026, 8, 25);
    final item = Item(
      id: 'item_1',
      name: 'Akkuschrauber',
      alternativeNames: const ['Bohrschrauber'],
      description: 'Akkubetriebener Schrauber',
      category: 'Werkzeug',
      tags: const ['akku'],
      capabilities: const ['Schrauben', 'Bohren'],
      properties: const ['tragbar'],
      brand: 'Bosch',
      color: 'Grün',
      condition: ItemCondition.good,
      quantity: 1,
      photos: const [],
      createdAt: now,
      updatedAt: now,
      roomId: 'room_1',
      containerId: null,
      position: const Vector3(x: 1, y: 2, z: 3),
      rotation: const Vector3.zero(),
      size: const Vector3.one(),
      model: PrimitiveModel.cube,
      ownershipStatus: OwnershipStatus.owned,
      isContainer: false,
    );

    final decoded = Item.fromJson(item.toJson());

    expect(decoded.id, item.id);
    expect(decoded.name, item.name);
    expect(decoded.capabilities, contains('Bohren'));
    expect(decoded.position, const Vector3(x: 1, y: 2, z: 3));
    expect(decoded.model, PrimitiveModel.cube);
  });
}
