import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/features/chat/logic/chat_controller.dart';
import 'package:jualbeli_buku_bekas/features/chat/presentation/pages/chat_room_page.dart';
import 'package:jualbeli_buku_bekas/models/chat_model.dart';
import 'package:jualbeli_buku_bekas/models/user_model.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';
import 'package:jualbeli_buku_bekas/services/user_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatController _chatController = ChatController();
  final UserService _userService = UserService();
  late String myId;

  bool _isLoading = true;
  List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    final user = SupabaseService.client.auth.currentUser;
    myId = user?.id ?? '';

    timeago.setLocaleMessages('id', timeago.IdMessages());
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    if (myId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final data = await _chatController.fetchMyRooms(context);

    if (mounted) {
      setState(() {
        _rooms = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (myId.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pesan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(child: Text('Belum ada pesan masuk'))
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.separated(
                    itemCount: _rooms.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final roomData = _rooms[index];
                      final room = ChatRoomModel.fromJson(roomData);

                      final otherUserId =
                          room.memberA == myId ? room.memberB : room.memberA;

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _userService.getUserProfile(otherUserId),
                        builder: (context, snapshot) {
                          String displayName = 'Memuat...';
                          String? avatarUrl;

                          if (snapshot.hasData && snapshot.data != null) {
                            final user = UserModel.fromJson(snapshot.data!);
                            displayName = user.fullName;
                            avatarUrl = user.avatarUrl;
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              displayName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              room.lastMessage ?? 'Gambar dikirim',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              timeago.format(room.updatedAt, locale: 'id'),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                    roomId: room.id,
                                    otherUserName: displayName,
                                  ),
                                ),
                              );
                              if (mounted) _loadRooms();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}