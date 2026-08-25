import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/inventory_enums.dart';
import '../models/item.dart';
import '../models/room.dart';

class RoomView extends StatelessWidget {
  const RoomView({
    super.key,
    required this.room,
    required this.items,
    required this.highlightedItemIds,
    required this.selectedItemId,
    required this.cameraAngle,
    required this.onSelectItem,
  });

  final Room room;
  final List<Item> items;
  final Set<String> highlightedItemIds;
  final String? selectedItemId;
  final double cameraAngle;
  final ValueChanged<String> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final tapped = _hitTest(details.localPosition, size);
            if (tapped != null) {
              onSelectItem(tapped.id);
            }
          },
          child: InteractiveViewer(
            minScale: 0.7,
            maxScale: 3,
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: RoomPainter(
                room: room,
                items: items,
                highlightedItemIds: highlightedItemIds,
                selectedItemId: selectedItemId,
                cameraAngle: cameraAngle,
                colorScheme: Theme.of(context).colorScheme,
              ),
            ),
          ),
        );
      },
    );
  }

  Item? _hitTest(Offset tap, Size size) {
    final placed = items.where((item) => item.position != null).toList().reversed;
    for (final item in placed) {
      final center = RoomPainter.project(
        room: room,
        item: item,
        canvasSize: size,
        cameraAngle: cameraAngle,
      );
      if ((tap - center).distance < 34) {
        return item;
      }
    }
    return null;
  }
}

class RoomPainter extends CustomPainter {
  const RoomPainter({
    required this.room,
    required this.items,
    required this.highlightedItemIds,
    required this.selectedItemId,
    required this.cameraAngle,
    required this.colorScheme,
  });

  final Room room;
  final List<Item> items;
  final Set<String> highlightedItemIds;
  final String? selectedItemId;
  final double cameraAngle;
  final ColorScheme colorScheme;

  static Offset project({
    required Room room,
    required Item item,
    required Size canvasSize,
    required double cameraAngle,
  }) {
    final position = item.position;
    if (position == null) {
      return Offset.zero;
    }
    final normalizedX = (position.x / room.width) - 0.5;
    final normalizedZ = (position.z / room.depth) - 0.5;
    final cosA = math.cos(cameraAngle);
    final sinA = math.sin(cameraAngle);
    final rotatedX = normalizedX * cosA - normalizedZ * sinA;
    final rotatedZ = normalizedX * sinA + normalizedZ * cosA;
    final perspective = 1 / (1 + rotatedZ * 0.45);
    final x = canvasSize.width * (0.5 + rotatedX * 0.72 * perspective);
    final y = canvasSize.height * (0.73 - position.y / room.height * 0.42);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final floor = Path()
      ..moveTo(size.width * 0.18, size.height * 0.78)
      ..lineTo(size.width * 0.82, size.height * 0.78)
      ..lineTo(size.width * 0.66, size.height * 0.38)
      ..lineTo(size.width * 0.34, size.height * 0.38)
      ..close();

    final wallPaint = Paint()..color = colorScheme.surfaceVariant;
    final floorPaint = Paint()..color = colorScheme.surface;
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(floor, floorPaint);
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.78),
      Offset(size.width * 0.34, size.height * 0.38),
      wallPaint..strokeWidth = 18,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, size.height * 0.78),
      Offset(size.width * 0.66, size.height * 0.38),
      wallPaint..strokeWidth = 18,
    );
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.38),
      Offset(size.width * 0.66, size.height * 0.38),
      wallPaint..strokeWidth = 18,
    );

    for (var i = 1; i < 6; i++) {
      final t = i / 6;
      canvas.drawLine(
        Offset.lerp(
          Offset(size.width * 0.18, size.height * 0.78),
          Offset(size.width * 0.34, size.height * 0.38),
          t,
        )!,
        Offset.lerp(
          Offset(size.width * 0.82, size.height * 0.78),
          Offset(size.width * 0.66, size.height * 0.38),
          t,
        )!,
        gridPaint,
      );
      canvas.drawLine(
        Offset.lerp(
          Offset(size.width * 0.18, size.height * 0.78),
          Offset(size.width * 0.82, size.height * 0.78),
          t,
        )!,
        Offset.lerp(
          Offset(size.width * 0.34, size.height * 0.38),
          Offset(size.width * 0.66, size.height * 0.38),
          t,
        )!,
        gridPaint,
      );
    }

    final placed = items.where((item) => item.position != null).toList()
      ..sort((a, b) => (a.position!.z).compareTo(b.position!.z));
    for (final item in placed) {
      _drawItem(canvas, size, item);
    }
  }

  void _drawItem(Canvas canvas, Size size, Item item) {
    final center = project(
      room: room,
      item: item,
      canvasSize: size,
      cameraAngle: cameraAngle,
    );
    final modelSize = math.max(16.0, (item.size.x + item.size.z) * 28);
    final fill = Paint()..color = _colorFor(item.color);
    final outline = Paint()
      ..color = highlightedItemIds.contains(item.id)
          ? Colors.amber
          : selectedItemId == item.id
              ? colorScheme.primary
              : colorScheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlightedItemIds.contains(item.id) ? 4 : 2;

    final rect = Rect.fromCenter(
      center: center,
      width: modelSize * item.size.x.clamp(0.3, 2.2),
      height: modelSize * item.size.z.clamp(0.3, 2.2),
    );

    switch (item.model) {
      case PrimitiveModel.sphere:
        canvas.drawCircle(center, rect.width / 2, fill);
        canvas.drawCircle(center, rect.width / 2, outline);
        break;
      case PrimitiveModel.cylinder:
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
        canvas.drawRRect(rrect, fill);
        canvas.drawRRect(rrect, outline);
        break;
      case PrimitiveModel.box:
      case PrimitiveModel.cube:
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, outline);
        break;
    }

    if (highlightedItemIds.contains(item.id)) {
      final markerPaint = Paint()..color = Colors.amber;
      canvas.drawCircle(center.translate(0, -modelSize), 8, markerPaint);
    }
  }

  Color _colorFor(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('grün')) return const Color(0xFF3FB950);
    if (normalized.contains('blau')) return const Color(0xFF58A6FF);
    if (normalized.contains('rot')) return const Color(0xFFFF6B6B);
    if (normalized.contains('schwarz')) return const Color(0xFF2B2D31);
    if (normalized.contains('grau')) return const Color(0xFF8B949E);
    if (normalized.contains('braun')) return const Color(0xFF8D6E63);
    return colorScheme.primaryContainer;
  }

  @override
  bool shouldRepaint(covariant RoomPainter oldDelegate) {
    return oldDelegate.room != room ||
        oldDelegate.items != items ||
        oldDelegate.highlightedItemIds != highlightedItemIds ||
        oldDelegate.selectedItemId != selectedItemId ||
        oldDelegate.cameraAngle != cameraAngle;
  }
}
