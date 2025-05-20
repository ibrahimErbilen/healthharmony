// lib/widgets/daily_calorie_consumed_tile.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Daily/daily_data_dto.dart';
import 'package:intl/intl.dart';

class DailyCalorieConsumedTile extends StatelessWidget {
  final DailyDataDTO dailyData;

  const DailyCalorieConsumedTile({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR');
    final NumberFormat numberFormatter = NumberFormat("#,##0", "tr_TR");

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0.0), // Dikey boşluk azaltıldı
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100, // Alınan kalori için farklı renk
          child: Icon(
            FontAwesomeIcons.utensils, // Yemek/Restoran ikonu
            color: Colors.green.shade700,
            size: 20,
          ),
        ),
        title: Text(
          dateFormatter.format(dailyData.date.toLocal()),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Text(
            "${numberFormatter.format(dailyData.caloriesConsumed)} kcal alındı",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}