import '../models/room.dart';
import 'id_service.dart';

abstract class RoomScanService {
  Future<Room> scanRoom();
}

class MockRoomScanService implements RoomScanService {
  const MockRoomScanService({this.ids = const IdService()});

  final IdService ids;

  @override
  Future<Room> scanRoom() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return Room(
      id: ids.next('room'),
      name: 'Gescanntes Zimmer',
      width: 4.2,
      depth: 3.4,
      height: 2.5,
      createdAt: now,
      updatedAt: now,
    );
  }
}
