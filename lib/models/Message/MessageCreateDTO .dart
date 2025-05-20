class MessageCreateDTO {
  final int? messageId;
  final String senderUserId;
  final String receiverUserId;
  final String messageContent;
  final String? senderCoachId;
  final DateTime sentTime;
  final bool isRead;

  MessageCreateDTO({
    this.messageId,
    required this.senderUserId,
    required this.receiverUserId,
    required this.messageContent,
    this.senderCoachId,
    required this.sentTime,
    required this.isRead,
  });

  factory MessageCreateDTO.fromJson(Map<String, dynamic> json) {
    return MessageCreateDTO(
      messageId: json['messageId'],
      senderUserId: json['senderUserId'],
      receiverUserId: json['receiverUserId'],
      messageContent: json['messageContent'],
      senderCoachId: json['senderCoachId'],
      sentTime: DateTime.parse(json['sentTime']),
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderUserId': senderUserId,
      'receiverUserId': receiverUserId,
      'senderCoachId': senderCoachId,
      'messageContent': messageContent,
      'sentTime': sentTime.toIso8601String(),
      'isRead': isRead,
    };
  }
}
