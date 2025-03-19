import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findmate1/main.dart'; // routeObserver가 정의된 파일
import 'package:findmate1/service/tabs/matching/room/room_model.dart';
import 'package:findmate1/service/tabs/matching/room/room_provider.dart';
import 'package:findmate1/service/tabs/matching/room/room_service.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_detail_screen.dart';
import 'package:findmate1/widgets/main_tab_appbar.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_card.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_filter_button.dart';
import 'create_room_screen.dart';
import 'package:findmate1/widgets/warning_dialog.dart';
import 'join_requests_screen.dart';
import 'package:findmate1/widgets/warning_dialog.dart';

class RoomListScreen extends StatefulWidget {
  final RoomModel room;
  const RoomListScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> with RouteAware {
  Future<List<RoomModel>>? _roomFuture;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 화면에 다시 돌아왔을 때 목록 새로고침
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final allRooms = await RoomService.fetchRooms();
    setState(() {
      _roomFuture = Future.value(allRooms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomProvider()..loadChecklist(),
      child: Consumer<RoomProvider>(
        builder: (context, provider, _) {
          if (!provider.isChecklistLoaded) {
            return Scaffold(
              appBar: MainTabAppBar(title: "룸메이트 찾기"),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: MainTabAppBar(
              title: "룸메이트 찾기",
              actions: [
                IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) return;
                    final myOwnedRooms = provider.filteredRooms
                        .where((room) => room.ownerUid == currentUser.uid)
                        .toList();
                    if (myOwnedRooms.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JoinRequestsScreen(roomId: myOwnedRooms.first.id),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => WarningDialog(
                          title: '알림',
                          message: '소유한 방이 없습니다.',
                          buttonCount: 1,
                          confirmText: '확인',
                          onConfirm: () => Navigator.pop(context),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _fetchRooms,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${provider.userChecklist!['dorm']} / "
                              "${provider.userChecklist!['roomType']} / "
                              "${provider.userChecklist!['dormDuration']} / "
                              "${provider.userChecklist!['gender']}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        RoomFilterButton(onPressed: () {}),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<RoomModel>>(
                      future: _roomFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('등록된 방이 없습니다.'));
                        }
                        final allRooms = snapshot.data!;
                        final currentUser = FirebaseAuth.instance.currentUser;

                        // 방이 꽉 찼으면, 사용자가 멤버가 아니면 제외
                        final validRooms = allRooms.where((room) {
                          if (room.isFull() &&
                              (currentUser == null || !room.members.contains(currentUser.uid))) {
                            return false;
                          }
                          return true;
                        }).toList();

                        // Provider에 validRooms 업데이트
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<RoomProvider>(context, listen: false)
                              .filterRooms(validRooms);
                        });

                        final filteredRooms = provider.filteredRooms;
                        List<RoomModel> myRooms = [];
                        List<RoomModel> otherRooms = [];
                        if (currentUser != null) {
                          for (var room in filteredRooms) {
                            if (room.members.contains(currentUser.uid)) {
                              myRooms.add(room);
                            } else {
                              otherRooms.add(room);
                            }
                          }
                        } else {
                          otherRooms = filteredRooms;
                        }

                        List<Widget> roomWidgets = [];
                        if (myRooms.isNotEmpty) {
                          roomWidgets.addAll(
                            myRooms.map(
                                  (room) => RoomCard(
                                room: room,
                                onRefresh: () {
                                  provider.increaseViewCount(room);
                                },
                                isMyRoom: true,
                                // 수정: RoomDetailScreen으로 라우트 (roomId: room.id)
                                routeBuilder: (context) =>
                                    RoomDetailScreen(roomId: room.id),
                              ),
                            ),
                          );
                          roomWidgets.add(const Divider(thickness: 0.5));
                        }
                        roomWidgets.addAll(
                          otherRooms.map(
                                (room) => RoomCard(
                               room: room,
                              onRefresh: () {
                                provider.increaseViewCount(room);
                              },
                              isMyRoom: false,
                              // 수정: RoomDetailScreen으로 라우트 (roomId: room.id)
                              routeBuilder: (context) =>
                                  RoomDetailScreen(roomId: room.id),
                            ),
                          ),
                        );

                        return ListView(
                          children: roomWidgets,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                bool alreadyInRoom = await RoomService.isUserInRoom();
                if (alreadyInRoom) {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        WarningDialog(message: '이미 참여하고 있는 방이 있습니다.'),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRoomScreen()),
                );
              },
              label: const Text('방 만들기', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          );
        },
      ),
    );
  }
}
