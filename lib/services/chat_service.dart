import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';

class ChatService {
  final SupabaseClient _supabase = SupabaseService.client;

  Future<String> createOrGetChatRoom(String otherUserId) async {
    final myId = _supabase.auth.currentUser!.id;

    final response = await _supabase.from('chat_rooms').select().or(
          'and(member_a.eq.$myId,member_b.eq.$otherUserId),and(member_a.eq.$otherUserId,member_b.eq.$myId)',
        ).maybeSingle();

    if (response != null) {
      return response['id'];
    }

    final newRoom = await _supabase.from('chat_rooms').insert({
      'member_a': myId,
      'member_b': otherUserId,
      'last_message': 'Chat dimulai',
      'last_updated': DateTime.now().toUtc().toIso8601String(),
    }).select().single();

    return newRoom['id'];
  }

  Future<void> sendMessage(String roomId, String content) async {
    final myId = _supabase.auth.currentUser!.id;
    final now = DateTime.now().toUtc().toIso8601String();

    await _supabase.from('messages').insert({
      'room_id': roomId,
      'sender_id': myId,
      'content': content,
      'created_at': now,
    });

    await _supabase.from('chat_rooms').update({
      'last_message': content,
      'last_updated': now,
    }).eq('id', roomId);
  }

  Future<void> markMessagesAsRead(String roomId) async {
    final myId = _supabase.auth.currentUser!.id;
    await _supabase.from('messages').update({
      'is_read': true,
    }).match({
      'room_id': roomId,
      'is_read': false,
    }).neq('sender_id', myId);
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true);
  }

  Future<List<Map<String, dynamic>>> getMyChatRooms() async {
    final myId = _supabase.auth.currentUser!.id;
    
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .or('member_a.eq.$myId,member_b.eq.$myId')
        .order('last_updated', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}