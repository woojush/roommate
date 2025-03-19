// service/tabs/matching/room/room_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_service.dart';
import 'room_model.dart';

class RoomProvider extends ChangeNotifier {
  bool _isChecklistLoaded = false;
  Map<String, dynamic>? _userChecklist;
  List<RoomModel> _filteredRooms = [];
  bool _disposed = false;

  bool get isChecklistLoaded => _isChecklistLoaded;
  Map<String, dynamic>? get userChecklist => _userChecklist;
  List<RoomModel> get filteredRooms => _filteredRooms;

  Future<void> loadChecklist() async {
    final data = await RoomService.fetchUserChecklist();
    if (data != null) {
      _userChecklist = data;
      _isChecklistLoaded = true;
      if (!_disposed) notifyListeners();
    }
  }

  /// 방 목록을 필터링할 때,
  /// - 사용자가 참여한 방은 항상 포함합니다.
  /// - 사용자가 참여하지 않은 방은, 방이 꽉 찼다면 제외하고, 체크리스트 조건에 맞는 경우만 포함합니다.
  void filterRooms(List<RoomModel> rooms) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (_userChecklist == null) return;
    _filteredRooms = rooms.where((room) {
      // 사용자가 이미 멤버라면 조건과 관계없이 포함
      if (currentUser != null && room.members.contains(currentUser.uid)) {
        return true;
      }
      // 사용자가 멤버가 아닌 경우, 방이 꽉 찼다면 제외
      if (room.isFull()) return false;
      // 나머지는 체크리스트 조건에 부합해야 포함
      return room.dorm == _userChecklist!['dorm'] &&
          room.roomType == _userChecklist!['roomType'] &&
          room.gender == _userChecklist!['gender'] &&
          room.dormDuration == _userChecklist!['dormDuration'];
    }).toList();
    if (!_disposed) notifyListeners();
  }

  Future<void> increaseViewCount(RoomModel room) async {
    if (_disposed) return;
    room.views++;
    if (!_disposed) notifyListeners();
    await RoomService.incrementRoomViews(room.id);
  }

  Future<void> requestToJoinRoom(String roomId) async {
    final user = await RoomService.getCurrentUser();
    if (user == null) return;
    await RoomService.requestJoin(roomId);
  }

  Future<void> leaveRoom(String roomId) async {
    final user = await RoomService.getCurrentUser();
    if (user == null) return;
    await RoomService.leaveRoom(roomId, user.uid);
    _filteredRooms.removeWhere((room) => room.id == roomId);
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
