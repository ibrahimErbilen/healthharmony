// lib/widgets/food_search_result_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class FoodSearchResultCard extends StatelessWidget {
  final Map<String, dynamic> foodData;
  final VoidCallback onAdd;
  final bool isAdding; // Yükleme durumu için

  const FoodSearchResultCard({
    super.key,
    required this.foodData,
    required this.onAdd,
    this.isAdding = false,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat numberFormatter = NumberFormat("#,##0", "tr_TR");
    final String foodName = foodData["foodName"] ?? "Bilinmeyen Yemek";
    final int calories = foodData["calories"] ?? 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.bowlFood, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    foodName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Kalori: ${numberFormatter.format(calories)} kcal",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isAdding
                    ? Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : const Icon(Icons.add_circle_outline_rounded),
                label: Text(isAdding ? 'Ekleniyor...' : 'Bu Yemeği Ekle'),
                onPressed: isAdding ? null : onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}