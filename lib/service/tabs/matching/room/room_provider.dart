import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_service.dart';
import 'room_model.dart';

// 상태 관리
class RoomProvider extends ChangeNotifier {
  bool _isChecklistLoaded = false; // ✅ 체크리스트 로딩 상태
  Map<String, dynamic>? _userChecklist; // ✅ 사용자의 체크리스트 데이터
  List<RoomModel> _filteredRooms = []; // ✅ 필터링된 방 목록

  bool get isChecklistLoaded => _isChecklistLoaded;
  Map<String, dynamic>? get userChecklist => _userChecklist;
  List<RoomModel> get filteredRooms => _filteredRooms;

  /// ✅ 체크리스트 로드 (사용자의 생활관, 인실, 기간, 성별 정보)
  Future<void> loadChecklist() async {
    final data = await RoomService.fetchUserChecklist();
    if (data != null) {
      _userChecklist = data; // _userChecklist 에 유저의 체크리스트 저장
      _isChecklistLoaded = true; // 체크리스트 불러오기 성공.
      notifyListeners(); // UI 업데이트
    }
  }

  /// ✅ 방 필터링 (사용자의 체크리스트와 일치하는 방만 유지)
  void filterRooms(List<RoomModel> rooms) {
    if (_userChecklist == null) return;

    _filteredRooms = rooms.where((room) {
      return room.dorm == _userChecklist!['dorm'] &&
          room.roomType == _userChecklist!['roomType'] &&
          room.gender == _userChecklist!['gender'] &&
          room.dormDuration == _userChecklist!['dormDuration'] &&
          !room.isFull(); // ✅ 방이 꽉 차지 않은 경우만 필터링
    }).toList();

    notifyListeners();
  }

  /// ✅ 조회수 증가 (Firestore에 업데이트)
  Future<void> increaseViewCount(RoomModel room) async {
    room.views++; // ✅ 로컬 변수 업데이트
    notifyListeners(); // ✅ UI 업데이트

    await RoomViews.increment(room.id);
  }

  /// ✅ 방 참여 요청 보내기
  Future<void> requestToJoinRoom(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await RoomService.requestJoin(roomId);
  }

  /// ✅ 방 나가기 기능
  Future<void> leaveRoom(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await RoomService.leaveRoom(roomId, user.uid);
    _filteredRooms.removeWhere((room) => room.id == roomId);
    notifyListeners();
  }
}
