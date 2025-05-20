// lib/widgets/daily_step_tile.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Daily/daily_data_dto.dart'; // Modelinizin doğru yolu
import 'package:intl/intl.dart';

class DailyStepTile extends StatelessWidget {
  final DailyDataDTO dailyData;

  const DailyStepTile({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR'); // Türkçe tarih formatı
    final NumberFormat numberFormatter = NumberFormat("#,##0", "tr_TR"); // Türkçe sayı formatı

    return Card(
      elevation: 2.5,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            FontAwesomeIcons.shoePrints,
            color: Colors.blue.shade700,
            size: 22,
          ),
        ),
        title: Text(
          dateFormatter.format(dailyData.date.toLocal()),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "${numberFormatter.format(dailyData.stepCount)} adım",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          // İsteğe bağlı: Bu tarihin detay sayfasına gitmek için
          // Navigator.push(context, MaterialPageRoute(builder: (context) => StepDetailScreen(data: dailyData)));
          print("${dailyData.date} tıklandı.");
        },
      ),
    );
  }
}