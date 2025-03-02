/// room_model.dart
/// ---------------------------------------------------------------------------
/// 이 파일은 방(Room)의 데이터 모델을 정의합니다.
/// Firestore에서 가져온 방 정보를 RoomModel 객체로 변환하고,
/// 필요한 데이터를 포함하도록 구조를 최적화합니다.
/// ---------------------------------------------------------------------------
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id; // 방 고유 ID (Firestore 문서 ID)
  final String title; // 방 제목
  final String description; // 방 설명
  final String dorm; // 생활관 (제1생활관, 제2생활관, 제3생활관)
  final String roomType; // 인실 (2인실, 3인실 등)
  final String gender; // 성별 (남성, 여성)
  final String dormDuration; // 기숙사 기간 (한 학기, 1년 등)
  final String ownerUid; // 방 생성자 (UID)
  final List<String> members; // 현재 방에 속한 멤버 UID 리스트
  final List<String> joinRequests; // 참여 요청을 보낸 사용자 UID 리스트
  final DateTime createdAt; // 방 생성 시간
  final Map<String, dynamic> checklist; // 방 체크리스트 (룸메 선호도)

  RoomModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dorm,
    required this.roomType,
    required this.gender,
    required this.dormDuration,
    required this.ownerUid,
    required this.members,
    required this.joinRequests,
    required this.createdAt,
    required this.checklist,
  });

  /// 🟢 Firestore 데이터에서 RoomModel 객체로 변환
  factory RoomModel.fromMap(Map<String, dynamic> data, String documentId) {
    return RoomModel(
      id: documentId,
      title: data['title'] ?? '제목 없음',
      description: data['description'] ?? '',
      dorm: data['dorm'] ?? '미정',
      roomType: data['roomType'] ?? '미정',
      gender: data['gender'] ?? '미정',
      dormDuration: data['dormDuration'] ?? '미정',
      ownerUid: data['ownerUid'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      joinRequests: List<String>.from(data['joinRequests'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      checklist: Map<String, dynamic>.from(data['checklist'] ?? {}),
    );
  }

  /// 🟢 Firestore에 저장할 데이터 형식으로 변환
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dorm': dorm,
      'roomType': roomType,
      'gender': gender,
      'dormDuration': dormDuration,
      'ownerUid': ownerUid,
      'members': members,
      'joinRequests': joinRequests,
      'createdAt': createdAt,
      'checklist': checklist,
    };
  }
}
