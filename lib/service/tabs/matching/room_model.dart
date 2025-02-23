/// ---------------------------------------------------------------------------
/// 이 파일은 매칭(룸) 관련 데이터 모델을 정의합니다.
/// - RoomModel: 방의 제목, 설명, 기숙사 정보, 방 종류, 성별, 생성일, 생성자, 멤버 목록 등을 포함합니다.
/// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String title;
  final String description;
  final String dorm;
  final String dormDuration;
  final String roomType;
  final String gender;
  final DateTime? createdAt;
  final String createdBy;
  final List<dynamic> members;

  RoomModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dorm,
    required this.dormDuration,
    required this.roomType,
    required this.gender,
    this.createdAt,
    required this.createdBy,
    required this.members,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RoomModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dorm: map['dorm'] ?? '',
      dormDuration: map['dormDuration'] ?? '',
      roomType: map['roomType'] ?? '',
      gender: map['gender'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] ?? '',
      members: map['members'] ?? [],
    );
  }
}
