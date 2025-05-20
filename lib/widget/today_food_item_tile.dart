// lib/widgets/today_food_item_tile.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthharmony/models/Daily/daily_food_dto.dart';
import 'package:intl/intl.dart';

class TodayFoodItemTile extends StatelessWidget {
  final DailyFoodDto foodItem;
  final VoidCallback? onDelete; // Silme işlevi için (opsiyonel)

  const TodayFoodItemTile({
    super.key,
    required this.foodItem,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat numberFormatter = NumberFormat("#,##0", "tr_TR");

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          child: Icon(FontAwesomeIcons.plateWheat, color: Colors.teal.shade600, size: 20),
        ),
        title: Text(foodItem.foodName, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text("${numberFormatter.format(foodItem.calories)} kcal"),
        trailing: onDelete != null
            ? IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: onDelete,
                tooltip: "Yemeği Sil",
              )
            : null,
      ),
    );
  }
}