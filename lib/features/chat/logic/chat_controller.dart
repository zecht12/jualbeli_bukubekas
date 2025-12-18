import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/services/chat_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';

class ChatController {
  final ChatService _service = ChatService();

  Future<String?> initiateChat(BuildContext context, String otherUserId) async {
    try {
      final roomId = await _service.createOrGetChatRoom(otherUserId);
      return roomId;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal membuka chat: $e');
      }
      return null;
    }
  }

  Future<void> sendMessage(BuildContext context, String roomId, String content) async {
    try {
      await _service.sendMessage(roomId, content);
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal mengirim pesan: $e');
      }
      rethrow;
    }
  }

  Future<void> markAsRead(String roomId) async {
    try {
      await _service.markMessagesAsRead(roomId);
    } catch (e) {
      debugPrint('Gagal update status read: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyRooms(BuildContext context) async {
    try {
      return await _service.getMyChatRooms();
    } catch (e) {
      if (context.mounted) {
        debugPrint('Gagal memuat list chat: $e');
      }
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(String roomId) {
    return _service.getMessagesStream(roomId);
  }
}