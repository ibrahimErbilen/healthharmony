// lib/widgets/activity_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // İkonlar için
import 'package:healthharmony/models/Activity/user_activity_dto.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final UserActivityDTO activity;
  final VoidCallback onToggleCompletion;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR'); // Tarih formatı
    final theme = Theme.of(context); // Tema renklerine erişim

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Daha yuvarlak köşeler
      ),
      child: InkWell( // Tıklanabilirlik efekti için
        onTap: onToggleCompletion, // Kartın tamamına tıklanınca da işaretlensin
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Checkbox ve metni hizala
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.activityName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: activity.isCompleted ? Colors.grey.shade600 : Colors.blue.shade800, // Mavi renk
                            decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.grey.shade600,
                          ),
                        ),
                        if (activity.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            activity.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: activity.isCompleted ? Colors.grey.shade500 : Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox( // Checkbox'ın etrafına dokunma alanını artırmak için
                    width: 48,
                    height: 48,
                    child: Transform.scale( // Checkbox'ı biraz büyüt
                      scale: 1.2,
                      child: Checkbox(
                        value: activity.isCompleted,
                        onChanged: (_) => onToggleCompletion(), // Tamamlanmışsa da tıklanabilir olsun (geri almak için)
                        activeColor: Colors.green.shade600, // Tamamlanınca yeşil
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: activity.isCompleted ? Colors.grey.shade400 : Colors.blue.shade600, // Mavi çerçeve
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.calendarPlus, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'Eklendi: ${dateFormat.format(activity.addedDate.toLocal())}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (activity.isCompleted && activity.completionDate != null)
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.calendarCheck, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'Tamamlandı: ${dateFormat.format(activity.completionDate!.toLocal())}',
                          style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}