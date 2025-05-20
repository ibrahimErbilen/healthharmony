// lib/widgets/coach_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Coach/Coach.dart'; // Coach modelinizin yolu

class CoachCard extends StatelessWidget {
  final Coach coach;
  final VoidCallback onMessageTap;
  final VoidCallback onDismissed;

  const CoachCard({
    super.key,
    required this.coach,
    required this.onMessageTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı al
    final primaryColor = Colors.blue.shade700; // Ana mavi renk
    final lightBlue = Colors.blue.shade100; // Açık mavi tonu
    final darkBlueText = Colors.blue.shade900; // Koyu mavi metin

    return Dismissible(
      key: Key(coach.coachId.toString()), // coachId int ise toString()
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Koçu Kaldır'),
              content: Text("'${coach.coachName}' adlı koçu listenizden kaldırmak istediğinizden emin misiniz?"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal', style: TextStyle(color: Colors.grey)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
                  child: const Text('Kaldır'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
      background: Container(
        color: Colors.red.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_sweep_outlined, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        onDismissed();
      },
      child: Card(
        elevation: 2.5, // Biraz daha az gölge
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          // Kenarlık eklenebilir (isteğe bağlı)
          // side: BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: lightBlue, // <<<--- AVATAR ARKA PLANI AÇIK MAVİ
                child: Text(
                  coach.coachName.isNotEmpty ? coach.coachName[0].toUpperCase() : "?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, // <<<--- AVATAR YAZI RENGİ MAVİ
                  ),
                ),
                // backgroundImage: coach.avatarUrl != null ? NetworkImage(coach.avatarUrl!) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.coachName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlueText, // <<<--- KOÇ ADI RENGİ KOYU MAVİ
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach.specialization,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor.withOpacity(0.9), // <<<--- UZMANLIK ALANI RENGİ MAVİ TONU
                        fontStyle: FontStyle.italic,
                      ),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coach.email,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600), // E-posta rengi
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.solidCommentDots, color: primaryColor, size: 26), // <<<--- MESAJ İKONU RENGİ MAVİ
                tooltip: "Mesaj Gönder",
                onPressed: onMessageTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}