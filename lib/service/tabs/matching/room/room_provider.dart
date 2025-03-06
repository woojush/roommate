import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_service.dart';
import 'room_model.dart';

class RoomProvider extends ChangeNotifier {
  bool _isChecklistLoaded = false;
  Map<String, dynamic>? _userChecklist;
  List<RoomModel> _filteredRooms = [];

  bool get isChecklistLoaded => _isChecklistLoaded;
  Map<String, dynamic>? get userChecklist => _userChecklist;
  List<RoomModel> get filteredRooms => _filteredRooms;

  Future<void> loadChecklist() async {
    final data = await RoomService.fetchUserChecklist();
    if (data != null) {
      _userChecklist = data;
      _isChecklistLoaded = true;
      notifyListeners();
    }
  }

  void filterRooms(List<RoomModel> rooms) {
    if (_userChecklist == null) return;
    _filteredRooms = rooms.where((room) {
      return room.dorm == _userChecklist!['dorm'] &&
          room.roomType == _userChecklist!['roomType'] &&
          room.gender == _userChecklist!['gender'] &&
          room.dormDuration == _userChecklist!['dormDuration'] &&
          !room.isFull();
    }).toList();
    notifyListeners();
  }

  Future<void> increaseViewCount(RoomModel room) async {
    room.views++;
    notifyListeners();
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
    notifyListeners();
  }
}
