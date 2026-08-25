import 'package:flutter_test/flutter_test.dart';
import 'package:reallife_inventory/database/demo_data.dart';
import 'package:reallife_inventory/search/inventory_search_engine.dart';

void main() {
  test('Search ranks capability matches highly', () {
    final data = DemoData.create();
    const engine = InventorySearchEngine();

    final results = engine.search(
      query: 'Ding zum Schrauben',
      items: data.items,
    );

    expect(results, isNotEmpty);
    expect(results.first.item.name, 'Akkuschrauber');
  });

  test('Fuzzy search tolerates small typos', () {
    final data = DemoData.create();
    const engine = InventorySearchEngine();

    final results = engine.search(
      query: 'akkuschraubr',
      items: data.items,
    );

    expect(results.first.item.name, 'Akkuschrauber');
  });
}
