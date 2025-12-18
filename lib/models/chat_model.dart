class ChatRoomModel {
  final String id;
  final String memberA;
  final String memberB;
  final String? lastMessage;
  final DateTime updatedAt;

  ChatRoomModel({
    required this.id,
    required this.memberA,
    required this.memberB,
    this.lastMessage,
    required this.updatedAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      memberA: json['member_a'],
      memberB: json['member_b'],
      lastMessage: json['last_message'],
      updatedAt: DateTime.parse(json['last_updated']),
    );
  }
}

class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool isMine(String myUserId) => senderId == myUserId;
}