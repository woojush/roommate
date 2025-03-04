/// room_model.dart
/// ---------------------------------------------------------------------------
/// Firestore에서 가져온 방 정보를 RoomModel 객체로 변환하고,
/// 필요한 데이터를 포함하도록 구조를 최적화합니다.
/// ---------------------------------------------------------------------------
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// 방(Room)의 데이터 모델을 정의
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
  final int maxMembers; // 방 최대 수용 인원
  int views; // 방 조회수

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
    required this.maxMembers,
    this.views = 0, // ✅ 기본값 0을 직접 설정하여 views 필드 자동 생성 보장
  });

  /// 🟢 현재 방의 멤버 수 반환
  int get currentMembers => members.length;

  /// 🟢 현재 방이 꽉 찼는지 확인
  bool isFull() {
    return currentMembers >= maxMembers;
  }

  /// 🟢 방이 생성된 시간(몇 시간 전) 계산
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy년 MM월 dd일').format(createdAt);
    }
  }

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
      createdAt: (data['createdAt'] != null)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // ✅ 기본값 제공
      checklist: Map<String, dynamic>.from(data['checklist'] ?? {}),
      maxMembers: data['maxMembers'] ?? 2, // ✅ 기본값 2명으로 설정
      views: data.containsKey('views') ? (data['views'] ?? 0) : 0, // ✅ views 필드가 없을 경우 기본값 0 설정
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
      'createdAt': Timestamp.fromDate(createdAt), // ✅ Firestore 저장 시 Timestamp로 변환
      'checklist': checklist,
      'maxMembers': maxMembers, // ✅ Firestore 저장 시 최대 인원 포함
      'views': views, // ✅ Firestore 저장 시 views 필드 포함
    };
  }
}
