import 'dart:math' as math;

class Vector3 {
  const Vector3({
    required this.x,
    required this.y,
    required this.z,
  });

  const Vector3.zero() : this(x: 0, y: 0, z: 0);
  const Vector3.one() : this(x: 1, y: 1, z: 1);

  final double x;
  final double y;
  final double z;

  Vector3 copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return Vector3(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  double distanceTo(Vector3 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  Map<String, Object?> toJson() => {
        'x': x,
        'y': y,
        'z': z,
      };

  factory Vector3.fromJson(Map<String, Object?> json) {
    return Vector3(
      x: (json['x'] as num? ?? 0).toDouble(),
      y: (json['y'] as num? ?? 0).toDouble(),
      z: (json['z'] as num? ?? 0).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Vector3 && other.x == x && other.y == y && other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'Vector3($x, $y, $z)';
}
