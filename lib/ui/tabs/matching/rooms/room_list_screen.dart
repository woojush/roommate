import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findmate1/service/tabs/matching/room/room_model.dart';
import 'package:findmate1/service/tabs/matching/room/room_provider.dart';
import 'package:findmate1/service/tabs/matching/room/room_service.dart';
import 'package:findmate1/widgets/main_tab_appbar.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_card.dart';
import 'package:findmate1/ui/tabs/matching/rooms/room_filter_button.dart';
import 'create_room_screen.dart';
import 'package:findmate1/widgets/warning_dialog.dart';

class RoomListScreen extends StatefulWidget {
  final RoomModel room;
  const RoomListScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  Future<List<RoomModel>>? _roomFuture;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final future = RoomService.fetchRooms();
    setState(() {
      _roomFuture = future;
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
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: MainTabAppBar(title: "룸메이트 찾기",
            actions: [
              IconButton(onPressed: (){}, icon: Icon(Icons.mail))
            ],),
            body: RefreshIndicator(
              onRefresh: _fetchRooms,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${provider.userChecklist!['dorm']} / ${provider.userChecklist!['roomType']} / "
                              "${provider.userChecklist!['dormDuration']} / ${provider.userChecklist!['gender']}",
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
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('등록된 방이 없습니다.'));
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            provider.filterRooms(snapshot.data!);
                          }
                        });
                        return ListView.builder(
                          itemCount: provider.filteredRooms.length,
                          itemBuilder: (context, index) {
                            final room = provider.filteredRooms[index];
                            return RoomCard(
                              room: room,
                              onRefresh: () {
                                provider.increaseViewCount(room);
                              },
                            );
                          },
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
                    builder: (context) => WarningDialog(message: '이미 참여하고 있는 방이 있습니다.')
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRoomScreen()),
                );
              },
              label: Text('방 만들기', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.blue,
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
