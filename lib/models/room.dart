class Room {
  const Room({
    required this.id,
    required this.name,
    required this.width,
    required this.depth,
    required this.height,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double width;
  final double depth;
  final double height;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room copyWith({
    String? id,
    String? name,
    double? width,
    double? depth,
    double? height,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'width': width,
        'depth': depth,
        'height': height,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Room.fromJson(Map<String, Object?> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      width: (json['width'] as num).toDouble(),
      depth: (json['depth'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
