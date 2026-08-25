import '../core/inventory_enums.dart';
import '../models/item.dart';
import '../models/vector3.dart';
import 'id_service.dart';

abstract class ItemRecognitionService {
  Future<Item> recognizeFromCameraPreview({
    required String roomId,
    String? containerId,
  });
}

class MockItemRecognitionService implements ItemRecognitionService {
  const MockItemRecognitionService({this.ids = const IdService()});

  final IdService ids;

  @override
  Future<Item> recognizeFromCameraPreview({
    required String roomId,
    String? containerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final now = DateTime.now();
    return Item(
      id: ids.next('item'),
      name: 'Bosch Akkuschrauber',
      alternativeNames: const ['Akkubohrer', 'Bohrschrauber'],
      description: 'Akkubetriebener Schrauber',
      category: 'Werkzeug',
      tags: const ['werkzeug', 'bohren', 'schrauben'],
      capabilities: const ['Schrauben', 'Bohren'],
      properties: const ['Akku', 'tragbar'],
      brand: 'Bosch',
      color: 'Grün',
      condition: ItemCondition.good,
      quantity: 1,
      photos: const [],
      createdAt: now,
      updatedAt: now,
      roomId: roomId,
      containerId: containerId,
      position: const Vector3(x: 1.2, y: 0.9, z: 0.8),
      rotation: const Vector3.zero(),
      size: const Vector3(x: 0.55, y: 0.22, z: 0.28),
      model: PrimitiveModel.cube,
      ownershipStatus: OwnershipStatus.owned,
      isContainer: false,
    );
  }
}
