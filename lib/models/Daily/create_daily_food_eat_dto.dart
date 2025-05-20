// models/Daily/create_daily_food_eat_dto.dart
class CreateDailyFoodEatDto {
  final String userId;
  final String foodName;
  final int calories;
  final DateTime? date;

  CreateDailyFoodEatDto({
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'date': null,
    };
  }
}
