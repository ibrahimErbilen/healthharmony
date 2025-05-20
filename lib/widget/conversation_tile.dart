// lib/widgets/conversation_tile.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Veya Material Icons

class ConversationTile extends StatelessWidget {
  final String username;
  final String lastMessage;
  final String? avatarUrl; // Opsiyonel avatar URL'i
  final VoidCallback onTap;
  final bool hasUnreadMessages; // Okunmamış mesaj var mı? (Opsiyonel)
  final String? timestamp; // Son mesaj zaman damgası (Opsiyonel)

  const ConversationTile({
    super.key,
    required this.username,
    required this.lastMessage,
    this.avatarUrl,
    required this.onTap,
    this.hasUnreadMessages = false,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // ListTile yerine daha fazla özelleştirme için InkWell
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : "?",
                      style: TextStyle(fontSize: 22, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasUnreadMessages ? Colors.blue.shade700 : Colors.grey.shade600,
                      fontWeight: hasUnreadMessages ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (timestamp != null || hasUnreadMessages) const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timestamp != null)
                  Text(
                    timestamp!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                if (hasUnreadMessages && timestamp != null) const SizedBox(height: 6),
                if (hasUnreadMessages)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    // child: Text("1", style: TextStyle(color: Colors.white, fontSize: 10)), // Okunmamış mesaj sayısı
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}