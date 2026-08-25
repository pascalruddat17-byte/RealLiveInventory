import 'package:flutter_test/flutter_test.dart';
import 'package:reallife_inventory/core/inventory_enums.dart';
import 'package:reallife_inventory/models/ownership_record.dart';

void main() {
  test('Sold ownership record requires non-negative sale price', () {
    final record = OwnershipRecord(
      id: 'history_1',
      itemId: 'item_1',
      status: OwnershipStatus.sold,
      date: DateTime(2026, 8, 25),
      salePrice: 20,
      createdAt: DateTime(2026, 8, 25),
    );

    expect(record.hasValidSalePrice, isTrue);
  });

  test('Negative sale price is invalid', () {
    final record = OwnershipRecord(
      id: 'history_1',
      itemId: 'item_1',
      status: OwnershipStatus.sold,
      date: DateTime(2026, 8, 25),
      salePrice: -1,
      createdAt: DateTime(2026, 8, 25),
    );

    expect(record.hasValidSalePrice, isFalse);
  });
}
