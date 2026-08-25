import 'package:flutter_test/flutter_test.dart';
import 'package:reallife_inventory/database/demo_data.dart';
import 'package:reallife_inventory/services/container_service.dart';

void main() {
  test('Container service prevents self nesting', () {
    final data = DemoData.create();
    const service = ContainerService();

    expect(
      service.canPlaceInside(
        items: data.items,
        itemId: 'item_electronics_box',
        targetContainerId: 'item_electronics_box',
      ),
      isFalse,
    );
  });

  test('Container service prevents cycles', () {
    final data = DemoData.create();
    const service = ContainerService();

    expect(
      service.canPlaceInside(
        items: data.items,
        itemId: 'item_desk',
        targetContainerId: 'item_electronics_box',
      ),
      isFalse,
    );
  });
}
