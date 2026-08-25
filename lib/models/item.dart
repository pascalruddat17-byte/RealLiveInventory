import '../core/inventory_enums.dart';
import 'vector3.dart';

class Item {
  const Item({
    required this.id,
    required this.name,
    required this.alternativeNames,
    required this.description,
    required this.category,
    required this.tags,
    required this.capabilities,
    required this.properties,
    required this.brand,
    required this.color,
    required this.condition,
    required this.quantity,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
    required this.roomId,
    required this.position,
    required this.rotation,
    required this.size,
    required this.model,
    required this.ownershipStatus,
    required this.isContainer,
    this.containerId,
  });

  final String id;
  final String name;
  final List<String> alternativeNames;
  final String description;
  final String category;
  final List<String> tags;
  final List<String> capabilities;
  final List<String> properties;
  final String brand;
  final String color;
  final ItemCondition condition;
  final int quantity;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? roomId;
  final String? containerId;
  final Vector3? position;
  final Vector3 rotation;
  final Vector3 size;
  final PrimitiveModel model;
  final OwnershipStatus ownershipStatus;
  final bool isContainer;

  bool get isOwned => ownershipStatus.isOwned;
  bool get hasPosition => position != null;

  Item copyWith({
    String? id,
    String? name,
    List<String>? alternativeNames,
    String? description,
    String? category,
    List<String>? tags,
    List<String>? capabilities,
    List<String>? properties,
    String? brand,
    String? color,
    ItemCondition? condition,
    int? quantity,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? roomId,
    Object? containerId = _unchanged,
    Object? position = _unchanged,
    Vector3? rotation,
    Vector3? size,
    PrimitiveModel? model,
    OwnershipStatus? ownershipStatus,
    bool? isContainer,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      capabilities: capabilities ?? this.capabilities,
      properties: properties ?? this.properties,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      condition: condition ?? this.condition,
      quantity: quantity ?? this.quantity,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roomId: roomId ?? this.roomId,
      containerId: identical(containerId, _unchanged)
          ? this.containerId
          : containerId as String?,
      position:
          identical(position, _unchanged) ? this.position : position as Vector3?,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      model: model ?? this.model,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      isContainer: isContainer ?? this.isContainer,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'alternativeNames': alternativeNames,
        'description': description,
        'category': category,
        'tags': tags,
        'capabilities': capabilities,
        'properties': properties,
        'brand': brand,
        'color': color,
        'condition': condition.name,
        'quantity': quantity,
        'photos': photos,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'roomId': roomId,
        'containerId': containerId,
        'position': position?.toJson(),
        'rotation': rotation.toJson(),
        'size': size.toJson(),
        'model': model.name,
        'ownershipStatus': ownershipStatus.name,
        'isContainer': isContainer,
      };

  factory Item.fromJson(Map<String, Object?> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      alternativeNames: _stringList(json['alternativeNames']),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      tags: _stringList(json['tags']),
      capabilities: _stringList(json['capabilities']),
      properties: _stringList(json['properties']),
      brand: json['brand'] as String? ?? '',
      color: json['color'] as String? ?? '',
      condition:
          ItemCondition.values.byName(json['condition'] as String? ?? 'good'),
      quantity: json['quantity'] as int? ?? 1,
      photos: _stringList(json['photos']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      roomId: json['roomId'] as String?,
      containerId: json['containerId'] as String?,
      position: json['position'] == null
          ? null
          : Vector3.fromJson(Map<String, Object?>.from(json['position'] as Map)),
      rotation:
          Vector3.fromJson(Map<String, Object?>.from(json['rotation'] as Map)),
      size: Vector3.fromJson(Map<String, Object?>.from(json['size'] as Map)),
      model: PrimitiveModel.values.byName(json['model'] as String? ?? 'box'),
      ownershipStatus: OwnershipStatus.values
          .byName(json['ownershipStatus'] as String? ?? 'owned'),
      isContainer: json['isContainer'] as bool? ?? false,
    );
  }

  static List<String> _stringList(Object? value) {
    return (value as List? ?? const [])
        .map((entry) => entry.toString())
        .where((entry) => entry.trim().isNotEmpty)
        .toList();
  }
}

const Object _unchanged = Object();
