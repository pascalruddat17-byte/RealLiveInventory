import '../core/inventory_enums.dart';

class OwnershipRecord {
  const OwnershipRecord({
    required this.id,
    required this.itemId,
    required this.status,
    required this.date,
    required this.createdAt,
    this.salePrice,
    this.person,
    this.note,
  });

  final String id;
  final String itemId;
  final OwnershipStatus status;
  final DateTime date;
  final DateTime createdAt;
  final double? salePrice;
  final String? person;
  final String? note;

  bool get hasValidSalePrice {
    if (status != OwnershipStatus.sold) {
      return salePrice == null;
    }
    return salePrice != null && salePrice! >= 0;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'itemId': itemId,
        'status': status.name,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'salePrice': salePrice,
        'person': person,
        'note': note,
      };

  factory OwnershipRecord.fromJson(Map<String, Object?> json) {
    return OwnershipRecord(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      status: OwnershipStatus.values.byName(json['status'] as String),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      person: json['person'] as String?,
      note: json['note'] as String?,
    );
  }
}
